//
//  MasterViewController.swift
//  Proximity
//
//  Created by Joshua Borck on 6/25/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import UserNotifications

class MasterViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var remindersTableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: Properties
    private let coreDataStack = CoreDataStack()
    private let locationManager = CLLocationManager()
    lazy var dataSource: ReminderTableViewDataSource = {
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        return ReminderTableViewDataSource(fetchRequest: request, managedObjectContext: self.coreDataStack.managedObjectContext, tableView: self.remindersTableView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        remindersTableView.dataSource = dataSource
        dataSource.controller = self
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.requestLocation()
            monitorReminders()
        }
    }
    
    // MARK: IBActions
    @IBAction func addReminder(_ sender: UIBarButtonItem) {
        presentDetailView(with: nil)
    }
    
    func stopMonitoringDeletedReminder(_ reminder: Reminder) {
        stopMonitoring(reminder)
    }
}

// MARK: Private Extension of Helper Functions
private extension MasterViewController {
    
    /// A function to add observers for when the core data context updates
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(monitorReminders), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: coreDataStack.managedObjectContext)
    }
    
    /// A function to present the detail view to edit a reminder and will get the reminder passed to it
    func presentDetailView(with reminder: Reminder?, from row: Int = 0) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyBoard.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController else {
            return
        }
        
        if let reminder = reminder {
            let model = ReminderModel(reminder: reminder)
            controller.model = model
            controller.reminder = reminder
            controller.row = row
        } else {
            controller.model = ReminderModel(reminder: "", isChecked: false)
            controller.row = row
        }
        
        controller.coreDataStack = coreDataStack
        show(controller, sender: nil)
    }
    
    /// A function to call to handle the notification from a region entry or exit
    /// Handles both if the app is active or backgrounded
    func handleNotificationFor(_ reminderIdentifier: String) {
        let reminderText = dataSource.textForReminderWith(reminderIdentifier)
        if UIApplication.shared.applicationState == .active {
            showAlert(title: "Reminder", message: reminderText)
        } else {
            let content = UNMutableNotificationContent()
            content.body = reminderText
            content.title = "Don't Forget!"
            content.sound = UNNotificationSound.default
            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber.advanced(by: 1))
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
            let notificationCenter = UNUserNotificationCenter.current()
            // TODO: Maybe handle error in the completion handler
            notificationCenter.add(request, withCompletionHandler: nil)
            notificationCenter.delegate = self
        }
    }
    
    /// A function to create a CLCircularRegion from a reminder with a radius of 100 m
    func createGeoRegionWith(_ reminder: Reminder) -> CLCircularRegion? {
        if let latitudeNumber = reminder.latitude,
            let longitudeNumber = reminder.longitude,
            let latitude = CLLocationDegrees(exactly: latitudeNumber),
            let longitude = CLLocationDegrees(exactly: longitudeNumber) {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = CLCircularRegion(center: coordinate, radius: 100.0, identifier: reminder.identifier)
            region.notifyOnEntry = reminder.isOnEntry
            region.notifyOnExit = !reminder.isOnEntry
            return region
        }
        return nil
    }
    
    /// A function to start monitoring a region associated with the reminder
    func startMonitoring(_ reminder: Reminder) {
        if let region = createGeoRegionWith(reminder) {
            locationManager.startMonitoring(for: region)
        }
    }
    
    /// A function to stop monitoring a region associated with the reminder
    func stopMonitoring(_ reminder: Reminder) {
        if let region = locationManager.monitoredRegions.first(where: { $0.identifier == reminder.identifier }) {
            locationManager.stopMonitoring(for: region)
        }
    }
    
    /// A function to check to make sure monitoring is allowed and then set it up off of the reminders
    @objc func monitorReminders() {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            showAlertFor(ProximityError.needToAllowMonitoring)
            return
        }
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else {
            showAlertFor(ProximityError.needsLocationAuthorization)
            return
        }
        
        let reminders = dataSource.reminders
        reminders.forEach {
            if !$0.isChecked {
                startMonitoring($0)
            }
            
            if $0.isChecked {
                stopMonitoring($0)
            }
        }
    }
    
}

// MARK: UITableViewDelegate Conformance
extension MasterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reminder = dataSource.reminderAt(indexPath)
        presentDetailView(with: reminder, from: indexPath.row)
    }
}

// MARK: CLLocationManagerDelegate
extension MasterViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        return
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            // After authorization, request the location and monitor any existing reminder regions
            locationManager.requestLocation()
            monitorReminders()
        default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlertFor(ProximityError.locationError)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        showAlertFor(ProximityError.monitoringFailure)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        handleNotificationFor(region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
       handleNotificationFor(region.identifier)
    }
}

// MARK: UNUserNotificationCenterDelegate Conformance
extension MasterViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // TODO: Check off event I think
        let identifier = response.notification.request.identifier
        if let reminder = dataSource.reminderWithIdentifierMatching(identifier) {
            reminder.setValue(true, forKey: ReminderKey.isChecked.rawValue)
            coreDataStack.managedObjectContext.saveChanges()
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
