//
//  NSMutableAttributedString+Ex.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/15/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

extension NSMutableAttributedString {
    
    static var paragraphStyle: NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.tabStops = [NSTextTab(textAlignment: NSTextAlignment.left, location: 85, options: [:])]
        style.lineHeightMultiple = 0.95
        style.headIndent = 0
        style.firstLineHeadIndent = 0
        return style
    }
    
    func appendText(_ text: String,
        sizeAdjustment: CGFloat = 0.0,
        isBold:Bool=false,
        kerning: CGFloat = -1.0,
        color: UIColor = Constants.GreyTextColor,
        lineHeightMultiple: CGFloat  = 1.0)
    {
        append(NSMutableAttributedString.mm_attributedString(text, sizeAdjustment: sizeAdjustment, isBold: isBold, kerning: kerning, color: color, lineHeightMultiple: lineHeightMultiple))
    }
    
    func appendClickableText(_ text: String,
        tag: String,
        dottedLine: Bool = true,
        fullWidthUnderline: Bool = false,
        sizeAdjustment: CGFloat = 0.0,
        lineHeightMultiple: CGFloat  = 1.0)
    {
        var underlineStyle = NSUnderlineStyle.styleThick.rawValue
        if (dottedLine) {
            underlineStyle |= NSUnderlineStyle.patternDot.rawValue
        } else {
            underlineStyle = NSUnderlineStyle.styleNone.rawValue
        }
        let m = NSMutableAttributedString.mm_attributedString(text, sizeAdjustment: sizeAdjustment, isBold: false, kerning: -1.0, color: Constants.ActiveColor, underlineStyle: underlineStyle, smartTag: tag, underlineLastLineOnly: fullWidthUnderline, lineHeightMultiple: lineHeightMultiple)
        append(m)
    }
    
    // construct attributed string with our specific style
    static func mm_attributedString(
        _ text: String,
        sizeAdjustment: CGFloat = 0.0,
        isBold:Bool=false,
        kerning: CGFloat = -1.0,
        color: UIColor = Constants.GreyTextColor,
        underlineStyle: Int = NSUnderlineStyle.styleNone.rawValue,
        smartTag: String? = nil,
        underlineLastLineOnly: Bool = false,
        lineHeightMultiple: CGFloat  = 1.0
        ) -> NSMutableAttributedString
    {
        let textSize = Constants.TextBaseSize+sizeAdjustment
        let font = UIFont(name: (isBold ? Constants.MediumFont : Constants.RegularFont), size: textSize)!
        
        let style:NSMutableParagraphStyle = NSMutableAttributedString.paragraphStyle.mutableCopy() as! NSMutableParagraphStyle
        style.lineHeightMultiple = lineHeightMultiple
        
//        if (sizeAdjustment>0.0) {
////            style.headIndent = 0
////            style.firstLineHeadIndent = 0
//            style.lineHeightMultiple = 0.8
//        }
        var attributes: [NSAttributedStringKey:Any] = [
            NSAttributedStringKey.font : font,
            NSAttributedStringKey.foregroundColor : color,
            NSAttributedStringKey.paragraphStyle: style,
            NSAttributedStringKey.kern: kerning,
        ]
        if (smartTag != nil) {
            attributes[Constants.SmartTag] = smartTag
        }
        if (underlineLastLineOnly) {
            attributes[Constants.SuperUnderlineStyle] = true
        }
        if (underlineStyle != NSUnderlineStyle.styleNone.rawValue) {
            attributes[NSAttributedStringKey.underlineStyle] = underlineStyle
        }

        return NSMutableAttributedString(string: text, attributes: attributes)
    }
    
    // create a spacer line
    // note: line height seems to be limited by a certain min and max value so need to play around with this
    static func spacerLine(_ lineHeightMultiple: CGFloat) -> NSMutableAttributedString {
        return NSMutableAttributedString.mm_attributedString("\n", lineHeightMultiple: lineHeightMultiple)
    }
    
    // apply an attribute over the entire range
    func applyAttribute(_ attributeName: NSAttributedStringKey, value: Any) {
        self.addAttribute(attributeName, value: value, range: NSRange(location: 0, length: self.length))
    }
    
}

