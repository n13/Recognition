//
//  String+Ex.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/28/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import Foundation
extension String {
    // all words in a string
    
    func pa_words() -> [String] {
        let s: NSString = self
        return s.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func pa_trim() -> String {
        let s: NSString = self
        return s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func isEmpty() -> Bool {
        let s: NSString = self
        return s.length == 0
    }

}