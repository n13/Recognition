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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        /*
         // VERSION 1 - fat black text with underline and arrow
         titleLabel.font = UIFont(name: Constants.BoldFont, size: 17)
         titleLabel.textColor = UIColor.blackColor()
         titleLabel.text = s
         */

        // VERSION 2 - light text with box
        
//        self.snp_removeConstraints()
//        for v in self.subviews {
//            v.removeFromSuperview()
//            v.snp_removeConstraints()
//        }
//        
        titleLabel.font = UIFont(name: Constants.LightFont, size: 20)
        titleLabel.textColor = Constants.ActiveColor

        self.layer.borderWidth = 1
        self.layer.borderColor = Constants.ActiveColor.cgColor
        
        lineView.isHidden = true
//
//        
//        let packView = UIView()
//        self.addSubview(packView)
//        self.addSubview(button)
//        packView.addSubview(titleLabel)
//        packView.addSubview(rightArrow)
//        
//        titleLabel.snp_makeConstraints { make in
//            make.left.equalTo(0)
//            make.top.equalTo(0)
//            make.bottom.equalTo(0)
//            make.right.equalTo(rightArrow.snp_left).offset(5).priority(600)
//        }
//        rightArrow.snp_makeConstraints { make in
//            make.centerY.equalTo(titleLabel.snp_centerY)
//        }
//        packView.backgroundColor = UIColor.yellowColor()
//        
//        packView.snp_makeConstraints { make in
//            make.center.equalTo(0)
//            make.width.equalTo(200)
//        }
//        packView.setContentHuggingPriority(999, forAxis: .Horizontal)
//        
//        button.snp_makeConstraints { make in
//            make.edges.equalTo(0)
//        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let labelSize = titleLabel.intrinsicContentSize
        let arrowSize = rightArrow.intrinsicContentSize
                
        let padding:CGFloat = 15
        let x = self.bounds.width / 2.0 - (labelSize.width + padding + arrowSize.width) / 2.0
        
        titleLabel.frame = CGRect(x: x, y: titleLabel.frame.origin.y, width: titleLabel.frame.size.width, height: titleLabel.frame.size.height)
        rightArrow.frame = CGRect(x: x + titleLabel.frame.size.width + padding, y: rightArrow.frame.origin.y, width: rightArrow.frame.size.width, height: rightArrow.frame.size.height)
    }
    
    func setText(_ s: String) {
        titleLabel.text = s
        titleLabel.sizeToFit()
    }
 
    
    override var intrinsicContentSize : CGSize {
        let labelSize = titleLabel.intrinsicContentSize
        let buttonSize = rightArrow.intrinsicContentSize
        return CGSize(width: labelSize.width + 10 + buttonSize.width, height: max(33, max(labelSize.height, buttonSize.height)))
    }
}
