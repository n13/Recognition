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
        static let reminderSound = "reminderSound"
    }
    
    struct Notifications {
        static let SettingsChanged = "SettingsChanged"
    }
    
    
    var reminderSound:String {
        get {
            return UserDefaults.standard.string(forKey: Keys.reminderSound) ?? SoundValue.Default
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: Keys.reminderSound)
        }
    }
    
    var startTime:Float {
        get {
            return UserDefaults.standard.float(forKey: Keys.startTime)
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: Keys.startTime)
        }
    }
    var stopTime:Float {
        get {
            return UserDefaults.standard.float(forKey: Keys.stopTime)
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: Keys.stopTime)
        }
    }
    var remindersPerDay: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.remindersPerDay)
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: Keys.remindersPerDay)
        }
    }
    var reminderText: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.reminderText)!
        }
        set(value) {
            UserDefaults.standard.setValue(value, forKey: Keys.reminderText)
        }
    }
    
    var history: HistoryList {
        get {
            let arr:[String] = UserDefaults.standard.array(forKey: Keys.historyList) as! [String]
            return HistoryList(arr: arr)
        }
        set(value) {
            let arr = history.array
            print("setting history hist: \(arr)")
            UserDefaults.standard.setValue(arr, forKey: Keys.historyList)
        }
    }

    func setReminderAndUpdateHistory(_ text: String) {
        if (self.reminderText == text) {
            print("new text is the same as the old text - ignoring new text, history unchanged")
        } else {
            let previousText = self.reminderText
            let h = self.history
            if previousText != Constants.DefaultReminderText {
                h.addItemToHistory(previousText)                
            }
            h.removeItemFromHistory(text)
            self.reminderText = text
            UserDefaults.standard.setValue(h.array, forKey: Keys.historyList)
            save()
        }
    }
    
    func endTimeIsPlusOneDay() -> Bool {
        return startTime >= stopTime
    }
    
    func setupDefaults() {
        //print("setting defaults...")
        
        //print("removing history")
        //NSUserDefaults.standardUserDefaults().removeObjectForKey(Keys.historyList) // DEBUG don't check in
        
        UserDefaults.standard.register(defaults: [
            Keys.startTime: Float(9.0),
            Keys.stopTime: Float(21.0),
            Keys.remindersPerDay: Int(12),
            Keys.reminderText: Constants.DefaultReminderText,
            Keys.historyList: [],
            Keys.IsRunning: true,
            Keys.reminderSound: SoundValue.Default
            ])
    }
    
    var running: Bool {
        get {
            // note: returns false if it's not running
            return UserDefaults.standard.bool(forKey: Keys.IsRunning)
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: Keys.IsRunning)
        }
    }
    
    func save() {
        UserDefaults.standard.synchronize()
        let center = NotificationCenter.default
        center.post(name: Notification.Name(rawValue: Notifications.SettingsChanged), object: nil)
    }
}
