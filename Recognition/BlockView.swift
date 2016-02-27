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
    var labelOnLeft = true {
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
        numberLabel.text = text
    }
    
    func setLabelText(text: String) {
        textLabel.text = text
    }
    
    func setup() {
        numberLabel.font = UIFont(name: Constants.LightFont, size: 50)
        textLabel.font = UIFont(name: Constants.LightFont, size: 20)
        addSubview(numberLabel)
        addSubview(textLabel)
        
        let leftView = numberLabel
        let rightView = textLabel
        
        leftView.snp_remakeConstraints { make in
            make.leading.equalTo(inset)
            make.baseline.equalTo(0)
        }
        rightView.snp_remakeConstraints{ make in
            make.left.equalTo(leftView.snp_right).offset(10)
            make.baseline.equalTo(0)
        }
    }
}
