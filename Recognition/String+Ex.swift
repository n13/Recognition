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
        let s: NSString = self as NSString
        return s.components(separatedBy: CharacterSet.whitespacesAndNewlines)
    }
    
    func pa_trim() -> String {
        let s: NSString = self as NSString
        return s.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func isEmpty() -> Bool {
        let s: NSString = self as NSString
        return s.length == 0
    }

}
