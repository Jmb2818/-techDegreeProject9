//
//  ProximityErrors.swift
//  Proximity
//
//  Created by Joshua Borck on 7/14/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import Foundation

/// An enum to hold all of the errors for the app
enum ProximityError: Error {
    case locationError
    case monitoringFailure
    case failureSettingUpView
    case needsLocationAuthorization
    case needToAllowMonitoring
    case searchFailure
    
    var errorTitle: String {
        switch self {
        case .locationError:
            return "Location Error"
        case .monitoringFailure:
            return "Error Monitoring Region"
        case .failureSettingUpView:
            return "Error with Reminder"
        case .needToAllowMonitoring:
            return "Region Monitoring Now Allowed"
        case .needsLocationAuthorization:
            return "Location Authorization Needed"
        case .searchFailure:
            return "Search Result Error"
        }
    }
    
    var errorMessage: String {
        switch self {
        case .locationError:
            return "There was an error trying to get your location. Make sure you have service and try again."
        case .monitoringFailure:
            return "There was an error trying to monitor one of the regions. Make sure you have service and try again."
        case .failureSettingUpView:
            return "There was an error when loading the reminder. Please try again"
        case .needToAllowMonitoring:
            return "Please allow this app to access and monitor your location"
        case .needsLocationAuthorization:
            return "Please allow this app to always access your location"
        case .searchFailure:
            return "There was an error retrieving the search results. Please try again"
        }
    }
}
