//
//  SmartTextViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/8/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//


import UIKit
import SnapKit

class SmartTextViewController: UIViewController {
    
    var scrollView = UIScrollView()
    var headerLabel: UILabel!
    var textView: UITextView!
    var offLabel: UILabel!
    var onLabel: UILabel!
    var offStateTextView: UITextView!
    
    var textStorage: NSTextStorage!
    var onOffSwitch = UISwitch()
    let textInset = 25
    var textHeightConstraint : Constraint? = nil

    // MARK: View
    override func viewDidLoad() {
        
        // Title
        title = "Recognition"
        
        // Info button
        let infoButton = UIButton(type: .InfoLight)
        infoButton.addTarget(self, action: "InfoButtonPressed:", forControlEvents: .TouchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
        
        // switch in nav bar
        onOffSwitch.addTarget(self, action: "switchPressed:", forControlEvents: .ValueChanged)
        
        // UX
        setupViews()
      
        // Tap recognizer
        let tappy = UITapGestureRecognizer(target: self, action: "textTapped:")
        textView.addGestureRecognizer(tappy)
        offLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onOffTextTapped:"))
        onLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onOffTextTapped:"))
        
        // Make sure the engine is on
        ReminderEngine.reminderEngine.initEngine()
        
        // UX config
        runStateUpdated(false)
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSettingsChanged:", name: Settings.Notifications.SettingsChanged, object: nil)

        
    }
    
    func createCustomTextView() -> UITextView {
        
        // 1. Create the text storage that backs the editor
        let attrString = createText()
        textStorage = NSTextStorage()
        textStorage.appendAttributedString(attrString)
        
        let newTextViewRect = view.bounds
        
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
        
        // compensate for iOS text offset of 15, 15
        //textView.contentInset = UIEdgeInsets(top: -15, left: -5, bottom: -8, right: -8)
        textView.textContainerInset = UIEdgeInsetsMake(0,0,0,0)
        textView.textContainer.lineFragmentPadding = 0

        return textView
    }
    
    // MARK: Text Rendering
    
    func setupViews() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        view.addSubview(scrollView)
        scrollView.snp_makeConstraints{ make in
            make.top.equalTo(0)
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        //print("topLayoutGuide.length \(topLayoutGuide)")
        
        scrollView.contentInset = UIEdgeInsets(top: 45, left: 0, bottom: 0, right: 0)
        
        // top label
        let headerInset = textInset - 10
        headerLabel = UILabel()
        headerLabel.numberOfLines = 0
        headerLabel.attributedText = NSMutableAttributedString.mm_attributedString("2-5 second\nmeditation", sizeAdjustment: 6, isBold: true, kerning: -0.6, color: Constants.GreyTextColor, lineHeightMultiple: 0.8)
        scrollView.addSubview(headerLabel)
        headerLabel.snp_makeConstraints { make in
            make.top.equalTo(0) // topLayoutGuide.length seems 0...
            make.leading.equalTo(headerInset)
            make.trailing.equalTo(-headerInset)
        }
        
        // On Off label
        offLabel = UILabel()
        offLabel.userInteractionEnabled = true
        scrollView.addSubview(offLabel)
        offLabel.snp_makeConstraints { make in
            make.baseline.equalTo(headerLabel.snp_baseline)
            make.right.equalTo(-headerInset)
        }
        
        onLabel = UILabel()
        onLabel.text = "Off"
        onLabel.userInteractionEnabled = true
        scrollView.addSubview(onLabel)
        onLabel.snp_makeConstraints { make in
            make.baseline.equalTo(headerLabel.snp_baseline)
            make.right.equalTo(offLabel.snp_left).offset(-1)
        }
        
        // separator
//        let separatorView = DashedLineView()
//        separatorView.dashShape.strokeColor = UIColor(red: 3.0/255, green: 3/255.0, blue: 3.0/255, alpha: 1).CGColor
//        separatorView.dashShape.lineWidth = 2
//        scrollView.addSubview(separatorView)
//        separatorView.snp_makeConstraints { make in
//            //make.top.equalTo(textView.snp_bottom).offset(15)
//            make.top.equalTo(headerLabel.snp_baseline).offset(22)
//            make.leading.equalTo(headerInset)
//            make.trailing.equalTo(-headerInset)
//            make.height.equalTo(separatorView.dashShape.lineWidth)
//        }

        // main text view
        textView = createCustomTextView()
        scrollView.addSubview(textView)
        
        textView.snp_makeConstraints { make in
            make.top.equalTo(headerLabel.snp_baseline).offset(40)
            make.leading.equalTo(scrollView.snp_leading).offset(textInset)
            make.trailing.equalTo(scrollView.snp_trailing).offset(-textInset)
            make.width.equalTo(view.snp_width).offset(-textInset*2)
            make.bottom.equalTo(scrollView.snp_bottom)

            // text heigh constraint so we can shrink this view
            self.textHeightConstraint = make.height.lessThanOrEqualTo(CGFloat(1000)).constraint
        }
        //textView.backgroundColor = UIColor.clearColor()
        
        
        
        offStateTextView = createCustomTextView()
        scrollView.insertSubview(offStateTextView, belowSubview:textView)
        
        offStateTextView.snp_makeConstraints { make in
            make.top.equalTo(headerLabel.snp_baseline).offset(40)
            make.leading.equalTo(scrollView.snp_leading).offset(textInset)
            make.trailing.equalTo(scrollView.snp_trailing).offset(-textInset)
            make.width.equalTo(view.snp_width).offset(-textInset*2)
            //make.bottom.equalTo(scrollView.snp_bottom)
            
            // text heigh constraint so we can shrink this view
            //self.textHeightConstraint = make.height.lessThanOrEqualTo(CGFloat(1000)).constraint
        }
        offStateTextView.attributedText = NSMutableAttributedString.mm_attributedString(
            "Reminders are off.",
            sizeAdjustment: 33,
            color: UIColor(white: 0.5, alpha: 0.3)
        )

        
        
        // on off label - OLD
        
        
        
        // debug
//        headerLabel.backgroundColor = UIColor.redColor()
//        textView.backgroundColor = UIColor.greenColor()
//        scrollView.backgroundColor = UIColor.orangeColor()
//        separatorView.backgroundColor = UIColor.magentaColor()
    }
    
    
    override func viewDidLayoutSubviews() {
        print("text frame: \(textView.frame)")
        print("view: \(view.performSelector("recursiveDescription"))")
    }
    
    // MARK: Actions
    func handleSettingsChanged(notification: NSNotification) {
        print("handle settings changed")
        textView.attributedText = createText()
    }
    
    @IBAction func InfoButtonPressed(sender: AnyObject) {
        showSettingsViewController()
    }
    
    @IBAction func switchPressed(sender: AnyObject) {
        if (onOffSwitch.on) {
            ReminderEngine.reminderEngine.start()
        } else {
            ReminderEngine.reminderEngine.stop()
        }
        runStateUpdated(true)
    }
    
    func running() -> Bool {
        return ReminderEngine.reminderEngine.isRunning
    }
    
    // MARK: UX
    func runStateUpdated(animated: Bool) {
        onOffSwitch.on = running()
        offLabel.attributedText = createOnOffText(false)
        onLabel.attributedText = createOnOffText(true)
        
        if running() {
            offLabel.alpha = 0.4
            onLabel.alpha = 1.0
        } else {
            offLabel.alpha = 1.0
            onLabel.alpha = 0.4
        }
        
        //onOffTextView.attributedText = createOnOffText()
        offLabel.setNeedsLayout()
        
        // abracadabra
        //textView.attributedText = self.createText()
        
        self.view.layoutIfNeeded()
        
        if (animated) {
            let foo = UIViewAnimationOptions.TransitionCrossDissolve.rawValue | UIViewAnimationOptions.ShowHideTransitionViews.rawValue
            
            UIView.transitionFromView(
                running() ? offStateTextView : textView,
                toView: running() ? textView : offStateTextView,
                duration: 0.5,
                options: UIViewAnimationOptions(rawValue: foo),
                completion: nil)
        } else {
            offStateTextView.hidden = running()
            textView.hidden = !offStateTextView.hidden
        }
        


//        self.textHeightConstraint!.updateOffset(CGFloat(running() ? 1000 : 0))
//        if (animated) {
//            UIView.animateWithDuration(0.4) {
//                self.view.layoutIfNeeded()
//            }
//        } else {
//        }
    }
    
    func showSettingsViewController() {
        let vc = SettingsViewController.createMain()
        let nc = UINavigationController(rootViewController: vc)
        nc.modalTransitionStyle = .FlipHorizontal
        presentViewController(nc, animated: true, completion: nil)
    }
    

    // MARK: Text Management - Should be in its own class
    struct Tag {
        static let NumberOfReminders = "#numberOfReminders"
        static let StartTime = "#startTime"
        static let EndTime = "#endTime"
        static let ReminderText = "#text"
        static let ToggleOnOff = "#OnOff"
    }
    
    func createText() -> NSMutableAttributedString {
        
        let attributedText = NSMutableAttributedString()
        
        let numReminders = "\(AppDelegate.delegate().settings.remindersPerDay) reminders"
        
        attributedText.appendText("schedule\n")
        attributedText.appendClickableText(numReminders, tag: Tag.NumberOfReminders, lineHeightMultiple: 0.85)
        attributedText.appendText("\nper day\n")
        attributedText.appendText("\n")
        
        attributedText.appendText("from\t")
        let startText = Constants.timeFormat.stringFromDate(ReminderEngine.reminderEngine.startTimeAsDate())
        attributedText.appendClickableText(startText, tag: Tag.StartTime)
        attributedText.appendText("\nto\t", lineHeightMultiple: 1.3)
        
        let endText = Constants.timeFormat.stringFromDate(ReminderEngine.reminderEngine.endTimeAsDate())
        attributedText.appendClickableText(endText, tag: Tag.EndTime, lineHeightMultiple: 1.3)

        attributedText.appendText("\n\ntelling me to\n", lineHeightMultiple:1.15)
        attributedText.appendText("\n", lineHeightMultiple:0.1)// tiny line
        attributedText.appendClickableText(AppDelegate.delegate().settings.reminderText, tag: Tag.ReminderText, dottedLine: false, fullWidthUnderline: true, lineHeightMultiple:0.9)
        attributedText.appendText("\n")
        
        return attributedText
        
    }
    
    func createOnOffText(isOnLabel: Bool) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString()
        let sizeAdjustment: CGFloat = 0
//        attributedText.appendText("reminders are ", sizeAdjustment: sizeAdjustment, color: UIColor.lightGrayColor())
        //attributedText.appendClickableText(running() ? "on" : "off", tag: Tag.ToggleOnOff, sizeAdjustment: sizeAdjustment)
        attributedText.appendText((isOnLabel) ? "on" : "off", sizeAdjustment: sizeAdjustment, color: Constants.PurpleColor)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Right

        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        
        return attributedText
    }
    

    
    // MARK: Handle taps
    
    func onOffTextTapped(recognizer: UITapGestureRecognizer) {
        print("on off")
        if (running()) {
            ReminderEngine.reminderEngine.stop()
        } else {
            ReminderEngine.reminderEngine.start()
        }
        runStateUpdated(true)
    }
    
    func textTapped(recognizer: UITapGestureRecognizer) {
        let textView = recognizer.view as! UITextView
        let layoutManager = textView.layoutManager
        
        // Location of the tap in text-container coordinates
        var location = recognizer.locationInView(textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        
        // Find the character that's been tapped on
        let characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        if (characterIndex < textView.textStorage.length) {
            var range = NSRange(location: 0, length: 1)
            let value = textView.attributedText.attribute(Constants.SmartTag, atIndex:characterIndex, effectiveRange:&range)
            print("value: \(value)")
            
            if (value != nil) {
                // for now just show settings
                showSettingsViewController()
            }
        }
        
        
    }
}


