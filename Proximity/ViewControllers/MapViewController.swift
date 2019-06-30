//
//  MapViewController.swift
//  Proximity
//
//  Created by Joshua Borck on 6/30/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshLocationButton: UIButton!
    
    // MARK: Properties
    private let locationManager = CLLocationManager()
    private let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        setupRefreshButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        focusOnCurrentLocation()
    }
    
    @IBAction func refreshLocation(_ sender: UIButton) {
        focusOnCurrentLocation()
    }
    
    
    /// Funcion to zoom in on users current location if permission has been given
    func focusOnCurrentLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            guard let currentLocation = locationManager.location else {
                locationManager.requestLocation()
                return
            }
            
            let coordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate,
                                                      latitudinalMeters: regionRadius,
                                                      longitudinalMeters: regionRadius)
            
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    func setupRefreshButton() {
        refreshLocationButton.layer.masksToBounds = false
        refreshLocationButton.layer.cornerRadius = 0.5 * refreshLocationButton.bounds.size.width
        refreshLocationButton.clipsToBounds = true
    }
}

// MARK: CLLocationManagerDelegate Conformance
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        focusOnCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            focusOnCurrentLocation()
        default:
            break
        }
    }
}
