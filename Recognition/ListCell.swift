//
//  ListCell.swift
//  Recognition
//
//  Created by Nikolaus Heger on 5/4/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

class ListCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!

    func setData(text: String) {
        let t = NSMutableAttributedString()
        
        t.appendText(text, sizeAdjustment: -10, isBold: false, kerning: 0.9, color: Constants.ActiveColor)
        
        label.attributedText = t
    }
}
