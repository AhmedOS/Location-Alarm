//
//  NotificationsManager.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 9/3/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class NotificationsManager: NSObject {
    
    let notificationCenter = UNUserNotificationCenter.current()
    var alarmRingingManager: AlarmRingingManager {
        get {
            return (UIApplication.shared.delegate as! AppDelegate).alarmRingingManager
        }
    }
    
    func setup() {
        notificationCenter.delegate = self
        setNotificationCategories()
        requestPermission()
    }
    
    func setNotificationCategories() {
        let stopAction = UNNotificationAction(identifier: "STOP_ACTION", title: "Stop",
                                              options: UNNotificationActionOptions(rawValue: 0))
        let meetingInviteCategory =
            UNNotificationCategory(identifier: "ALARM_RINGING",
                                   actions: [stopAction],
                                   intentIdentifiers: [],
                                   hiddenPreviewsBodyPlaceholder: "",
                                   options: .customDismissAction)
        notificationCenter.setNotificationCategories([meetingInviteCategory])
    }
    
    func requestPermission() {
        notificationCenter.requestAuthorization(options: [.alert]) { (granted, error) in
            
        }
    }
    
    func presentNotification(alarmId: String, title: String, body: String) {
        notificationCenter.getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else {return}
            
            if settings.alertSetting == .enabled {
                let content = self.getNotificationContent(alarmId: alarmId, title: title, body: body)
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                self.requestNotification(content: content, trigger: trigger)
            }
        }
    }
    
    func getNotificationContent(alarmId: String, title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = ["ALARM_ID" : alarmId]
        content.categoryIdentifier = "ALARM_RINGING"
        return content
    }
    
    func requestNotification(content: UNMutableNotificationContent, trigger: UNNotificationTrigger) {
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if error != nil {
                //
            }
        }
    }
    
}

extension NotificationsManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        let alarmId = userInfo["ALARM_ID"] as! String

        switch response.actionIdentifier {
        case "STOP_ACTION":
            alarmRingingManager.stopRinging(for: alarmId)
            break
        default:
            break
        }
        
        completionHandler()
    }
}
