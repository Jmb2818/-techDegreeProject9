//
//  GlobalFunctions.swift
//  Proximity
//
//  Created by Joshua Borck on 7/1/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import Foundation
import MapKit

func isEven(_ int: Int) -> Bool {
    if int == 0 {
        return true
    }
    if int % 2 == 0 {
        return true
    }
    return false
}

// TODO: Move into MapViewController
func format(_ placemark: MKPlacemark) -> String {
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

func format(_ placemark: CLPlacemark) -> String {
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


func formatWithName(_ placemark: MKPlacemark) -> String {
    var locationString = ""
    if let locationName = placemark.name {
        locationString = locationName
    } else {
        locationString = format(placemark)
    }
    return locationString
}
