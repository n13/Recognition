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

    let textInset = Constants.TextInset
    var textHeightConstraint : Constraint? = nil
    
    // MARK: View
    override func viewDidLoad() {
        
        // Title
        title = "Settings"
        
        // Done button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed:")
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName:Constants.ActiveColor], forState: .Normal)
        
        // UX
        setupViews()
        
        // Tap recognizer
        let tappy = UITapGestureRecognizer(target: self, action: "textTapped:")
        textView.addGestureRecognizer(tappy)
        
        // taps outside the text view need to release the focus
        let releaser = UITapGestureRecognizer(target: self, action: "releaseFirstResponder")
        view.addGestureRecognizer(releaser)

        reminderTextView.delegate = self
        
        // UX config
        handleSettingsChanged(nil)
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSettingsChanged:", name: Settings.Notifications.SettingsChanged, object: nil)
        
        self.pa_addKeyboardListeners()
        
    }
    
    override func pa_notificationKeyboardWillShow(notification: NSNotification) {
        self.moveScrollViewForKeyboard(scrollView, notification: notification, keyboardShowing: true)
    }
    
    func textViewDidChange(textView: UITextView) {
        //scrollView.scrollRectToVisible(reminderTextView.frame, animated: true)
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
        //scrollView.backgroundColor = UIColor.whiteColor()
        reminderTextView.setNeedsLayout()
        underline.setNeedsLayout()

    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        UIView.animateWithDuration(0.4) {
            self.underline.alpha = 0
            //self.scrollView.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        }
    }
    override func pa_notificationKeyboardWillHide(notification: NSNotification) {
        self.moveScrollViewForKeyboard(scrollView, notification: notification, keyboardShowing: false)

    }

    // MARK: Text Rendering
    func setupViews() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        view.addSubview(scrollView)
        scrollView.snp_makeConstraints{ make in
            make.edges.equalTo(0)
        }
        
        //print("topLayoutGuide.length \(topLayoutGuide)")
        
        //scrollView.contentInset = UIEdgeInsets(top: 45, left: 0, bottom: 0, right: 0)
        
        // top label
        let headerInset = 15
        headerLabel = UILabel()
        headerLabel.numberOfLines = 0
        headerLabel.attributedText = NSMutableAttributedString.mm_attributedString(
            "Edit\nsettings",
            sizeAdjustment: 6,
            isBold: true,
            kerning: -0.6,
            color: Constants.GreyTextColor,
            lineHeightMultiple: 0.8)
        scrollView.addSubview(headerLabel)
        headerLabel.snp_makeConstraints { make in
            make.top.equalTo(46) // topLayoutGuide.length seems 0...
            make.leading.equalTo(headerInset)
            make.trailing.equalTo(-headerInset)
        }
        headerLabel.backgroundColor = UIColor.clearColor()
        
        var textOffsetFromHeader = 40
        
        // For now just hide the header label and on off button - we don't need it here
        if ((self.navigationController) != nil) {
            //headerLabel.hidden = true
            textOffsetFromHeader = -30
        }
        
        // done button
        let doneLabel = UILabel()
        doneLabel.userInteractionEnabled = true
        doneLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "doneButtonPressed:"))
        
        doneLabel.attributedText = NSMutableAttributedString.mm_attributedString(
            "done",
            sizeAdjustment: 0,
            isBold: true,
            kerning: -0.6,
            color: Constants.ActiveColor,
            lineHeightMultiple: 0.8)
        scrollView.addSubview(doneLabel)
        doneLabel.snp_makeConstraints { make in
            make.baseline.equalTo(headerLabel.snp_baseline) // topLayoutGuide.length seems 0...
            make.trailing.equalTo(-headerInset)
        }

        // line view
        let line = DashedLineView()
        scrollView.addSubview(line)
        line.dashShape.strokeColor = UIColor.nkrPaleSalmonColor().colorWithAlphaComponent(0.9).CGColor
        line.dashShape.lineWidth = 2
        line.snp_makeConstraints { make in
            make.top.equalTo(headerLabel.snp_baseline).offset(18) // topLayoutGuide.length seems 0...
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
        }
        
        // main text view
        textView = UITextView.createCustomTextView()
        reminderTextView = UITextView.createCustomTextView()
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
            make.top.equalTo(textView.snp_bottom).offset(7)
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
    
    func textTapped(recognizer: UITapGestureRecognizer) {
        let textView = recognizer.view as! UITextView
        let value = textView.tagForLocation(recognizer.locationInView(textView))
        
        if let value = value {
            switch value {
            case Tag.StartTime:
                showTimeControl(Tag.StartTime, text: "From", time: ReminderEngine.reminderEngine.startTimeAsDate())
                break
                
            case Tag.EndTime:
                showTimeControl(Tag.EndTime, text: "To:", time: ReminderEngine.reminderEngine.endTimeAsDate())
                break
                
            case Tag.NumberOfReminders:
                showNumRemindersControl("Reminders Per Day", number: AppDelegate.delegate().settings.remindersPerDay)
                break
                
            default:
                break
            }
        }
        releaseFirstResponder()
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
        attributedText.appendText(" per day,\n")
        attributedText.appendText("\n")
        
        attributedText.appendText("from\t")
        let startText = ReminderEngine.reminderEngine.startTimeAsDate().asHoursString()
        attributedText.appendClickableText(startText, tag: Tag.StartTime)
        attributedText.appendText("\nto\t", lineHeightMultiple: 1.3)
        
        let endText = ReminderEngine.reminderEngine.endTimeAsDate().asHoursString()
        attributedText.appendClickableText(endText, tag: Tag.EndTime, lineHeightMultiple: 1.3)
        
        attributedText.appendText("\ntelling me to", lineHeightMultiple:1.8)
        
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
    
    
    
    
    func releaseFirstResponder() {
        if (self.reminderTextView.isFirstResponder()) {
            self.reminderTextView.resignFirstResponder()
        }
    }

    func showTimeControl(tag: String, text: String, time: NSDate) {
        let isStartDate = tag == Tag.StartTime
        let picker = ActionSheetDatePicker(
            title: text,
            datePickerMode: UIDatePickerMode.Time,
            selectedDate: time,
            doneBlock: { picker, selectedDate, origin in
                print("\(selectedDate)")
                self.setDate(selectedDate as! NSDate, isStartDate: isStartDate)
            },
            cancelBlock: { picker in
            },
            origin: self.view)
        
        picker.hideCancel = true
        picker.minuteInterval = 30
        picker.showActionSheetPicker()

        print("picker.pickerView \(picker.pickerView)")
        if let pickerView = picker.pickerView as? UIDatePicker {
            print("adding observer")
            pickerView.addTarget(self, action: (isStartDate ? "startDateChanged:" : "endDateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    func startDateChanged(datePicker: UIDatePicker) {
        setDate(datePicker.date, isStartDate: true)
    }
    func endDateChanged(datePicker: UIDatePicker) {
        setDate(datePicker.date, isStartDate: false)
    }
    
    func setDate(selectedDate: NSDate, isStartDate: Bool) {
        let settings = AppDelegate.delegate().settings
        let date = selectedDate
        let f = date.asHoursAndMinutesFloat()
        
        if (isStartDate) {
            settings.startTime = f
        } else {
            settings.stopTime = f
        }
        settings.save()
    }

    
    func showNumRemindersControl(title: String, number: Int) {
        
        var rows = [String]()
        for ix in 1...50 {
            rows.append("\(ix)")
        }
        
        //let actionSheetStringPicker
        
        let actionSheetStringPicker = ActionSheetStringPicker(title: "Reminders Per Day", rows: rows, initialSelection: number-1,
            doneBlock: {
                picker, index, value in
                let settings = AppDelegate.delegate().settings
                settings.remindersPerDay = index + 1
                settings.save()
                picker.removeObserver(self, forKeyPath: "selectedIndex")
                return
            }, cancelBlock: { picker in
                picker.removeObserver(self, forKeyPath: "selectedIndex")
                return
            },
            origin: self.view)
        actionSheetStringPicker.hideCancel = true
        actionSheetStringPicker.addObserver(self, forKeyPath: "selectedIndex", options: .New, context: nil)
        actionSheetStringPicker.showActionSheetPicker()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "selectedIndex") {
            if let picker = object as? ActionSheetStringPicker{
                let settings = AppDelegate.delegate().settings
                settings.remindersPerDay = picker.selectedIndex + 1
                settings.save()
            }
        }
    }

    
    func pickerChanged(sender: UIDatePicker) {
        print("picker changed to \(sender.date)")
    }
    
    
}


