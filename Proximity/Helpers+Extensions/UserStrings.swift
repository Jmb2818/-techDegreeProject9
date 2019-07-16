//
//  UserStrings.swift
//  Proximity
//
//  Created by Joshua Borck on 7/15/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import Foundation

/// A class for holding strings the user will see
class UserStrings {
    enum General {
        static let lineBreak = "\n"
        static let noCharacters = "0/50"
        static let someCharacters = "/50"
        static let emptyString = ""
        static let selectedLocation = "Current Selected Location"
        static let selectLocation = "Select A Location For The Reminder"
    }
    
    enum Error {
        static let okTitle = "OK"
        static let error = "Error"
    }
}
