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
    
    static func scheduleAlert(_ message: String, fireDate: Date) {
        let notification = UILocalNotification()
        notification.fireDate = fireDate
        notification.alertBody = message
        notification.timeZone = TimeZone.current
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.category = Constants.NotificationCategory
        notification.repeatInterval = NSCalendar.Unit.day
        UIApplication.shared.scheduleLocalNotification(notification)
    }

}
