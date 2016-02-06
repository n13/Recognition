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
    
}