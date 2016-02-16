//
//  MyLayoutManager.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/10/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import UIKit

class UnderlineLayoutManager : NSLayoutManager {    
    
    override func drawUnderlineForGlyphRange(
        glyphRange: NSRange,
        underlineType underlineVal: NSUnderlineStyle,
        baselineOffset: CGFloat,
        var lineFragmentRect lineRect: CGRect,
        lineFragmentGlyphRange lineGlyphRange: NSRange,
        containerOrigin: CGPoint)
    {
        let dotted = (underlineVal.rawValue & NSUnderlineStyle.PatternDot.rawValue) > 0
        
        // get current UIFont for the glyphRange
        let characterRange = self.characterRangeForGlyphRange(glyphRange, actualGlyphRange: nil)
        let superUnderlineAttribute = textStorage?.attribute(Constants.SuperUnderlineStyle, atIndex: characterRange.location, effectiveRange: nil)
        
        // check the next line
        var superUnderline = superUnderlineAttribute != nil
        var skipUnderline = false
        
        // super underline mode follows these rules:
        // - only the last line is underlined if there are multiple super underlined lines
        // - the last line is underlined across the entire width of the text view
        if (superUnderline) {
            var nextLineIsUnderlined = false
            // peek at the next line
            let lineCharacterRange = self.characterRangeForGlyphRange(lineGlyphRange, actualGlyphRange: nil)
            let nextIndex = lineCharacterRange.location + lineCharacterRange.length
            let foo : NSString = textStorage!.string
            if (nextIndex < textStorage!.length) {
                let superUnderlineAttributeNextLine = textStorage?.attribute(Constants.SuperUnderlineStyle, atIndex: nextIndex, effectiveRange: nil)
                nextLineIsUnderlined = superUnderlineAttributeNextLine != nil
            }
            if nextLineIsUnderlined {
                skipUnderline = true
            }
        }
        if (skipUnderline) {
            return
        }
        
        let dashLength: CGFloat = 6
        let gapLength: CGFloat = 3
        let lengths:[CGFloat] = [dashLength, gapLength]
        
        // container offset
        lineRect.origin.x += containerOrigin.x;
        lineRect.origin.y += containerOrigin.y;

        if (superUnderline) {
            let inset: CGFloat = 15
            lineRect.origin.x += inset
            lineRect.size.width -= inset*2
            lineRect.origin.y += 10

        } else {
            let firstPosition = locationForGlyphAtIndex(glyphRange.location).x;
            var lastPosition: CGFloat
            if (NSMaxRange(glyphRange) < NSMaxRange(lineGlyphRange)) {
                lastPosition = locationForGlyphAtIndex(NSMaxRange(glyphRange)).x;
            } else {
                lastPosition = lineFragmentUsedRectForGlyphAtIndex(NSMaxRange(glyphRange)-1, effectiveRange:nil).size.width;
            }
            // Offset line by container origin
            lineRect.origin.x += firstPosition
            lineRect.size.width = lastPosition - firstPosition + 2
        }


        // construct the path
        var path = UIBezierPath()
        let y = lineRect.origin.y + lineRect.size.height
        path.moveToPoint(CGPoint(x: lineRect.origin.x, y: y))
        path.addLineToPoint(CGPoint(x: lineRect.origin.x + lineRect.size.width, y: y))

        // Line width
        path.lineWidth = 3.0
        
        if (dotted) {
            path.setLineDash(lengths, count: 2, phase: 0.0)
        }
        
        // Color
        Constants.PurpleColor.set()
        
        // draw path
        path.stroke()
        
    }

}