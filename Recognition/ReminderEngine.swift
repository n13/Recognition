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
    
    
    func initEngine() {
        if (isRunning && futureReminders.count == 0) {
            // we are running update ensures we have correct dates set
            updateReminders()
        }
        observer = NSNotificationCenter.defaultCenter().addObserverForName(Settings.Notifications.SettingsChanged, object: nil, queue: nil) { notification in
            if self.isRunning {
                self.updateReminders()
            }
        }

    }
    
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
        updateReminders()
    }
    
    func start() {
        isRunning = true
        updateReminders()
    }
    
    // cancels all existing reminders and creates new ones
    func updateReminders() {
        // kill all existing notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // if we're running, add new notifications
        if (isRunning) {
            futureReminders = createReminderTimesForToday()
            print("Setting reminders for:")
            for date in futureReminders {
                print("reminder with daily repeat on: \(date.toLocalString())")
                scheduleNotification(date)
            }
        } else {
            futureReminders = [NSDate]()
        }
    }
    
    private func scheduleNotification(date: NSDate) {
        let settings = AppDelegate.delegate().settings
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.alertBody = settings.reminderText
        notification.timeZone = NSTimeZone.systemTimeZone()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.category = Constants.NotificationCategory
        // this is the trick - we just set a daily repetition
        // othewise 64 reminders is the most we can schedule
        notification.repeatInterval = NSCalendarUnit.Day
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    // MARK: Conversion methods
    func startTimeAsDate() -> NSDate {
        let nowTime = NSDate()
        return nowTime.hourAsDate(AppDelegate.delegate().settings.startTime)
    }
    
    func endTimeAsDate() -> NSDate {
        let nowTime = NSDate()
        return nowTime.hourAsDate(AppDelegate.delegate().settings.stopTime)
    }
    
    // note that the returned date can only be used for hour and minute. 
    // calendar date might be the next day.
    func nextReminderToday() -> NSDate? {
        let now = NSDate()
        for date in futureReminders {
            if !date.isBeforeHourToday(now) {
                return date
            }
        }
        return nil
    }
    func remindersRemainingToday() -> Int {
        let now = NSDate()
        for (index,date) in futureReminders.enumerate() {
            if !date.isBeforeHourToday(now) {
                return futureReminders.count - index
            }
        }
        return 0
    }
    // MARK: Model
    private func createReminderTimesForToday() -> [NSDate] {
        let nowTime = NSDate()
        let settings = AppDelegate.delegate().settings
        let startTime = startTimeAsDate()
        let endTime = endTimeAsDate()
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