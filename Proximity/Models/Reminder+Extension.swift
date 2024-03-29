//
//  Reminder+Extension.swift
//  Proximity
//
//  Created by Joshua Borck on 6/28/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import Foundation
import CoreData

/// Class of the main entity used in the app
class Reminder: NSManagedObject {}

extension Reminder {
    // Setup the sorting of the entities and the fetch request
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        let request = NSFetchRequest<Reminder>(entityName: "Reminder")
        let creationSort = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [creationSort]
        return request
    }
    
    @NSManaged public var creationDate: Date
    @NSManaged public var reminder: String
    @NSManaged public var isChecked: Bool
    @NSManaged public var locationLabel: String?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var identifier: String
    @NSManaged public var isOnEntry: Bool
}

extension Reminder {
    static var entityName: String {
        return String(describing: Reminder.self)
    }
    
    /// Create a new reminder entity from an ReminderModel
    @nonobjc class func with(_ model: ReminderModel, in context: NSManagedObjectContext) {
        guard let reminder = NSEntityDescription.insertNewObject(forEntityName: Reminder.entityName, into: context) as? Reminder else {
            return
        }
        reminder.creationDate = Date()
        reminder.isChecked = model.isChecked
        reminder.reminder = model.reminder
        reminder.identifier = UUID().uuidString
        reminder.locationLabel = model.locationLabel
        reminder.isOnEntry = model.isOnEntry
        if let latitudeNumber = model.latitude,
            let longitudeNumber = model.longitude {
            let latitude = NSNumber(value: latitudeNumber)
            let longitude = NSNumber(value: longitudeNumber)
            reminder.latitude = latitude
            reminder.longitude = longitude
        }
    }
}

/// An enum to hold the keys for the properties of a reminder
enum ReminderKey: String {
    case creationDate
    case reminder
    case isChecked
    case locationLabel
    case longitude
    case latitude
    case identifier
    case isOnEntry
}
