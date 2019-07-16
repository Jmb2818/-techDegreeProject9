//
//  MapViewController.swift
//  Proximity
//
//  Created by Joshua Borck on 6/30/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import UIKit
import MapKit

/// A protocol for delegating back the location selected by the MapView
protocol LocationDelegate: class {
    func locationSelected(locationString: String?, locationCoordinate: CLLocationCoordinate2D?)
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
    var coordinate: CLLocationCoordinate2D?
    var searchResultsController: UISearchController?
    
    private var hasSavedLocation: Bool {
        return coordinate != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        setupRefreshButton()
        setupGestures()
        setupSearch()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        focusOnLocation()
    }
    
    @IBAction func refreshLocation(_ sender: UIButton) {
        focusOnCurrentLocation()
    }
    
    // MARK: Helper Functions
    /// A function to setup the searchTableView and also the searchResultsController
    func setupSearch() {
        guard let searchTableVC = storyboard?.instantiateViewController(withIdentifier: "LocationSearchTableViewController") as? LocationSearchTableViewController else {
            return
        }
        searchResultsController = UISearchController(searchResultsController: searchTableVC)
        searchResultsController?.searchResultsUpdater = searchTableVC
        
        guard let searchBar = searchResultsController?.searchBar else {
            return
        }
        
        searchBar.sizeToFit()
        searchBar.placeholder = "Search For A Location"
        navigationItem.titleView = searchBar
        searchResultsController?.hidesNavigationBarDuringPresentation = false
        searchResultsController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        searchTableVC.mapView = mapView
        searchTableVC.delegate = self
        searchTableVC.searchController = searchResultsController
    }
    
    /// A function to focus on the saved location if it exists and if not then current location
    func focusOnLocation() {
        if hasSavedLocation {
            focusOnSavedLocation()
        } else {
            focusOnCurrentLocation()
        }
    }
    
    /// A funcion to zoom in on users current location if permission has been given
    func focusOnCurrentLocation() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways  {
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
    
    /// A function to focus on a saved location
    func focusOnSavedLocation() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways  {
            guard let savedLocation = coordinate else {
                return
            }
            
            let coordinateRegion = MKCoordinateRegion(center: savedLocation,
                                                      latitudinalMeters: regionRadius,
                                                      longitudinalMeters: regionRadius)
            
            mapView.setRegion(coordinateRegion, animated: true)
            addAnnotationAndOverlayFor(savedLocation)
        }
    }
    
    /// A function to format the refresh button
    func setupRefreshButton() {
        refreshLocationButton.layer.masksToBounds = false
        refreshLocationButton.layer.cornerRadius = 0.5 * refreshLocationButton.bounds.size.width
        refreshLocationButton.clipsToBounds = true
    }
    
    /// A function to setup a tap gesture to add annotation
    func setupGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(addAnnotationToLocation))
        mapView.addGestureRecognizer(tapRecognizer)
    }
    
    /// A function to add an annotation and overlay for a coordinate on the MapView
    func addAnnotationAndOverlayFor(_ coordinate: CLLocationCoordinate2D) {
        let overlays = mapView.overlays
        if !overlays.isEmpty {
            mapView.removeOverlays(overlays)
        }
        annotation.coordinate = coordinate
        mapView?.addOverlay(MKCircle(center: coordinate, radius: 100.0))
        mapView.addAnnotation(annotation)
    }
    
    /// Add a pin to the map when user taps it
    @objc private func addAnnotationToLocation(sender: UITapGestureRecognizer) {
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let lastLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        defer {
           addAnnotationAndOverlayFor(coordinate)
        }
        
        // Convert the last location into a readable location for user
        geoCoder.reverseGeocodeLocation(lastLocation) { [weak self] placemarks, error in
            guard error == nil else {
                return
            }
            
            if let location = placemarks?.first {
                let locationString = MapFormatter.format(location)
                self?.locationDelegate?.locationSelected(locationString: locationString, locationCoordinate: location.location?.coordinate)
            }
        }
    }
}

// MARK: MKMapViewDelegate Conformance
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .green
            circleRenderer.fillColor = UIColor.green.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

// MARK: CLLocationManagerDelegate Conformance
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        focusOnCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlertFor(ProximityError.locationError)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            focusOnLocation()
        default:
            break
        }
    }
}

// MARK: Search Location Delegate Conformance
extension MapViewController: SearchLocationDelegate {
    func searchResultSelected(placemark: MKPlacemark) {
        guard let location = placemark.location else {
            return
        }
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
        let locationString = MapFormatter.formatWithName(placemark)
        addAnnotationAndOverlayFor(location.coordinate)
        locationDelegate?.locationSelected(locationString: locationString, locationCoordinate: location.coordinate)
    }
}
