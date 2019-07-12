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

class MasterViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var remindersTableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var coreDataStack = CoreDataStack()
    private var locationManager: CLLocationManager?
    lazy var dataSource: ReminderTableViewDataSource = {
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        return ReminderTableViewDataSource(fetchRequest: request, managedObjectContext: self.coreDataStack.managedObjectContext, tableView: self.remindersTableView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = (UIApplication.shared.delegate as? AppDelegate)?.locationManager
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        remindersTableView.dataSource = dataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager?.requestLocation()
//        monitorReminders()
    }
    
    @IBAction func addReminder(_ sender: UIBarButtonItem) {
        presentDetailView(with: nil)
    }
    
    private func presentDetailView(with reminder: Reminder?, from row: Int = 0) {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reminder = dataSource.reminderAt(indexPath)
        presentDetailView(with: reminder, from: indexPath.row)
    }
    
    func createGeoRegionWith(_ reminder: Reminder) -> CLCircularRegion? {
        if let latitudeNumber = reminder.latitude,
            let longitudeNumber = reminder.longitude,
            let latitude = CLLocationDegrees(exactly: latitudeNumber),
            let longitude = CLLocationDegrees(exactly: longitudeNumber) {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = CLCircularRegion(center: coordinate, radius: 75.0, identifier: reminder.identifier)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            return region
        }
        return nil
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(monitorReminders), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: coreDataStack.managedObjectContext)
    }
    
    @objc func monitorReminders() {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            // TODO: Throw an error that geo location is not allowed
            print("Monitoring is not available")
            return
        }
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else {
            // TODO: Throw an error that you need to authorize always from settings
            print("Need to authorize always")
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
    
    func startMonitoring(_ reminder: Reminder) {
        if let region = createGeoRegionWith(reminder) {
            locationManager?.startMonitoring(for: region)
        }
    }
    
    func stopMonitoring(_ reminder: Reminder) {
        if let region = locationManager?.monitoredRegions.first(where: { $0.identifier == reminder.identifier }) {
            locationManager?.stopMonitoring(for: region)
        }
    }
}

extension MasterViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        return
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
}
