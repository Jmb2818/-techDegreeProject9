//
//  MasterViewController.swift
//  Proximity
//
//  Created by Joshua Borck on 6/25/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UIViewController {
    
    @IBOutlet weak var remindersTableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var coreDataStack = CoreDataStack()
    lazy var dataSource: ReminderTableViewDataSource = {
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        return ReminderTableViewDataSource(fetchRequest: request, managedObjectContext: self.coreDataStack.managedObjectContext, tableView: self.remindersTableView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        remindersTableView.dataSource = dataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func addReminder(_ sender: UIBarButtonItem) {
        let model = ReminderModel(reminder: "", isChecked: false)
        Reminder.with(model, in: coreDataStack.managedObjectContext)
        coreDataStack.managedObjectContext.saveChanges()
    }
}

extension MasterViewController: UITableViewDelegate {
    
}
