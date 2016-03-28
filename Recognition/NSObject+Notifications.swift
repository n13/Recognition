//
//  NSObject+Notifications.swift
//  Recognition
//
//  Created by Nikolaus Heger on 3/28/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import Foundation

extension NSObject {
    
    func addObserverForNotification(name: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: name, object: nil)
    }
    
    func removeObserverForNotification(name: String) {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: name, object: nil)
    }
    
    func postNotification(name: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: self, userInfo: nil)
    }
}