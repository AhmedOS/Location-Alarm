//
//  AlarmRingingManager.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 9/3/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation
import UIKit

class AlarmRingingManager {
    
    var ringingVC: AlarmRingingVC?
    
    private var appDelegate: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    let mainStoryboardName = "Main"
    let alarmRingingVCId = "AlarmRingingVC"
    var rootVC: UIViewController? {
        get {
            return (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController
        }
    }
    
    func startRinging(for alarmId: String) {
        let alarm = appDelegate.dataController.getAlarm(with: alarmId)!
        startRinging(for: alarm)
    }
    
    func startRinging(for alarm: Alarm) {
        if UIApplication.shared.applicationState != .active {
            let distance = LocationManager.getDistanceWithUnit(value: Float(alarm.distance))
            appDelegate.notificationsManager.presentNotification(
                        alarmId: alarm.id!, title: "Ding Ding! \"\(alarm.name!)\" is ringing...",
                        body: "We are within \(distance) of \(alarm.details!)")
        }
        let storyboard = UIStoryboard(name: mainStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: alarmRingingVCId) as! AlarmRingingVC
        vc.alarm = alarm
        ringingVC = vc
        rootVC?.present(vc, animated: true, completion: nil)
        appDelegate.audioPlayer.play(sound: Sound.init(rawValue: alarm.sound!)!)
        scheduleToStopAndDismiss(for: alarm, with: vc)
    }
    
    func stopRinging(for alarmId: String) {
        let alarm = appDelegate.dataController.getAlarm(with: alarmId)!
        stopRinging(for: alarm)
    }
    
    func stopRinging(for alarm: Alarm) {
        appDelegate.audioPlayer.stop()
        ringingVC?.dismiss(animated: true, completion: nil)
        if !alarm.stayActive {
            alarm.isEnabled = false
            appDelegate.locationManager.stopMonitoringAlarm(alarm: alarm)
        }
    }
    
    func scheduleToStopAndDismiss(for alarm: Alarm, with vc: AlarmRingingVC) {
        let seconds = 60.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if vc.isViewLoaded && vc.view.window != nil {
                self.stopRinging(for: alarm)
            }
        }
    }
    
    func vibrate() {
        //AudioServicesPlayAlertSound
        //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        //let generator = UIImpactFeedbackGenerator(style: .heavy)
        //generator.impactOccurred()
    }
    
}
