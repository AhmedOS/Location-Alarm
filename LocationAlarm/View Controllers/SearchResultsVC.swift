//
//  SearchResultsVC.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 8/31/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit
import MapKit

class SearchResultsVC: UIViewController {
    
    var parentView: UIView! // Injected
    
    var tableView: UITableView!
    var searchCompleter: MKLocalSearchCompleter!
    var results: [MKLocalSearchCompletion]!
    var searchBar: UISearchBar!
    
    var gotCoordinateFromSearch: ((CLLocationCoordinate2D) -> Void)?
    
    func setup(for searchBar: UISearchBar) {
        self.searchBar = searchBar
        if searchBar.text == "" {
            results = nil
        }
        searchCompleter = MKLocalSearchCompleter()
        //searchCompleter.region
        searchCompleter.delegate = self
        
        var frame = UIScreen.main.bounds
        let value = searchBar.frame.origin.y + searchBar.frame.size.height
        frame.origin.y += value
        frame.size.height -= value
        tableView = UITableView(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

// MARK:- UISearchBar Delegate

extension SearchResultsVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        setup(for: searchBar)
        parentView.addSubview(tableView)
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tableView.removeFromSuperview()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchBar.text!
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
    }
    
}

// MARK:- MKLocalSearchCompleter Delegate

extension SearchResultsVC: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
        tableView.reloadData()
    }
    
}

// MARK:- UITableView Delegate and DataSource

extension SearchResultsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if results != nil {
            return results.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        if results != nil {
            cell?.textLabel?.text = results[indexPath.row].title
            cell?.detailTextLabel?.text = results[indexPath.row].subtitle
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let completionResult = results[indexPath.row]
        searchBar.text = completionResult.title
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.endEditing(true)
        let searchRequest = MKLocalSearchRequest(completion: completionResult)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let coordinate = response?.mapItems[0].placemark.coordinate
            self.gotCoordinateFromSearch?(coordinate!)
        }
    }
    
}

