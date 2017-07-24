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
        for familyName:String in UIFont.familyNames.sorted() {
            print("Family Name: \(familyName)")
            for fontName in UIFont.fontNames(forFamilyName: familyName).sorted() {
                print("--Font Name: \(fontName)")
            }
        }
    }
}
