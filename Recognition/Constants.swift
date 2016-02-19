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
    
    static var TextBaseSize : CGFloat = 34 // adjusted for screen size

    //144 19 254
     // static let PurpleColor = UIColor(red: 144.0/255, green: 19.0/255, blue: 254.0/255, alpha: 1.0)
    // 28	164	243
    //static let PurpleColor = UIColor(red: 28.0/255, green: 164.0/255, blue: 243.0/255, alpha: 1.0)
    //static let PurpleColor = UIColor(red: 0, green: 191/255, blue: 255, alpha: 1.0) // sky blue
    //static let PurpleColor = UIColor.magentaColor() // pink
    //static let PurpleColor = UIColor(red: 32/255, green: 222/255, blue: 223/255, alpha: 1.0)

    //  42	242	243
    // 11	49	245	
    //static let PurpleColor = UIColor(red: 11/255, green: 49/255, blue: 245/255, alpha: 1.0)
    //static let PurpleColor = UIColor(red: 218/255, green: 165/255, blue: 32/255, alpha: 1.0)
    // 255	85	3 intense rose gold sRGB
    //static let PurpleColor = UIColor(red: 255/255, green: 85/255, blue: 3/255, alpha: 1.0) //
    // 252	85	31  intense rose gold generic RGB
    //static let PurpleColor = UIColor(red: 252/255, green: 85/255, blue: 31/255, alpha: 1.0) //
    static let PurpleColor = UIColor(red: 255/255, green: 85/255, blue: 31/255, alpha: 1.0) // nik...

    
    //251	62	9 intense rose gold
    
    static let HeavyFont = "HelveticaNeue-Medium" // "HelveticaNeue-Bold"
    static let LightFont = "HelveticaNeue"

    //68 68 68
    static let GreyTextColor = UIColor(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 1.0)

}