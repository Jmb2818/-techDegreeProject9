//
//  MapFormatter.swift
//  Proximity
//
//  Created by Joshua Borck on 7/12/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import Foundation
import MapKit

/// Class for formatting strings for anything using a mapView
class MapFormatter {
    
    /// A function to format a MKPlacemark into an address
    static func format(_ placemark: MKPlacemark) -> String {
        var locationString = ""
        let city = placemark.locality ?? ""
        let state = placemark.administrativeArea ?? ""
        if let street = placemark.thoroughfare, let streetNum = placemark.subThoroughfare {
            locationString = "\(streetNum) \(street) - \(city), \(state)"
        } else if let street = placemark.thoroughfare {
            locationString = "\(street) - \(city), \(state)"
        } else {
            locationString = "\(city), \(state)"
        }
        return locationString
    }
    
    /// A function to format a CLPlacemark into an address
    static func format(_ placemark: CLPlacemark) -> String {
        var locationString = ""
        let city = placemark.locality ?? ""
        let state = placemark.administrativeArea ?? ""
        if let street = placemark.thoroughfare, let streetNum = placemark.subThoroughfare {
            locationString = "\(streetNum) \(street) - \(city), \(state)"
        } else if let street = placemark.thoroughfare {
            locationString = "\(street) - \(city), \(state)"
        } else {
            locationString = "\(city), \(state)"
        }
        return locationString
    }
    
    /// A function to format a MKPlacemark into the name of the address rather than the street number
    static func formatWithName(_ placemark: MKPlacemark) -> String {
        var locationString = ""
        if let locationName = placemark.name {
            locationString = locationName
        } else {
            locationString = format(placemark)
        }
        return locationString
    }
}
