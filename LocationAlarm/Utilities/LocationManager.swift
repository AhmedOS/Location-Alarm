//
//  LocationManager.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 8/15/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreData

class LocationManager: CLLocationManager {
    
    // MARK: - Declarations
    
    var dataController: DataController!
    var alarmRingingManager: AlarmRingingManager!
    
    //var monitoredRegions: Set<CLRegion>
    //var maximumRegionMonitoringDistance: CLLocationDistance
    //var location: CLLocation?

    // MARK: - Main Functionalities
    
    func setup() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        alarmRingingManager = appDelegate.alarmRingingManager
        self.delegate = self
        allowsBackgroundLocationUpdates = true
        requestAlwaysAuthorization()
    }
    
    func startMonitoringAlarm(alarm: Alarm) {
        let center = CLLocationCoordinate2DMake(alarm.latitude, alarm.longitude)
        let distance = alarm.distance as CLLocationDistance
        let identifier = alarm.id!
        
        //CLLocationManager.locationServicesEnabled()
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                let region = CLCircularRegion(center: center,
                                              radius: distance, identifier: identifier)
                region.notifyOnEntry = true
                region.notifyOnExit = false
                
                startMonitoring(for: region) //limited by 20 region
            }
        }
        
    }
    
    func stopMonitoringAlarm(alarm: Alarm) {
        let center = CLLocationCoordinate2DMake(alarm.latitude, alarm.longitude)
        let distance = alarm.distance as CLLocationDistance
        let identifier = alarm.id!
        let region = CLCircularRegion(center: center, radius: distance, identifier: identifier)
        stopMonitoring(for: region)
    }
    
}

// MARK: - CLLocationManager Delegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        alarmRingingManager.startRinging(for: region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            //Disable location features
            break
            
        case .authorizedWhenInUse:
            //Enable only when-in-use features.
            break
            
        case .authorizedAlways:
            //Enable location services.
            break
            
        case .notDetermined:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        //
    }
    
}

// MARK: - Static methods

extension LocationManager {
    static func getDistanceWithUnit(value: Float) -> String {
        let roundPlaces = 1
        var distance = value
        var unit = "m"
        if distance >= 1000 {
            distance /= 1000
            unit = "km"
        }
        return distance.rounded(toPlaces: roundPlaces).toString() + unit
    }
    
    static func getLameDescription(for coordinate: CLLocationCoordinate2D) -> String {
        let description = "[" + coordinate.latitude.rounded(toPlaces: 4).toString() +
            ", " + coordinate.longitude.rounded(toPlaces: 4).toString() + "]"
        return description
    }
    
    static func getDescription(for coordinate: CLLocationCoordinate2D, completionHandler: @escaping (String) -> ()) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = (placemarks?[0].name)!
                completionHandler(firstLocation)
            }
            else {
                let description = getLameDescription(for: coordinate)
                completionHandler(description)
            }
        })
    }
}

