//
//  Constants.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/9/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import Foundation

struct Constants {
    static let SmartTag = "SmartTag"
    static let SuperUnderlineStyle = "SuperUnderlineStyle-_-:)"
    static let NotificationCategory = "RECOGNITION_CATEGORY"
    static let TextInset = 25
    
    static let EditSettingsText = "Edit settings."
    
    static var timeFormat: NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle;
        formatter.dateStyle = .NoStyle;
        return formatter
    }
    static var DefaultReminderText = "Take 2-5 seconds to recognize that you exist. Let go of all thoughts."
    static var TextBaseSize : CGFloat = 34 // adjusted for screen size
    static let ActiveColor = UIColor.nkrReddishOrangeColor()
        
    static let MediumFont = "HelveticaNeue-Medium"
    static let BoldFont = "HelveticaNeue-Bold"
    static let RegularFont = "HelveticaNeue"
    static let LightFont = "HelveticaNeue-Light"

//    static let MediumFont = "SourceSansPro-Semibold"
//    static let ExtraHeavyFont = "SourceSansPro-Bold"
//    static let RegularFont = "SourceSansPro-Regular"
//    static let LightFont = "SourceSansPro-Light"

    
    //    static let ExtraLightFont = "HelveticaNeue-Thin"

    //68 68 68
    static let GreyTextColor = UIColor(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 1.0)
    static let BlackTextColor = UIColor.blackColor()

}