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
        style.tabStops = [NSTextTab(textAlignment: NSTextAlignment.Left, location: 85, options: [:])]
        style.lineHeightMultiple = 0.95
        style.headIndent = 0
        style.firstLineHeadIndent = 0
        return style
    }
    
    func appendText(text: String,
        sizeAdjustment: CGFloat = 0.0,
        isBold:Bool=false,
        kerning: CGFloat = -1.0,
        color: UIColor = Constants.GreyTextColor,
        lineHeightMultiple: CGFloat  = 1.0)
    {
        appendAttributedString(NSMutableAttributedString.mm_attributedString(text, sizeAdjustment: sizeAdjustment, isBold: isBold, kerning: kerning, color: color, lineHeightMultiple: lineHeightMultiple))
    }
    
    func appendClickableText(text: String,
        tag: String,
        dottedLine: Bool = true,
        fullWidthUnderline: Bool = false,
        sizeAdjustment: CGFloat = 0.0,
        lineHeightMultiple: CGFloat  = 1.0)
    {
        var underlineStyle = NSUnderlineStyle.StyleThick.rawValue
        if (dottedLine) {
            underlineStyle |= NSUnderlineStyle.PatternDot.rawValue
        }
        let m = NSMutableAttributedString.mm_attributedString(text, sizeAdjustment: sizeAdjustment, isBold: false, kerning: -1.0, color: Constants.PurpleColor, underlineStyle: underlineStyle, smartTag: tag, underlineLastLineOnly: fullWidthUnderline, lineHeightMultiple: lineHeightMultiple)
        appendAttributedString(m)
    }
    
    // construct attributed string with our specific style
    static func mm_attributedString(
        text: String,
        sizeAdjustment: CGFloat = 0.0,
        isBold:Bool=false,
        kerning: CGFloat = -1.0,
        color: UIColor = Constants.GreyTextColor,
        underlineStyle: Int = NSUnderlineStyle.StyleNone.rawValue,
        smartTag: String? = nil,
        underlineLastLineOnly: Bool = false,
        lineHeightMultiple: CGFloat  = 1.0
        ) -> NSAttributedString
    {
        let textSize = Constants.TextBaseSize+sizeAdjustment
        let font = UIFont(name: (isBold ? Constants.HeavyFont : Constants.LightFont), size: textSize)!
        
        let style:NSMutableParagraphStyle = NSMutableAttributedString.paragraphStyle.mutableCopy() as! NSMutableParagraphStyle
        style.lineHeightMultiple = lineHeightMultiple

//        if (sizeAdjustment>0.0) {
////            style.headIndent = 0
////            style.firstLineHeadIndent = 0
//            style.lineHeightMultiple = 0.8
//        }
        var attributes: [String:AnyObject] = [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName: style,
            NSKernAttributeName: kerning,
        ]
        if (smartTag != nil) {
            attributes[Constants.SmartTag] = smartTag
        }
        if (underlineLastLineOnly) {
            attributes[Constants.SuperUnderlineStyle] = true
        }
        if (underlineStyle != NSUnderlineStyle.StyleNone.rawValue) {
            attributes[NSUnderlineStyleAttributeName] = underlineStyle
        }

        return NSAttributedString(string: text, attributes: attributes)
    }
    
}

