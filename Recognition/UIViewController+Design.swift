//
//  UIViewController+Design.swift
//  Recognition
//
//  Created by Nikolaus Heger on 5/8/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import SnapKit

extension UIViewController {
    
    // Create header text label and underline view, and the done button
    func createHeaderViews(_ theView: UIView, titleText: String, doneButtonText: String, doneButtonAction: Selector)
        -> (headerLabel: UILabel, underline: UIView, doneLabel: UILabel)
    {
        // top label
        let headerInset = 15
        let headerLabel = UILabel()
        headerLabel.numberOfLines = 0
        headerLabel.attributedText = NSMutableAttributedString.mm_attributedString(
            titleText,
            sizeAdjustment: 6,
            isBold: true,
            kerning: -0.6,
            color: Constants.GreyTextColor,
            lineHeightMultiple: 0.8)
        theView.addSubview(headerLabel)
        headerLabel.snp_makeConstraints { make in
            make.top.equalTo(46) // topLayoutGuide.length seems 0...
            make.leading.equalTo(headerInset)
            make.trailing.equalTo(-headerInset)
        }
        headerLabel.backgroundColor = UIColor.clear
                
        // done button
        let doneLabel = UILabel()
        doneLabel.isUserInteractionEnabled = true
        doneLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: doneButtonAction))
        
        doneLabel.attributedText = NSMutableAttributedString.mm_attributedString(
            doneButtonText,
            sizeAdjustment: 0,
            isBold: true,
            kerning: -0.6,
            color: Constants.ActiveColor,
            lineHeightMultiple: 0.8)
        theView.addSubview(doneLabel)
        doneLabel.snp_makeConstraints { make in
            make.baseline.equalTo(headerLabel.snp_baseline) // topLayoutGuide.length seems 0...
            make.trailing.equalTo(-headerInset)
        }
        
        // line view
        let line = DashedLineView()
        theView.addSubview(line)
        line.dashShape.strokeColor = UIColor.nkrPaleSalmonColor().withAlphaComponent(0.9).cgColor
        line.dashShape.lineWidth = 2
        line.snp_makeConstraints { make in
            make.top.equalTo(headerLabel.snp_baseline).offset(18) // topLayoutGuide.length seems 0...
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
        }

        return (headerLabel:headerLabel, underline: line, doneLabel: doneLabel)
    }
    
}
