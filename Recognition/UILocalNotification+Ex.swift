//
//  UILocalNotification+Ex.swift
//  Recognition
//
//  Created by Nikolaus Heger on 11/19/15.
//  Copyright © 2015 Nikolaus Heger. All rights reserved.
//

import Foundation
import NotificationCenter

extension UILocalNotification {
    
    static func scheduleAlert(message: String, fireDate: NSDate) {
        let notification = UILocalNotification()
        notification.fireDate = fireDate
        notification.alertBody = message
        notification.timeZone = NSTimeZone.systemTimeZone()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.category = "RECOGNITION_CATEGORY"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

}