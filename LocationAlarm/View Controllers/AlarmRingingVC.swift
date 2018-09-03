//
//  AlarmRingingVC.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 8/22/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AudioToolbox

class AlarmRingingVC: UIViewController {
    
    // MARK:- Declarations
    
    var didLayoutSubviews = false
    
    // AppDelegate
    var alarmRingingManager: AlarmRingingManager!
    
    // Injected
    var alarm: Alarm!
    
    // IBOutlets
    @IBOutlet weak var messageAndDistanceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var alarmNameLabel: UILabel!
    
    // MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        alarmRingingManager = appDelegate.alarmRingingManager
        
        let distance = LocationManager.getDistanceWithUnit(value: Float(alarm.distance))
        messageAndDistanceLabel.text = "Hey! We are within \(distance) of"
        locationLabel.text = alarm.details
        alarmNameLabel.text = alarm.name
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didLayoutSubviews {
            didLayoutSubviews = true
            makeViewCircular(view: imageView)
            addPulseToView(view: imageView)
        }
    }
    
    // MARK:- Actions
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        alarmRingingManager.stopRinging(for: alarm)
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Helpers
    
    func makeViewCircular(view: UIView) {
        //view.layer.borderWidth = 2
        //view.layer.borderColor = UIColor.blue.cgColor
        view.layer.cornerRadius = view.frame.size.width / 2;
        view.clipsToBounds = true
    }
    
    func addPulseToView(view: UIView) {
        let pulse = PulsingLayer(numberOfPulses: Float.infinity, radius: view.frame.width, position: view.center)
        pulse.animationDuration = 1.0
        pulse.backgroundColor = UIColor.blue.cgColor
        self.view.layer.insertSublayer(pulse, below: view.layer)
    }
    
}
