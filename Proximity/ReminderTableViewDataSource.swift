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
    
    var remindersCount: Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
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
            fatalError()
        }
        
        let reminder = fetchedResultsController.object(at: indexPath)
        let model = ReminderModel(reminder: reminder)
        cell.configureAt(indexPath, withModel: model)
        cell.checkedButton.tag = indexPath.row
        cell.checkedButton.addTarget(self, action: #selector(checkOffReminder), for: .touchUpInside)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
////    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        switch editingStyle {
//        case .delete:
//            let entry = fetchedResultsController.object(at: indexPath)
//            context.delete(entry)
//            context.saveChanges()
//        default:
//            break
//        }
//    }
    
    // MARK: Helper Functions
    /// Function to return the reminder at the indexPath in the fetchedResultsController
    func reminderAt(_ indexPath: IndexPath) -> Reminder {
        return fetchedResultsController.object(at: indexPath)
    }
    
    @objc func checkOffReminder(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let reminder = reminderAt(indexPath)
        if reminder.isChecked {
            reminder.setValue(false, forKey: "isChecked")
        } else {
            reminder.setValue(true, forKey: "isChecked")
        }
        context.saveChanges()
    }
}

// MARK: NSFetchedResultsControllerDelegate Conformance
extension ReminderTableViewDataSource: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

