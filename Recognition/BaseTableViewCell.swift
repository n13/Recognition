//
//  BaseTableViewCell.swift
//  Recognition
//
//  Created by Nikolaus Heger on 5/8/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

class BaseTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        customSetup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        customSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customSetup()
    }
    
    // this will get called at init, override to do custom setup
    func customSetup() {
        
    }
}