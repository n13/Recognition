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
    }
    
    var startTime:Float = 8.0
    var stopTime:Float = 21.0
    var intervalMin: Float = 30
    var intervalMax: Float = 90
    var remindersPerDay: Int = 12
    
    var running: Bool {
        get {
            // note: returns false if it's not running
            return NSUserDefaults.standardUserDefaults().boolForKey(Keys.IsRunning)
        }
        set(value) {
            NSUserDefaults.standardUserDefaults().setBool(value, forKey: Keys.IsRunning)
        }
    }
}