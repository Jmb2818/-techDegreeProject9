//
//  ReminderModel.swift
//  Proximity
//
//  Created by Joshua Borck on 6/27/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import Foundation

struct ReminderModel {
    let reminder: String
    let isChecked: Bool
    let locationLabel: String?
    
    init(reminder: String, isChecked: Bool) {
        self.reminder = reminder
        self.isChecked = isChecked
        self.locationLabel = nil
    }
    
    init(reminder: Reminder) {
        self.reminder = reminder.reminder
        self.isChecked = reminder.isChecked
        self.locationLabel = reminder.locationLabel
    }
}
