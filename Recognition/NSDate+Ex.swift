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
}