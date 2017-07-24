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
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func addCancelButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(UIViewController.cancelButtonPressed))
    }
    
    func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
