//
//  TableCell.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 8/13/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation
import UIKit

class TableCell: UITableViewCell {
    
    let locationManager = (UIApplication.shared.delegate as! AppDelegate).locationManager
    
    static var defaultReuseIdentifier: String {
        get {
            return "\(self)"
        }
    }
    
    var alarm: Alarm!
    @IBOutlet weak var alarmName: UILabel!
    @IBOutlet weak var alarmDetails: UILabel!
    @IBOutlet weak var alarmSwitch: UISwitch!
    
    @IBAction func alarmSwitchValueChanged(_ sender: Any) {
        if alarmSwitch.isOn {
            alarm.isEnabled = true
            locationManager.startMonitoringAlarm(alarm: alarm)
        }
        else {
            alarm.isEnabled = false
            locationManager.stopMonitoringAlarm(alarm: alarm)
        }
        try? (UIApplication.shared.delegate as! AppDelegate).dataController.viewContext.save()
    }
    
}
