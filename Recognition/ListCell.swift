//
//  ListCell.swift
//  Recognition
//
//  Created by Nikolaus Heger on 5/4/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

class ListCell: BaseTableViewCell {
    
    var label = UILabel()
        
    override func customSetup() {
        label.numberOfLines = 0
        self.contentView.addSubview(label)
        label.snp_makeConstraints { make in
            make.edges.equalTo(self.contentView).inset(UIEdgeInsets(top: 10, left: Constants.TextInset, bottom: 10, right: Constants.TextInset))
        }
        DashedLineView().placeBelowView(label)
    }
    
    func setData(text: String) {
        let t = NSMutableAttributedString()
        t.appendClickableText(text, tag: "", dottedLine: false, fullWidthUnderline: false, lineHeightMultiple:0.9)
        label.attributedText = t
    }
}
