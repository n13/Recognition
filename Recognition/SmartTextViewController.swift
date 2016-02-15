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
    var textView: UITextView!
    var headerLabel: UILabel!
    var onOffTextView: UITextView!
    
    var textStorage: NSTextStorage!
    var onOffSwitch = UISwitch()
    
    static var timeFormat: NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle;
        formatter.dateStyle = .NoStyle;
        return formatter
    }
    
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
        onOffTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onOffTextTapped:"))
        
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
        
        // compensate for iOS text offset
        textView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)

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
        
        scrollView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        
        // top label
        headerLabel = UILabel()
        headerLabel.numberOfLines = 0
        headerLabel.attributedText = NSMutableAttributedString.mm_attributedString("2-5 second\nmeditation", sizeAdjustment: 6, isBold: true, kerning: -0.6, color: Constants.GreyTextColor)
        scrollView.addSubview(headerLabel)
        headerLabel.snp_makeConstraints { make in
            make.top.equalTo(0) // topLayoutGuide.length seems 0...
            make.leading.equalTo(textInset-10)
            make.trailing.equalTo(textInset-10)
        }
        
        // switch
        onOffSwitch.onTintColor = Constants.PurpleColor
        scrollView.addSubview(onOffSwitch)
        onOffSwitch.snp_makeConstraints { make in
            make.trailing.equalTo(scrollView.snp_trailingMargin)
            make.centerY.equalTo(headerLabel.snp_centerY)
        }
        onOffSwitch.hidden = true // DEBUG
        

        // main text view
        textView = createCustomTextView()
        scrollView.addSubview(textView)
        
        textView.snp_makeConstraints { make in
            make.top.equalTo(headerLabel.snp_baseline).offset(55) // for scroll view
            make.leading.equalTo(scrollView.snp_leading).offset(textInset)
            make.trailing.equalTo(scrollView.snp_trailing).offset(-textInset)
            make.width.equalTo(view.snp_width).offset(-textInset*2)
            self.textHeightConstraint = make.height.lessThanOrEqualTo(CGFloat(1000)).constraint
            //            make.bottom.equalTo(scrollView.snp_bottom)
        }
        
        // separator
        let separatorView = DashedLineView()
        separatorView.dashShape.strokeColor = UIColor.lightGrayColor().CGColor
        separatorView.dashShape.lineWidth = 1
        
        scrollView.addSubview(separatorView)
        separatorView.snp_makeConstraints { make in
            make.top.equalTo(textView.snp_bottom).offset(15)
            make.trailing.equalTo(-textInset)
            make.leading.equalTo(textInset)
            make.height.equalTo(separatorView.dashShape.lineWidth)
            //make.bottom.equalTo(scrollView.snp_bottom)
        }
        
        // on off label
        onOffTextView = createCustomTextView()
        onOffTextView.attributedText = createOnOffText()
        scrollView.addSubview(onOffTextView)
        onOffTextView.snp_makeConstraints { make in
            make.top.equalTo(separatorView)
            make.leading.equalTo(textInset)
            make.trailing.equalTo(-textInset)
            make.bottom.equalTo(scrollView.snp_bottom)
        }
        


        
        
        // debug
//        headerLabel.backgroundColor = UIColor.redColor()
//        textView.backgroundColor = UIColor.greenColor()
//        scrollView.backgroundColor = UIColor.orangeColor()
//        separatorView.backgroundColor = UIColor.magentaColor()
    }
    
    let textInset = 25
    var textHeightConstraint : Constraint? = nil

//    func changeMainTextConstraintsForRunning(running: Bool) {
//        textView.snp_removeConstraints()
//        textView.snp_remakeConstraints { make in
//            make.top.equalTo(headerLabel.snp_baseline).offset(55) // for scroll view
//            make.leading.equalTo(scrollView.snp_leading).offset(textInset)
//            make.trailing.equalTo(scrollView.snp_trailing).offset(-textInset)
//            make.width.equalTo(view.snp_width).offset(-textInset*2)
//            if (!running) {
//                make.height.equalTo(100)
//            }
//        }
//
//    }
    
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
        onOffTextView.attributedText = createOnOffText()
        
        // abracadabra
        //textView.attributedText = self.createText()
        
        self.view.layoutIfNeeded()

        self.textHeightConstraint!.updateOffset(CGFloat(running() ? 1000 : 0))
        if (animated) {
            UIView.animateWithDuration(0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
        }
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
        
//        if (!running()) {
//            attributedText.appendText(" ")
//            return attributedText
//        }
        
        let numReminders = "\(AppDelegate.delegate().settings.remindersPerDay) reminders"
        
        //appendText("2-5 second\nmeditation\n\n", sizeAdjustment: 6, isBold: true, kerning: -0.6, color: Constants.GreyTextColor)

        
        attributedText.appendText("schedule\n")
        attributedText.appendClickableText(numReminders, tag: Tag.NumberOfReminders)
        attributedText.appendText("\nper day\n")
        attributedText.appendText("\n")
        
        attributedText.appendText("from\t")
        let startText = Constants.timeFormat.stringFromDate(ReminderEngine.reminderEngine.startTimeAsDate())
        attributedText.appendClickableText(startText, tag: Tag.StartTime)
        attributedText.appendText("\nto\t")
        
        let endText = Constants.timeFormat.stringFromDate(ReminderEngine.reminderEngine.endTimeAsDate())
        attributedText.appendClickableText(endText, tag: Tag.EndTime)

        attributedText.appendText("\n\ntelling me to\n")
        attributedText.appendClickableText(AppDelegate.delegate().settings.reminderText, tag: Tag.ReminderText, dottedLine: false, fullWidthUnderline: true)
        attributedText.appendText("\n")
        
        return attributedText
        
    }
    
    func createOnOffText() -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString()
        let sizeAdjustment: CGFloat = -15
        attributedText.appendText("reminders are "+(running() ? "ON" : "OFF") + ". Turn them ", sizeAdjustment: sizeAdjustment, color: UIColor.darkGrayColor())
        attributedText.appendClickableText(running() ? "OFF." : "ON.", tag: Tag.ToggleOnOff, sizeAdjustment: sizeAdjustment)
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


