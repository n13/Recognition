//
//  NSObject+Notifications.swift
//  Recognition
//
//  Created by Nikolaus Heger on 3/28/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import Foundation

extension NSObject {
    
    func addObserverForNotification(_ name: String, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
    }
    
    func removeObserverForNotification(_ name: String) {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: name), object: nil)
    }
    
    func postNotification(_ name: String) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: self, userInfo: nil)
    }
}
