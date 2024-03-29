//
//  ReminderTableViewDataSource.swift
//  Proximity
//
//  Created by Joshua Borck on 6/26/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import UIKit
import CoreData

class ReminderTableViewDataSource: NSObject, UITableViewDataSource {
    // MARK: Properties
    private let tableView: UITableView
    private let fetchedResultsController: RemindersFetchedResultsController
    private let context: NSManagedObjectContext
    weak var controller: MasterViewController?
    
    // MARK: Computed Vars
    var remindersCount: Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    var reminders: [Reminder] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    // MARK: Initializers
    init(fetchRequest: NSFetchRequest<Reminder>, managedObjectContext context: NSManagedObjectContext, tableView: UITableView) {
        self.tableView = tableView
        self.fetchedResultsController = RemindersFetchedResultsController(request: fetchRequest, context: context)
        self.context = context
        super.init()
        
        self.fetchedResultsController.delegate = self
    }
    
    // MARK: TableViewDelegate Conformance
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as? ReminderCell else {
            fatalError("Could not create a reminder cell. Terminating App")
        }
        
        let reminder = fetchedResultsController.object(at: indexPath)
        let model = ReminderModel(reminder: reminder)
        cell.configureAt(indexPath, withModel: model)
        cell.checkedButton.tag = indexPath.row
        cell.checkedButton.addTarget(self, action: #selector(checkOffReminder), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let reminder = fetchedResultsController.object(at: indexPath)
            controller?.stopMonitoringDeletedReminder(reminder)
            context.delete(reminder)
            context.saveChanges()
        default:
            break
        }
    }
    
    // MARK: Helper Functions
    /// Function to return the reminder at the indexPath in the fetchedResultsController
    func reminderAt(_ indexPath: IndexPath) -> Reminder {
        return fetchedResultsController.object(at: indexPath)
    }
    
    /// A function to set the reminder as being checked or not depending on original state
    @objc func checkOffReminder(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let reminder = reminderAt(indexPath)
        if reminder.isChecked {
            reminder.setValue(false, forKey: ReminderKey.isChecked.rawValue)
        } else {
            reminder.setValue(true, forKey: ReminderKey.isChecked.rawValue)
        }
        context.saveChanges()
    }
    
    /// A function to return the reminder's reminder that matches the given identifier
    func textForReminderWith(_ identifier: String) -> String {
        if let selectedReminder = reminderWithIdentifierMatching(identifier){
            return selectedReminder.reminder
        } else {
            return UserStrings.General.emptyString
        }
    }
    
    /// A function to return a reminder if it exists that matches the given identifier
    func reminderWithIdentifierMatching(_ identifier: String) -> Reminder? {
        return reminders.first(where: { $0.identifier == identifier })
    }
}


// MARK: NSFetchedResultsControllerDelegate Conformance
extension ReminderTableViewDataSource: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

