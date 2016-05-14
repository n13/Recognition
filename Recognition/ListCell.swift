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
            make.edges.equalTo(self.contentView).inset(UIEdgeInsets(top: 20, left: Constants.TextInset, bottom: 20, right: Constants.TextInset))
        }
        let line = DashedLineView()
        line.placeBelowView(label)
        line.clipsToBounds = true
        line.snp_remakeConstraints { make in
            make.top.equalTo(label.snp_bottom).offset(18)
            make.left.equalTo(label.snp_left)
            make.right.equalTo(label.snp_right)
            make.height.equalTo(2)
        }
    }
    
    func setData(text: String) {
        let t = NSMutableAttributedString()
        t.appendClickableText(text, tag: "", dottedLine: false, fullWidthUnderline: false, lineHeightMultiple:0.9)
        label.attributedText = t
    }
}
