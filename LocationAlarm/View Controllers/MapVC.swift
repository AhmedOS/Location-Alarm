//
//  MapVC.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 8/15/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapVC: UIViewController {
    
    // MARK: - Declarations
    
    var searchVC: SearchResultsVC!
    
    var latitude: Double!
    var longitude: Double!
    var distance: Double!
    
    var selectedLatitude: Double!
    var selectedLongitude: Double!
    var selectedDistance: Double!
    
    var currentAnnotation: MKPointAnnotation!
    var currentCircle: MKCircle!
    
    // Closures
    var onSave: (() -> Void)?
    
    // From AppDelegate
    var locationManager: LocationManager!
    
    // IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var rangeLabel: UILabel!

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = (UIApplication.shared.delegate as! AppDelegate).locationManager
        setupSearchResultsVC()
        setupProperties()
        fetchFromModel()
    }
    
    // MARK: - Actions
    
    @IBAction func handleLongPress(_ sender: Any) {
        let gestureRecognizer = sender as! UILongPressGestureRecognizer
        if gestureRecognizer.state != .began {
            return
        }
        
        resetDistance()
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        updateSelectedCoordinate(location: touchMapCoordinate)
        setMapRegion()
    }
    
    @IBAction func distanceChanged(_ sender: Any) {
        if selectedLatitude != nil && selectedLongitude != nil {
            updateRangeLabel()
            selectedDistance = Double(distanceSlider.value)
            let coordinate = CLLocationCoordinate2D(latitude: selectedLatitude, longitude: selectedLongitude)
            addCircle(location: coordinate)
            setMapRegion()
        }
    }
    
    @IBAction func dragFinished(_ sender: Any) {
        if selectedLatitude != nil && selectedLongitude != nil {
            distanceSlider.value = max(distanceSlider.value, 1)
            distanceSlider.maximumValue = min(distanceSlider.value * 2, Float(locationManager.maximumRegionMonitoringDistance))
            saveButton.isEnabled = true
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        latitude = selectedLatitude
        longitude = selectedLongitude
        distance = selectedDistance
        onSave?()
        navigationController?.popViewController(animated: true)
    }
 
    // MARK: - Helpers
    
    func setupSearchResultsVC() {
        searchVC = SearchResultsVC()
        searchVC.parentView = self.view
        searchVC.gotCoordinateFromSearch = { (coordinate) in
            self.updateSelectedCoordinate(location: coordinate)
            self.setMapRegion()
        }
        searchBar.delegate = searchVC
    }
    
    func setupProperties() {
        saveButton.isEnabled = false
        selectedDistance = 100
        updateRangeLabel()
    }
    
    func resetDistance() {
        selectedDistance = 100
        distanceSlider.value = 100
        distanceSlider.maximumValue = 200
        updateRangeLabel()
    }
    
    func fetchFromModel() {
        if latitude != nil && longitude != nil {
            selectedLatitude = latitude
            selectedLongitude = longitude
            selectedDistance = distance
            distanceSlider.maximumValue = Float(distance * 2)
            distanceSlider.value = Float(distance)
            updateRangeLabel()
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            addCircle(location: coordinate)
            addDestinationAnnotation(coordinate: coordinate)
            setMapRegion()
        }
    }
    
    func updateSelectedCoordinate(location: CLLocationCoordinate2D) {
        addCircle(location: location)
        addDestinationAnnotation(coordinate: location)
        selectedLatitude = location.latitude
        selectedLongitude = location.longitude
        saveButton.isEnabled = true
    }
    
    func addCircle(location: CLLocationCoordinate2D) {
        let newCircle = MKCircle(center: location, radius: Double(distanceSlider.value))
        mapView.addOverlays([newCircle])
        if currentCircle != nil {
            mapView.removeOverlays([currentCircle])
        }
        currentCircle = newCircle
    }

    func addDestinationAnnotation(coordinate: CLLocationCoordinate2D) {
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = coordinate
        newAnnotation.title = "Destination"
        mapView.addAnnotation(newAnnotation)
        if currentAnnotation != nil {
            mapView.removeAnnotation(currentAnnotation)
        }
        currentAnnotation = newAnnotation
    }

    func setMapRegion() {
        let coordinate = CLLocationCoordinate2DMake(selectedLatitude, selectedLongitude)
        let span = MKCoordinateSpanMake(0.00005 * selectedDistance, 0.00005 * selectedDistance)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func updateRangeLabel() {
        rangeLabel.text = "Range: " + LocationManager.getDistanceWithUnit(value: distanceSlider.value)
    }
    
}

// MARK:- MKMapView Delegate

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        let defaultBlueColor = UIButton(type: UIButtonType.system).titleColor(for: .normal)!
        renderer.fillColor = defaultBlueColor.withAlphaComponent(0.3)
        renderer.strokeColor = UIColor.gray
        renderer.lineWidth = 1
        return renderer
    }
}

