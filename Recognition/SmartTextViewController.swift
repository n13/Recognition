//
//  SmartTextViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/8/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//


import UIKit
import SnapKit

class SmartTextViewController: UIViewController, UIPickerViewDelegate, UITextViewDelegate {
    
    var scrollView = UIScrollView()
    var headerLabel: UILabel!
    var textView: UITextView!
    var reminderTextView: UITextView!
    var underline: DashedLineView!

    var offLabel: UILabel!
    var onLabel: UILabel!
    //var offStateTextView: UITextView!
    
    var textStorage: NSTextStorage!
    var onOffSwitch = UISwitch()
    let textInset = Constants.TextInset
    var textHeightConstraint : Constraint? = nil
    
    // MARK: View
    override func viewDidLoad() {
        
        // Title
        title = "Settings"
        
        // Done button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed:")
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName:Constants.ActiveColor], forState: .Normal)

        // switch in nav bar
        onOffSwitch.addTarget(self, action: "switchPressed:", forControlEvents: .ValueChanged)
        
        // UX
        setupViews()
        
        // Tap recognizer
        let tappy = UITapGestureRecognizer(target: self, action: "textTapped:")
        textView.addGestureRecognizer(tappy)
        //reminderTextView.addGestureRecognizer(tappy)
        offLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onOffTextTapped:"))
        onLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onOffTextTapped:"))
        
        // taps outside the text view need to release the focus
        let releaser = UITapGestureRecognizer(target: self, action: "releaseFirstResponder")
        view.addGestureRecognizer(releaser)

        reminderTextView.delegate = self
        
        // UX config
        runStateUpdated(false)
        handleSettingsChanged(nil)
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSettingsChanged:", name: Settings.Notifications.SettingsChanged, object: nil)
        
        self.pa_addKeyboardListeners()
        
    }
    
    override func pa_notificationKeyboardWillShow(notification: NSNotification) {
        self.moveScrollViewForKeyboard(scrollView, notification: notification, keyboardShowing: true)
    }
    
    func textViewDidChange(textView: UITextView) {
        scrollView.scrollRectToVisible(reminderTextView.frame, animated: true)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        let newText = reminderTextView.attributedText.string.pa_trim()
        print("new text: \(newText)")
        let settings = AppDelegate.delegate().settings
        settings.reminderText = newText
        settings.save()
        UIView.animateWithDuration(0.4) {
            self.underline.alpha = 1
        }
        reminderTextView.setNeedsLayout()
        underline.setNeedsLayout()

    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        UIView.animateWithDuration(0.4) {
            self.underline.alpha = 0
        }
    }
    override func pa_notificationKeyboardWillHide(notification: NSNotification) {
        self.moveScrollViewForKeyboard(scrollView, notification: notification, keyboardShowing: false)

    }

    func createCustomTextView() -> UITextView {
        
        // 1. Create the text storage that backs the editor
        textStorage = NSTextStorage()
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
        
        var textOffsetFromHeader = 40
        
        // For now just hide the header label and on off button - we don't need it here
        if ((self.navigationController) != nil) {
            headerLabel.hidden = true
            onLabel.hidden = true
            offLabel.hidden = true
            textOffsetFromHeader = -30
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
        reminderTextView = createCustomTextView()
        scrollView.addSubview(textView)
        scrollView.addSubview(reminderTextView)
        
        textView.snp_makeConstraints { make in
            make.top.equalTo(headerLabel.snp_baseline).offset(textOffsetFromHeader)
            make.leading.equalTo(scrollView.snp_leading).offset(textInset)
            make.trailing.equalTo(scrollView.snp_trailing).offset(-textInset)
            make.width.equalTo(view.snp_width).offset(-textInset*2)
            //make.bottom.equalTo(scrollView.snp_bottom)
            
            // text heigh constraint so we can shrink this view
            self.textHeightConstraint = make.height.lessThanOrEqualTo(CGFloat(1000)).constraint // DEBUG remove
        }
        reminderTextView.snp_makeConstraints { make in
            make.top.equalTo(textView.snp_bottom).offset(5)
            make.width.equalTo(textView.snp_width)
            make.left.equalTo(textView.snp_left)
            make.bottom.equalTo(scrollView.snp_bottom)
        }
        reminderTextView.editable = true
        
        underline = DashedLineView()
        underline.placeBelowView(reminderTextView)

        
        // debug
        //        headerLabel.backgroundColor = UIColor.redColor()
        //        textView.backgroundColor = UIColor.greenColor()
//                reminderTextView.backgroundColor = UIColor.redColor()
        //        scrollView.backgroundColor = UIColor.orangeColor()
        //        separatorView.backgroundColor = UIColor.magentaColor()
    }
    
    
    override func viewDidLayoutSubviews() {
//        print("text frame: \(textView.frame)")
//        print("view: \(view.performSelector("recursiveDescription"))")
    }
    
    // MARK: Actions
    func handleSettingsChanged(notification: NSNotification?) {
        print("handle settings changed")
        textView.attributedText = createText()
        reminderTextView.attributedText = createReminderText()
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
        
        offLabel.setNeedsLayout()
        
        self.view.layoutIfNeeded()
        
        // hiding - it works, but not really cool
        
        //        if (animated) {
        //            let foo = UIViewAnimationOptions.TransitionCurlUp.rawValue | UIViewAnimationOptions.ShowHideTransitionViews.rawValue
        //
        //            UIView.transitionFromView(
        //                running() ? offStateTextView : textView,
        //                toView: running() ? textView : offStateTextView,
        //                duration: 0.5,
        //                options: UIViewAnimationOptions(rawValue: foo),
        //                completion: nil)
        //        } else {
        //            offStateTextView.hidden = running()
        //            textView.hidden = !offStateTextView.hidden
        //        }
        
        //        offStateTextView.hidden = running()
        
        
        print("ATTRTEXT \(textView.attributedText)")
        self.textHeightConstraint!.updateOffset(CGFloat(self.running() ? 1000 : 0))
        if (animated) {
            UIView.animateWithDuration(0.4) {
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
    
    func createReminderText() -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString()
        
        attributedText.appendClickableText(AppDelegate.delegate().settings.reminderText, tag: Tag.ReminderText, dottedLine: false, fullWidthUnderline: false, lineHeightMultiple:0.9)
        attributedText.appendText("\n")
        
        return attributedText
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
        
        attributedText.appendText("\n\ntelling me to", lineHeightMultiple:1.15)
        
        return attributedText
        
    }
    
    func createOnOffText(isOnLabel: Bool) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString()
        let sizeAdjustment: CGFloat = 0
        //        attributedText.appendText("reminders are ", sizeAdjustment: sizeAdjustment, color: UIColor.lightGrayColor())
        //attributedText.appendClickableText(running() ? "on" : "off", tag: Tag.ToggleOnOff, sizeAdjustment: sizeAdjustment)
        attributedText.appendText((isOnLabel) ? "on" : "off", sizeAdjustment: sizeAdjustment, color: Constants.ActiveColor)
        
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
            let value = textView.attributedText.attribute(Constants.SmartTag, atIndex:characterIndex, effectiveRange:&range) as! String?
            print("value: \(value)")
            
            if let value = value {
                switch value {
                case Tag.StartTime:
                    showTimeControl(Tag.StartTime, text: "From", time: ReminderEngine.reminderEngine.startTimeAsDate())
                    break
                    
                case Tag.EndTime:
                    showTimeControl(Tag.EndTime, text: "To:", time: ReminderEngine.reminderEngine.endTimeAsDate())
                    break
                    
                default:
                    releaseFirstResponder()
                    break
                    
                    
                }
            }
        }
        releaseFirstResponder()
    }
    
    func releaseFirstResponder() {
        if (self.reminderTextView.isFirstResponder()) {
            self.reminderTextView.resignFirstResponder()
        }
    }

    func showTimeControl(tag: String, text: String, time: NSDate) {
        let picker = ActionSheetDatePicker(
            title: text,
            datePickerMode: UIDatePickerMode.Time,
            selectedDate: time,
            doneBlock: { picker, selectedDate, origin in
                print("\(selectedDate)")
                let settings = AppDelegate.delegate().settings
                let date = selectedDate as! NSDate
                let f = date.asHoursAndMinutesFloat()
                
                if (tag == Tag.StartTime) {
                    print("setting start time")
                    settings.startTime = f
                } else {
                    settings.stopTime = f
                }
                settings.save()
            },
            cancelBlock: { picker in
            },
            origin: self.view)
        
        picker.minuteInterval = 30
        
        picker.showActionSheetPicker()
    }
    
    func pickerChanged(sender: UIDatePicker) {
        print("picker changed to \(sender.date)")
    }
    
    
}


