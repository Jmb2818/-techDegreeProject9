//
//  DetailViewController.swift
//  Proximity
//
//  Created by Joshua Borck on 6/28/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var reminderView: UIView!
    @IBOutlet weak var textField: UITextField!
    private weak var mapView: MapViewController!
    
    var reminder: Reminder?
    var model: ReminderModel?
    var coreDataStack: CoreDataStack?
    var row: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? MapViewController {
            mapView = destination
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
    
    func setupView() {
        guard let model = model, let row = row else {
            return
        }
        textField.text = model.reminder
        reminderView.layer.masksToBounds = false
        reminderView.layer.cornerRadius = 20
        reminderView.layer.shadowOffset = CGSize(width: 0, height: 4)
        reminderView.layer.shadowRadius = 2
        reminderView.layer.shadowColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        reminderView.layer.shadowOpacity = 1
        reminderView.clipsToBounds = false
        reminderView.backgroundColor = isEven(row) ? #colorLiteral(red: 0.8980392157, green: 0.5450980392, blue: 0.5333333333, alpha: 1) : #colorLiteral(red: 0.9254901961, green: 0.7450980392, blue: 0.4784313725, alpha: 1)
        mapContainerView.layer.cornerRadius = 20
        mapContainerView.layer.masksToBounds = true
    }
    
    @objc func saveReminder() {
        guard let coreDataStack = coreDataStack else {
            return
        }
        
        defer {
            coreDataStack.managedObjectContext.saveChanges()
            navigationController?.popToRootViewController(animated: true)
        }
        
        guard let reminder = reminder else {
            let model = ReminderModel(reminder: textField.text ?? "", isChecked: false)
            Reminder.with(model, in: coreDataStack.managedObjectContext)
            return
        }
        
        reminder.setValue(reminder.isChecked, forKey: "isChecked")
        reminder.setValue(textField.text, forKey: "reminder")
    }
    
    private func formatSubViews() {
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
    
    @objc func cancelReminder() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func isEven(_ int: Int) -> Bool {
        if int == 0 {
            return true
        }
        if int % 2 == 0 {
            return true
        }
        return false
    }
}
