//
//  ReminderEngine.swift
//  Recognition
//
//  Created by Nikolaus Heger on 1/11/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import Foundation
import UIKit

class ReminderEngine {
    // singleton
    static let reminderEngine = ReminderEngine()
    
    // instance variables
    var futureReminders = [NSDate]()
    var observer: NSObjectProtocol!

    var isRunning: Bool {
        get {
            return AppDelegate.delegate().settings.running
        }
        set(value) {
            AppDelegate.delegate().settings.running = value
        }
    }

    func stop() {
        isRunning = false
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        futureReminders = [NSDate]()
        if (observer != nil) {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    func start() {
        isRunning = true
        updateReminders()
        observer = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.SettingsChanged, object: nil, queue: nil) { notification in
            self.updateReminders()
        }
    }
    
    // cancels all existing reminders and creates new ones
    func updateReminders() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        futureReminders = createReminderTimesForToday()
        print("Setting reminders for:")
        for date in futureReminders {
            print("reminder with daily repeat on: \(date.toLocalString())")
            scheduleNotification(date)
        }

    }
    
    private func scheduleNotification(date: NSDate) {
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.alertBody = "Take 2-5 seconds to recognize that you exist. Let go of all thoughts."
        notification.timeZone = NSTimeZone.systemTimeZone()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.category = "RECOGNITION_CATEGORY"
        // this is the trick - we just set a daily repetition
        // othewise 64 reminders is the most we can schedule
        notification.repeatInterval = NSCalendarUnit.Day
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    // MARK: Model
    private func createReminderTimesForToday() -> [NSDate] {
        let nowTime = NSDate()
        let settings = AppDelegate.delegate().settings
        let startTime = NSDate(year: nowTime.year(), month: nowTime.month(), day: nowTime.day(), hour: Int(settings.startTime), minute: 0, second: 0)
        let endTime = NSDate(year: nowTime.year(), month: nowTime.month(), day: nowTime.day(), hour: Int(settings.stopTime), minute: 0, second: 0)
        var totalMinutes: Float = Float(endTime.minutesLaterThan(startTime))
        if (totalMinutes < 1) {
            totalMinutes = 1
        }
        let numberOfReminders = settings.remindersPerDay
        let minutesPerReminder = Int(totalMinutes / Float(numberOfReminders))
        
        print("start: \(startTime.toLocalString())")
        print("end: \(endTime.toLocalString()) ")
        print("reminders: \(numberOfReminders)")
        print("minutes per reminder: \(minutesPerReminder)")

        
        var reminderTimes = [NSDate]()
        var fireTime = startTime
        for _ in 0..<numberOfReminders {
            fireTime = fireTime.dateByAddingMinutes(minutesPerReminder)
            if fireTime.isLaterThan(nowTime) {
                reminderTimes.append(fireTime)
                print("added reminder time: \(fireTime.toLocalString())")
            } else {
                print("added reminder time for tomorrow: \(fireTime.dateByAddingDays(1).toLocalString())")
                reminderTimes.append(fireTime.dateByAddingDays(1))
            }
        }
        return reminderTimes
    }

}