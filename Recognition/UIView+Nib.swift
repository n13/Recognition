//
//  UIView+Nib.swift
//  Recognition
//
//  Created by Nikolaus Heger on 3/16/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import Foundation
extension UIView {
    class func fromNib<T : UIView>(nibNameOrNil: String? = nil) -> T {
        let v: T? = fromNib2(nibNameOrNil)
        return v!
    }
    
    class func fromNib2<T : UIView>(nibNameOrNil: String? = nil) -> T? {
        var view: T?
        let name: String
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name = "\(T.self)".componentsSeparatedByString(".").last!
        }
        let nibViews = NSBundle.mainBundle().loadNibNamed(name, owner: nil, options: nil)
        for v in nibViews! {
            if let tog = v as? T {
                view = tog
            }
        }
        return view
    }
}
