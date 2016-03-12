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
    
    static var TextBaseSize : CGFloat = 34 // adjusted for screen size
    static let ActiveColor = UIColor.nkrReddishOrangeColor()
    
    //251	62	9 intense rose gold
    
    static let HeavyFont = "HelveticaNeue-Medium" // "HelveticaNeue-Bold" CondensedBlack CondensedBold
    static let ExtraHeavyFont = "HelveticaNeue-Bold" // "HelveticaNeue-Bold" CondensedBlack CondensedBold
    static let LightFont = "HelveticaNeue"
    static let ExtraLightFont = "HelveticaNeue-Thin"

    //68 68 68
    static let GreyTextColor = UIColor(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 1.0)
    static let BlackTextColor = UIColor.blackColor()

}