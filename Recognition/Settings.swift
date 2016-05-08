//
//  Settings.swift
//  Recognition
//
//  Created by Nikolaus Heger on 12/7/15.
//  Copyright © 2015 Nikolaus Heger. All rights reserved.
//

import Foundation

class Settings {
    
    struct Keys {
        static let IsRunning = "isRunning"
        static let startTime = "startTime"
        static let stopTime = "stopTime"
        static let remindersPerDay = "remindersPerDay"
        static let reminderText = "reminderText"
        static let historyList = "historyList"
    }
    
    struct Notifications {
        static let SettingsChanged = "SettingsChanged"
    }
    
    var startTime:Float {
        get {
            return NSUserDefaults.standardUserDefaults().floatForKey(Keys.startTime)
        }
        set(value) {
            NSUserDefaults.standardUserDefaults().setFloat(value, forKey: Keys.startTime)
        }
    }
    var stopTime:Float {
        get {
            return NSUserDefaults.standardUserDefaults().floatForKey(Keys.stopTime)
        }
        set(value) {
            NSUserDefaults.standardUserDefaults().setFloat(value, forKey: Keys.stopTime)
        }
    }
    var remindersPerDay: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey(Keys.remindersPerDay)
        }
        set(value) {
            NSUserDefaults.standardUserDefaults().setInteger(value, forKey: Keys.remindersPerDay)
        }
    }
    var reminderText: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(Keys.reminderText)!
        }
        set(value) {
            NSUserDefaults.standardUserDefaults().setValue(value, forKey: Keys.reminderText)
        }
    }
    
    var history: HistoryList {
        get {
            let arr:[String] = NSUserDefaults.standardUserDefaults().arrayForKey(Keys.historyList) as! [String]
            return HistoryList(arr: arr)
        }
        set(value) {
            let arr = history.array
            print("setting history hist: \(arr)")
            NSUserDefaults.standardUserDefaults().setValue(arr, forKey: Keys.historyList)
        }
    }

    func setReminderAndUpdateHistory(text: String) {
        self.reminderText = text
        let h = self.history
        h.addItemToHistory(text)
        NSUserDefaults.standardUserDefaults().setValue(h.array, forKey: Keys.historyList)
        save()
    }
    
    func endTimeIsPlusOneDay() -> Bool {
        return startTime >= stopTime
    }
    
    func setupDefaults() {
        //print("setting defaults...")
        NSUserDefaults.standardUserDefaults().registerDefaults([
            Keys.startTime: Float(9.0),
            Keys.stopTime: Float(21.0),
            Keys.remindersPerDay: Int(12),
            Keys.reminderText: Constants.DefaultReminderText,
            Keys.historyList: [],
            Keys.IsRunning: true
            ])
    }
    
    var running: Bool {
        get {
            // note: returns false if it's not running
            return NSUserDefaults.standardUserDefaults().boolForKey(Keys.IsRunning)
        }
        set(value) {
            NSUserDefaults.standardUserDefaults().setBool(value, forKey: Keys.IsRunning)
        }
    }
    
    func save() {
        NSUserDefaults.standardUserDefaults().synchronize()
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(Notifications.SettingsChanged, object: nil)
    }
}