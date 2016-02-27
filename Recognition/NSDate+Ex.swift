//
//  NSDate+Ex.swift
//  Recognition
//
//  Created by Nikolaus Heger on 11/19/15.
//  Copyright © 2015 Nikolaus Heger. All rights reserved.
//

import Foundation

extension NSDate {
    func toLocalString() -> String {
        return NSDateFormatter.localizedStringFromDate(self, dateStyle: .MediumStyle, timeStyle: .MediumStyle)
    }
    
    func isBeforeHourToday(otherDate: NSDate) -> Bool {
        if self.hour() == otherDate.hour() {
            return self.minute() < otherDate.minute()
        } else {
            return self.hour() < otherDate.hour()
        }
    }
    
    func asHoursAndMinutesFloat() -> Float {
        let hoursFloat: Float = Float(hour()) + Float(minute()) / 60.0
        print("hour float: hour: \(hour()) minute: \(minute()) float: \(hoursFloat)")
        return hoursFloat
    }
    
    func hourAsDate(hour0_24: Float) -> NSDate {
        let nowTime = NSDate()
        let hour = Int(hour0_24)
        let minute: Int = Int(60.0 * (hour0_24 - Float(hour)))
        return NSDate(year: nowTime.year(), month: nowTime.month(), day: nowTime.day(), hour: hour, minute: minute, second: 0)
    }
    
    static func hourAsDateToday(hour0_24: Float) -> NSDate {
        return NSDate().hourAsDate(hour0_24)
    }
    
    func asHoursString() -> String {
        return Constants.timeFormat.stringFromDate(self)
    }
    
    
}