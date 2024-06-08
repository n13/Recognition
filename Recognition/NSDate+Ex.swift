//
//  NSDate+Ex.swift
//  Recognition
//
//  Created by Nikolaus Heger on 11/19/15.
//  Copyright © 2015 Nikolaus Heger. All rights reserved.
//

import Foundation

extension Date {
    func toLocalString() -> String {
        return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .medium)
    }
    
    func isBeforeHourToday(_ otherDate: Date) -> Bool {
        if self.hour == otherDate.hour {
            return (self).minute < (otherDate).minute
        } else {
            return (self).hour < (otherDate).hour
        }
    }
    
    func asHoursAndMinutesFloat() -> Float {
        let aDate = self
        let hoursFloat: Float = Float(aDate.hour) + Float(aDate.minute) / 60.0
        print("hour float: hour: \(aDate.hour) minute: \(aDate.minute) float: \(hoursFloat)")
        return hoursFloat
    }
    
    func hourAsDate(_ hour0_24: Float) -> Date {
        let nowTime = Date()
        let hour = Int(hour0_24)
        let minute: Int = Int(60.0 * (hour0_24 - Float(hour)))
        return Date(year: (nowTime).year, month: (nowTime).month, day: (nowTime).day, hour: hour, minute: minute, second: 0) as Date
    }
    
    static func hourAsDateToday(_ hour0_24: Float) -> Date {
        return Date().hourAsDate(hour0_24)
    }
    
    func asHoursString() -> String {
        var ns = Constants.timeFormat.string(from: self).lowercased() as NSString
        if ns.hasSuffix(" am") {
            ns = ns.substring(to: ns.length-3) as NSString
            ns = "\(ns)" + "am" as NSString
        }
        if ns.hasSuffix(" pm") {
            ns = ns.substring(to: ns.length-3) as NSString
            ns = "\(ns)" + "pm" as NSString
        }
        return ns as String
    }
    
    
}
