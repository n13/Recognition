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
        super.init(frame: CGRect.zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setNumberText(_ text: String) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.right
        
        let attributes: [String:AnyObject] = [
            NSFontAttributeName: UIFont(name:
                Constants.LightFont, size: 50)!,
            NSKernAttributeName: -3.0 as AnyObject,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        
        let s = NSMutableAttributedString(string: text.lowercased(), attributes: attributes)
        
        numberLabel.attributedText = s
    }
    
    func setLabelText(_ text: String) {
        textLabel.text = text
    }
    
    func setup() {
        numberLabel.font = UIFont(name: Constants.RegularFont, size: 50)
        textLabel.font = UIFont(name: Constants.RegularFont, size: 20)
        addSubview(numberLabel)
        addSubview(textLabel)
        
        if (!labelOnLeft) {
            textLabel.snp.remakeConstraints{ make in
                make.left.equalTo(60)
                make.lastBaseline.equalTo(0)
            }
            numberLabel.snp.remakeConstraints { make in
                make.right.equalTo(textLabel.snp.left).offset(-10)
                make.lastBaseline.equalTo(0)
            }
        } else {
            textLabel.snp.remakeConstraints{ make in
                make.leading.equalTo(inset)
                make.lastBaseline.equalTo(0)
            }
            numberLabel.snp.remakeConstraints { make in
                make.leading.equalTo(textLabel.snp.trailing).offset(10)
                make.lastBaseline.equalTo(0)
            }

        }
    }
}
