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
        super.init(frame: CGRectZero)
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor.clearColor()
        dashShape.strokeColor = UIColor.whiteColor().CGColor
        dashShape.fillColor = nil
        //dashShape.lineDashPattern = [4, 4]
        self.layer.addSublayer(dashShape)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // make a line
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: self.bounds.width, y: 0))
        // update layer
        dashShape.path = path.CGPath
        dashShape.frame = self.bounds
    }
}
