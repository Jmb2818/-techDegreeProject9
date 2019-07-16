//
//  ReminderModel.swift
//  Proximity
//
//  Created by Joshua Borck on 6/27/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import Foundation

/// A model for each reminder
struct ReminderModel {
    
    // MARK: Properties
    let reminder: String
    let isChecked: Bool
    let locationLabel: String?
    let longitude: Double?
    let latitude: Double?
    let isOnEntry: Bool
    
    // MARK: Initializers
    init(reminder: String, isChecked: Bool, locationLabel: String? = nil, latitude: Double? = nil, longitude: Double? = nil, isOnEntry: Bool = true) {
        self.reminder = reminder
        self.isChecked = isChecked
        self.locationLabel = locationLabel
        self.longitude = longitude
        self.latitude = latitude
        self.isOnEntry = isOnEntry
    }
    
    init(reminder: Reminder) {
        self.reminder = reminder.reminder
        self.isChecked = reminder.isChecked
        self.isOnEntry = reminder.isOnEntry
        self.locationLabel = reminder.locationLabel
        if let longitude = reminder.longitude as? Double,
            let latitude = reminder.latitude as? Double {
            self.longitude = longitude
            self.latitude = latitude
        } else {
            self.longitude = nil
            self.latitude = nil
        }
    }
}
