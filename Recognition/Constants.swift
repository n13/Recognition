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

    static var timeFormat: NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle;
        formatter.dateStyle = .NoStyle;
        return formatter
    }
    
    static var TextBaseSize : CGFloat = 30 // adjusted for screen size

    //144 19 254
    static let PurpleColor = UIColor(red: 144.0/255, green: 19.0/255, blue: 254.0/255, alpha: 1.0)
    
    //68 68 68
    static let GreyTextColor = UIColor(red: 68.0/255, green: 68.0/255, blue: 68.0/255, alpha: 1.0)

}