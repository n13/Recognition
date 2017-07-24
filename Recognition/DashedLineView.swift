//
//  DashedLineView.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/15/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

// view that's a single dashed line
class DashedLineView: UIView {
    
    let dashShape = CAShapeLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor.clear
        dashShape.strokeColor = Constants.ActiveColor.cgColor
        dashShape.lineWidth = 3
        //dashShape.lineDashPattern = [4, 4]
        self.layer.addSublayer(dashShape)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // make a line
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.bounds.width, y: 0))
        // update layer
        dashShape.path = path.cgPath
        dashShape.frame = self.bounds
    }
    
    func placeBelowView(_ viewToUnderline: UIView) {
        dashShape.strokeColor = Constants.ActiveColor.cgColor
        dashShape.lineWidth = 4
        viewToUnderline.superview!.addSubview(self)
        snp_makeConstraints { make in
            make.top.equalTo(viewToUnderline.snp_baseline).offset(15)
            make.left.equalTo(viewToUnderline.snp_left)
            make.right.equalTo(viewToUnderline.snp_right)
        }

    }
}
