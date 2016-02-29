//
//  UITextView+Ex.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/29/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import Foundation

extension UITextView {
    
    static func createCustomTextView() -> UITextView {
        
        // 1. Create the text storage that backs the editor
        let textStorage = NSTextStorage()
        let newTextViewRect = CGRect(x: 0, y: 0, width: 200, height: 200)
        
        // 2. Create the layout manager
        let layoutManager = UnderlineLayoutManager()
        
        // 3. Create a text container
        let containerSize = CGSize(width: newTextViewRect.width, height: CGFloat.max)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true
        layoutManager.addTextContainer(container)
        textStorage.addLayoutManager(layoutManager)
        
        let textView = UITextView(frame: newTextViewRect, textContainer: container)
        
        // make this work in a scroll view
        textView.editable = false
        textView.scrollEnabled = false
        textView.selectable = false
        
        // compensate for iOS text offset of 15, 15
        //textView.contentInset = UIEdgeInsets(top: -15, left: -5, bottom: -8, right: -8)
        textView.textContainerInset = UIEdgeInsetsMake(0,0,0,0)
        textView.textContainer.lineFragmentPadding = 0
        
        return textView
    }

}
