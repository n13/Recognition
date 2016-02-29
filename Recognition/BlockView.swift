//
//  BlockView.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/26/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import SnapKit

class BlockView: UIView {
    
    var numberLabel = UILabel()
    var textLabel = UILabel()
    var labelOnLeft = false {
        didSet {
            setup()
        }
    }
    var inset = 0
    
    init() {
        super.init(frame: CGRectZero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setNumberText(text: String) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Right
        
        let attributes: [String:AnyObject] = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 50)!,
            NSKernAttributeName: -3.0,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        
        let s = NSMutableAttributedString(string: text.lowercaseString, attributes: attributes)
        
        numberLabel.attributedText = s
    }
    
    func setLabelText(text: String) {
        textLabel.text = text
    }
    
    func setup() {
        numberLabel.font = UIFont(name: Constants.LightFont, size: 50)
        textLabel.font = UIFont(name: Constants.LightFont, size: 20)
        addSubview(numberLabel)
        addSubview(textLabel)
        
        if (!labelOnLeft) {
            textLabel.snp_remakeConstraints{ make in
                make.left.equalTo(60)
                make.baseline.equalTo(0)
            }
            numberLabel.snp_remakeConstraints { make in
                make.right.equalTo(textLabel.snp_left).offset(-10)
                make.baseline.equalTo(0)
            }
        } else {
            textLabel.snp_remakeConstraints{ make in
                make.leading.equalTo(inset)
                make.baseline.equalTo(0)
            }
            numberLabel.snp_remakeConstraints { make in
                make.leading.equalTo(textLabel.snp_trailing).offset(10)
                make.baseline.equalTo(0)
            }

        }
    }
}
