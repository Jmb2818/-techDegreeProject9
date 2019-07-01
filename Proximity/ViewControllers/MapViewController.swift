//
//  MapViewController.swift
//  Proximity
//
//  Created by Joshua Borck on 6/30/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import UIKit
import MapKit

protocol LocationDelegate: class {
    func locationSelected(locationString: String?)
}
    

class MapViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshLocationButton: UIButton!
    
    // MARK: Properties
    private let locationManager = CLLocationManager()
    private let regionRadius: CLLocationDistance = 1000
    private let annotation = MKPointAnnotation()
    private let geoCoder = CLGeocoder()
    weak var locationDelegate: LocationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        setupRefreshButton()
        setupGestures()
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
    
    func setupGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(addAnnotationToLocation))
        mapView.addGestureRecognizer(tapRecognizer)
    }
    
    /// Add a pin to the map when user taps it
    @objc private func addAnnotationToLocation(sender: UITapGestureRecognizer) {
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let lastLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        // Convert the last location into a readable location for user
        geoCoder.reverseGeocodeLocation(lastLocation) { [weak self] placemarks, error in
            guard error == nil else {
                return
            }
            
            if let location = placemarks?.first {
                let city = location.locality ?? ""
                let state = location.administrativeArea ?? ""
                if let street = location.thoroughfare {
                    let locationString = "\(street) - \(city), \(state)"
                    self?.locationDelegate?.locationSelected(locationString: locationString)
                } else {
                    let locationString = "\(city), \(state)"
                    self?.locationDelegate?.locationSelected(locationString: locationString)
                }
            }
        }
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
