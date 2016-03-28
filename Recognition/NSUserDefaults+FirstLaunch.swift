//
//  NSUserDefaults+FirstLaunch.swift
//  Recognition
//
//  Created by Nikolaus Heger on 3/28/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import Foundation

extension NSUserDefaults {
    // check for is first launch - only true on first invocation after app install, false on all further invocations
    static func isFirstLaunch() -> Bool {
        let firstLaunchFlag = "FirstLaunchFlag"
        let isFirstLaunch = NSUserDefaults.standardUserDefaults().stringForKey(firstLaunchFlag) == nil
        if (isFirstLaunch) {
            NSUserDefaults.standardUserDefaults().setObject("false", forKey: firstLaunchFlag)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        return isFirstLaunch
    }
}