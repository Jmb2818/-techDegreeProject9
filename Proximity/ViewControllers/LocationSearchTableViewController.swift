//
//  LocationSearchTableViewController.swift
//  Proximity
//
//  Created by Joshua Borck on 7/1/19.
//  Copyright © 2019 Joshua Borck. All rights reserved.
//

import UIKit
import MapKit

protocol SearchLocationDelegate: class {
    func searchResultSelected(placemark: MKPlacemark)
}

class LocationSearchTableViewController: UITableViewController {
    
    private var matchingLocations: [MKMapItem] = []
    var mapView: MKMapView?
    weak var delegate: SearchLocationDelegate?
    weak var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension LocationSearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView, let searchText = searchController.searchBar.text else {
            return
        }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        searchRequest.region = mapView.region
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] response, error in
            guard let response = response else {
                // TODO: Errors
                return
            }
            
            self?.matchingLocations = response.mapItems
            self?.tableView.reloadData()
        }
    }
}

extension LocationSearchTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        let selectedLocation = matchingLocations[indexPath.row].placemark
        cell.textLabel?.text = selectedLocation.name
        cell.detailTextLabel?.text = format(selectedLocation)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocation = matchingLocations[indexPath.row].placemark
        searchController?.searchBar.text = selectedLocation.name
        delegate?.searchResultSelected(placemark: selectedLocation)
        dismiss(animated: true, completion: nil)
    }
}
