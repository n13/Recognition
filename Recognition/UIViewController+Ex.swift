//
//  UIViewController+Ex.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/25/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import Foundation

extension UIViewController {
    func takeScreenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.mainScreen().scale)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func addCancelButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(UIViewController.cancelButtonPressed))
    }
    
    func cancelButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}