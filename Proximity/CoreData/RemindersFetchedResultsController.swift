//
//  RemindersFetchedResultsController.swift
//  Proximity
//
//  Created by Joshua Borck on 6/28/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import CoreData

/// A subclass of NSFetchedResultsController for Reminder
class RemindersFetchedResultsController: NSFetchedResultsController<Reminder> {
    init(request: NSFetchRequest<Reminder>, context: NSManagedObjectContext) {
        super.init(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetch()
    }
    
    func fetch() {
        do {
            try performFetch()
        } catch {
            fatalError("Error performing fetch. Terminating App" )
        }
    }
}
