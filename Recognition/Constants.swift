//
//  Constants.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/9/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import Foundation

struct Constants {
    
    // Notifications
    static let LocalNotificationArrived = "LocalNotificationArrived"
    
    static let UserAnsweredNotificationsDialog = "UserAnsweredNotificationsDialog"

    static let SmartTag = NSAttributedStringKey("SmartTag")
    static let SuperUnderlineStyle = NSAttributedStringKey("SuperUnderlineStyle-_-:)")
    static let NotificationCategory = "RECOGNITION_CATEGORY"
    static let TextInset: CGFloat = 25
    
    static let isSmallDevice = (UIScreen.main.bounds.width <= 320)
    
    static let HomeBaseSize:CGFloat = isSmallDevice ? 26 : 32 // adjusted for screen size
    static let OnOffButtonSize:CGFloat = HomeBaseSize + 2
    static var TextBaseSize : CGFloat = HomeBaseSize + 2

    static let EditSettingsText = "Edit settings."
    
    static var timeFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short;
        formatter.dateStyle = .none;
        return formatter
    }
    static var DefaultReminderText = "Take 2-5 seconds to let go of all thoughts. Recognize that you exist."
    
    
    static let ActiveColor = UIColor.nkrReddishOrangeColor()
        
    static let MediumFont = "HelveticaNeue-Medium"
    static let BoldFont = "HelveticaNeue-Bold"
    static let RegularFont = "HelveticaNeue"
    static let LightFont = "HelveticaNeue-Light"
    
    static let ShortTextHeight = 40
    
    static func isIpad() -> Bool {
        let model = UIDevice.current.model
        return model.lowercased().contains("ipad")
    }
//    static let MediumFont = "SourceSansPro-Semibold"
//    static let ExtraHeavyFont = "SourceSansPro-Bold"
//    static let RegularFont = "SourceSansPro-Regular"
//    static let LightFont = "SourceSansPro-Light"

    
    //    static let ExtraLightFont = "HelveticaNeue-Thin"

    //68 68 68
    static let GreyTextColor = UIColor(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 1.0)
    static let BlackTextColor = UIColor.black

}
