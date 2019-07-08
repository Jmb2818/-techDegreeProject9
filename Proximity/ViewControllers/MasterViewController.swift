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
    private let locationManager = CLLocationManager()
    lazy var dataSource: ReminderTableViewDataSource = {
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        return ReminderTableViewDataSource(fetchRequest: request, managedObjectContext: self.coreDataStack.managedObjectContext, tableView: self.remindersTableView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        remindersTableView.dataSource = dataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        controller.locationManager = locationManager
        controller.coreDataStack = coreDataStack
        show(controller, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reminder = dataSource.reminderAt(indexPath)
        presentDetailView(with: reminder, from: indexPath.row)
    }
}
