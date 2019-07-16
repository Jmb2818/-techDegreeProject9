//
//  DetailViewController.swift
//  Proximity
//
//  Created by Joshua Borck on 6/28/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var reminderView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var selectLocationLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var onEntryButton: UIButton!
    @IBOutlet weak var onExitButton: UIButton!
    @IBOutlet weak var charactersCountLabel: UILabel!
    
    // MARK: Properties
    private weak var mapView: MapViewController!
    private var currentCoordinates: CLLocationCoordinate2D?
    var reminder: Reminder?
    var model: ReminderModel?
    var coreDataStack: CoreDataStack?
    var row: Int?
    
    // MARK: Computed Properties
    private var textFieldTextCount: Int {
        return textField.text?.count ?? 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViewForModel()
        formatSubViews()
        formatViewButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLocationCoordinates()
        setupButtons()
        updateCount()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? UINavigationController,
            let mapView = destination.viewControllers.first as? MapViewController {
            self.mapView = mapView
            mapView.locationDelegate = self
        }
    }
    
    // MARK: IBActions
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        updateCount()
    }
    
    @IBAction func selectedButton(_ sender: UIButton) {
        formatViewButtons()
        sender.isSelected = true
        sender.layer.shadowOffset = CGSize.zero
        sender.layer.shadowRadius = 0
        sender.layer.shadowOpacity = 0
        sender.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        sender.layer.borderWidth = 2.0
    }
}

private extension DetailViewController {
    // MARK: View Setup
    func setupButtons() {
        if let model = model, model.isOnEntry {
            selectedButton(onEntryButton)
        } else {
            selectedButton(onExitButton)
        }
    }
    
    func setupNavigationBar() {
        let backButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelReminder))
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveReminder))
        navigationItem.setLeftBarButton(backButton, animated: false)
        navigationItem.setRightBarButton(saveButton, animated: false)
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    func setupViewForModel() {
        guard let model = model, let row = row else {
            showAlertFor(ProximityError.failureSettingUpView)
            return
        }
        textField.text = model.reminder
        textField.delegate = self
        reminderView.backgroundColor = isEven(row) ? #colorLiteral(red: 0.8980392157, green: 0.5450980392, blue: 0.5333333333, alpha: 1) : #colorLiteral(red: 0.9254901961, green: 0.7450980392, blue: 0.4784313725, alpha: 1)
        
        // If there is a location setup the location label
        if let location = model.locationLabel {
            selectLocationLabel.text = UserStrings.General.selectedLocation
            locationLabel.text = location
        } else {
            selectLocationLabel.text = UserStrings.General.selectLocation
            locationLabel.text = nil
        }
    }
    
    func isEven(_ int: Int) -> Bool {
        if int == 0 {
            return true
        }
        if int % 2 == 0 {
            return true
        }
        return false
    }
    
    /// A function to show a reminder's area on the map if it exists
    func setupLocationCoordinates() {
        guard let reminder = reminder,
            let longitudeNumber = reminder.longitude,
            let latitudeNumber = reminder.latitude,
            let longitude = CLLocationDegrees(exactly: longitudeNumber),
            let latitude = CLLocationDegrees(exactly: latitudeNumber) else {
            return
        }
        self.currentCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func formatSubViews() {
        // Round the reminderView everything is held in
        reminderView.layer.masksToBounds = false
        reminderView.layer.cornerRadius = 20
        reminderView.layer.shadowOffset = CGSize(width: 0, height: 4)
        reminderView.layer.shadowRadius = 2
        reminderView.layer.shadowColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        reminderView.layer.shadowOpacity = 1
        reminderView.clipsToBounds = false
        
        // Round the containerView
        mapContainerView.layer.cornerRadius = 20
        mapContainerView.layer.masksToBounds = true
    }
    
    func formatViewButtons() {
        // Round buttons for onEntry and onExit
        let onLocationButtons = [onExitButton, onEntryButton]
        onLocationButtons.forEach { button in
            button?.layer.masksToBounds = false
            button?.layer.cornerRadius = 5
            button?.layer.borderWidth = 0
            button?.layer.shadowOffset = CGSize(width: 0, height: 4)
            button?.layer.shadowRadius = 2
            button?.layer.shadowColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            button?.layer.shadowOpacity = 1
            button?.clipsToBounds = false
            button?.isSelected = false
        }
    }
    
    // MARK: Helper Functions
    /// A function to update the count of the characters for the textField
    func updateCount() {
        guard textField.text != UserStrings.General.emptyString else {
            charactersCountLabel.text = UserStrings.General.noCharacters
                return
        }

        let count = String(textFieldTextCount)
        charactersCountLabel.text = [count, UserStrings.General.someCharacters].joined()
    }
    
    /// A function to save a reminder to core data
    @objc func saveReminder() {
        guard let coreDataStack = coreDataStack else {
            return
        }
        
        defer {
            // Always save changes and dismiss the DetailViewController
            coreDataStack.managedObjectContext.saveChanges()
            navigationController?.popToRootViewController(animated: true)
        }
        
        guard let reminder = reminder else {
            // If there is no existing reminder then create one
            let model = ReminderModel(reminder: textField.text ?? "",
                                      isChecked: false,
                                      locationLabel: locationLabel.text,
                                      latitude: currentCoordinates?.latitude,
                                      longitude: currentCoordinates?.longitude,
                                      isOnEntry: onEntryButton.isSelected)
            Reminder.with(model, in: coreDataStack.managedObjectContext)
            return
        }
        
        // Set all the values for the current reminder
        reminder.setValue(reminder.isChecked, forKey: ReminderKey.isChecked.rawValue)
        reminder.setValue(textField.text, forKey: ReminderKey.reminder.rawValue)
        reminder.setValue(onEntryButton.isSelected, forKey: ReminderKey.isOnEntry.rawValue)
        if let location = locationLabel.text {
            reminder.setValue(location, forKey: ReminderKey.locationLabel.rawValue)
        }
        if let longitude = currentCoordinates?.longitude,
            let latitude = currentCoordinates?.latitude {
            reminder.setValue(longitude, forKey: ReminderKey.longitude.rawValue)
            reminder.setValue(latitude, forKey: ReminderKey.latitude.rawValue)
        }
    }
    
    /// A function to dismiss the DetailViewController
    @objc func cancelReminder() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: LocationDelegate Conformance
extension DetailViewController: LocationDelegate {
    func locationSelected(locationString: String?, locationCoordinate: CLLocationCoordinate2D?) {
        selectLocationLabel.text = "Current Selected Location"
        locationLabel.text = locationString
        currentCoordinates = locationCoordinate
    }
}

// MARK: UITextFieldDelegate Conformance
extension DetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateCount()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateCount()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // If it is a line break then resign first responder
        if string == UserStrings.General.lineBreak {
            textField.resignFirstResponder()
            return false
        }
        
        if string == UserStrings.General.emptyString {
            return true
        }
        
        // Stop allowing entering of text at 50 characters
        return textFieldTextCount <= 49
    }
}
