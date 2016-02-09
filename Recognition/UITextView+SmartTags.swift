//
//  UITextView+SmartTags.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/8/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import UIKit

// text view with operations based on smart tags.
extension UITextView {
    
    func tagForLocation(point: CGPoint) -> String? {
        // Location of the tap in text-container coordinates
        var location = point
        location.x -= self.textContainerInset.left
        location.y -= self.textContainerInset.top
        
        // Find the character that's been tapped on
        let characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if (characterIndex < self.textStorage.length) {
            var range = NSRange(location: 0, length: 1)
            let value = self.attributedText.attribute(Constants.SmartTag, atIndex:characterIndex, effectiveRange:&range)
            
            if let _ = value {
                return value as? String
            }
            print("value: \(value)")
        }
        return nil
    }
    
    func replaceTaggedText(tag: String, replacementText: String) {
        let totalRange = NSRange(location: 0, length: self.attributedText.length)
        var foundRange = NSRange(location: 0, length: 1)
        for i in 0..<attributedText.length {
            let aTag = attributedText.attribute(Constants.SmartTag, atIndex: i, longestEffectiveRange: &foundRange, inRange: totalRange) as? String
            if aTag == tag {
                let mutableText = NSMutableAttributedString(attributedString: attributedText)
                let replacementString = NSAttributedString(string: replacementText, attributes: [Constants.SmartTag:tag])
                mutableText.replaceCharactersInRange(foundRange, withAttributedString: replacementString)
                self.attributedText = mutableText
            }
        }
    }
    
    
}