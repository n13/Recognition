//
//  ButtonView.swift
//  Recognition
//
//  Created by Nikolaus Heger on 3/14/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import UIKit

class ButtonView: UIView {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var lineView: DashedLineView!
    
    
    func setText(s: String) {
        titleLabel.font = UIFont(name: Constants.BoldFont, size: 20)
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.text = s
    }
    
    override func intrinsicContentSize() -> CGSize {
        let labelSize = titleLabel.intrinsicContentSize()
        let buttonSize = rightArrow.intrinsicContentSize()
        return CGSize(width: labelSize.width + 10 + buttonSize.width, height: max(labelSize.height, buttonSize.height))
    }
}
