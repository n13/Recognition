//
//  MyLayoutManager.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/10/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import UIKit

class UnderlineLayoutManager : NSLayoutManager {    
    
    override func drawUnderline(
        forGlyphRange glyphRange: NSRange,
        underlineType underlineVal: NSUnderlineStyle,
        baselineOffset: CGFloat,
        lineFragmentRect lineRectParameter: CGRect,
        lineFragmentGlyphRange lineGlyphRange: NSRange,
        containerOrigin: CGPoint)
    {
        let dotted = (underlineVal.rawValue & NSUnderlineStyle.patternDot.rawValue) > 0
        
        var lineRect = lineRectParameter
        
        // get current UIFont for the glyphRange
        let characterRange = self.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        let superUnderlineAttribute = textStorage?.attribute(Constants.SuperUnderlineStyle, at: characterRange.location, effectiveRange: nil)
        
        // check the next line
        let superUnderline = superUnderlineAttribute != nil
        var skipUnderline = false
        
        // super underline mode follows these rules:
        // - only the last line is underlined if there are multiple super underlined lines
        // - the last line is underlined across the entire width of the text view
        if (superUnderline) {
            var nextLineIsUnderlined = false
            // peek at the next line
            let lineCharacterRange = self.characterRange(forGlyphRange: lineGlyphRange, actualGlyphRange: nil)
            let nextIndex = lineCharacterRange.location + lineCharacterRange.length
            let foo : NSString = textStorage!.string as NSString
            if (nextIndex < textStorage!.length) {
                let superUnderlineAttributeNextLine = textStorage?.attribute(Constants.SuperUnderlineStyle, at: nextIndex, effectiveRange: nil)
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
            let inset: CGFloat = 0
            lineRect.origin.x += inset
            lineRect.size.width -= inset*2
            lineRect.origin.y += 18

        } else {
            let firstPosition = location(forGlyphAt: glyphRange.location).x;
            var lastPosition: CGFloat
            if (NSMaxRange(glyphRange) < NSMaxRange(lineGlyphRange)) {
                lastPosition = location(forGlyphAt: NSMaxRange(glyphRange)).x;
            } else {
                lastPosition = lineFragmentUsedRect(forGlyphAt: NSMaxRange(glyphRange)-1, effectiveRange:nil).size.width;
            }
            // Offset line by container origin
            lineRect.origin.x += firstPosition
            lineRect.size.width = lastPosition - firstPosition
            
            let multiple = dashLength + gapLength
            let lineW = lineRect.size.width / multiple
            let roundedNum = ceil(lineW)
            
            lineRect.size.width = roundedNum * multiple
            
        }


        // construct the path
        let path = UIBezierPath()
        let y = lineRect.origin.y + lineRect.size.height - 1
        path.move(to: CGPoint(x: lineRect.origin.x, y: y))
        path.addLine(to: CGPoint(x: lineRect.origin.x + lineRect.size.width, y: y))

        // Line width
        path.lineWidth = 2.0
        
        if (dotted) {
            path.setLineDash(lengths, count: 2, phase: 0.0)
        }
        
        // Color
        Constants.ActiveColor.set()
        
        // draw path
        path.stroke()
        
    }

}
