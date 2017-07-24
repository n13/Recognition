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
        label.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView).inset(UIEdgeInsets(top: 20, left: Constants.TextInset, bottom: 20, right: Constants.TextInset))
        }
        let line = DashedLineView()
        line.placeBelowView(label)
        line.clipsToBounds = true
        line.snp.remakeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(18)
            make.left.equalTo(label.snp.left)
            make.right.equalTo(label.snp.right)
            make.height.equalTo(2)
        }
    }
    
    func setData(_ text: String) {
        let t = NSMutableAttributedString()
        t.appendClickableText(text, tag: "", dottedLine: false, fullWidthUnderline: false, lineHeightMultiple:0.9)
        label.attributedText = t
    }
}
