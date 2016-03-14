//
//  UIFont+Ex.swift
//  Recognition
//
//  Created by Nikolaus Heger on 3/14/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import Foundation

extension UIFont {
    
    static func listFonts() {
        for familyName:AnyObject in UIFont.familyNames().sort() {
            print("Family Name: \(familyName)")
            for fontName:AnyObject in UIFont.fontNamesForFamilyName(familyName as! String).sort() {
                print("--Font Name: \(fontName)")
            }
        }
    }
}