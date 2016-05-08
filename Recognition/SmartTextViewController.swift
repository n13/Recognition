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
    var presetsButton: ButtonView?
    var dismissKeyboardOnShow = false

    let textInset = Constants.TextInset
    var textHeightConstraint : Constraint? = nil
    var changeButtonBottomOffset : Constraint? = nil
    
    // generalization options
    var titleText: String = "Edit\nsettings"
    var bodyText: String?
    var isSettingsScreen = true
    
    var reminderTextMaxHeightConstraint : Constraint? = nil
    var reminderTextMinHeightConstraint : Constraint? = nil

    // MARK: View
    override func viewDidLoad() {
        
        // Title
        title = "Settings"
        
        // Done button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(SmartTextViewController.doneButtonPressed(_:)))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName:Constants.ActiveColor], forState: .Normal)
        navigationController?.navigationBarHidden = true
        
        // UX
        setupViews()
        
        // Tap recognizer
        let tappy = UITapGestureRecognizer(target: self, action: #selector(SmartTextViewController.textTapped(_:)))
        textView.addGestureRecognizer(tappy)
        
        // taps outside the text view need to release the focus
        let releaser = UITapGestureRecognizer(target: self, action: #selector(SmartTextViewController.releaseFirstResponder))
        view.addGestureRecognizer(releaser)
        
        // UX config
        handleSettingsChanged(nil)
        if (!isSettingsScreen && bodyText != nil) {
            let attributedText = NSMutableAttributedString()
            attributedText.appendText(bodyText!, sizeAdjustment: -10, kerning: 0.0)
            self.textView.attributedText = attributedText
        }
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SmartTextViewController.handleSettingsChanged(_:)), name: Settings.Notifications.SettingsChanged, object: nil)
        
        self.pa_addKeyboardListeners()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.navigationController != nil && !self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if (dismissKeyboardOnShow) {
            reminderTextView.resignFirstResponder()
            dismissKeyboardOnShow = false
        }

    }
    
    override func pa_notificationKeyboardWillShow(notification: NSNotification) {
        self.moveScrollViewForKeyboard(scrollView, notification: notification, keyboardShowing: true)
        scrollView.contentOffset = CGPoint(x: 0, y: reminderTextView.frame.origin.y - 20)
        scrollView.scrollEnabled = false
        
        let info = notification.userInfo
        let kbSize = info?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size
        if let size = kbSize {
            changeButtonBottomOffset?.updateOffset(-size.height+1)
        }
        self.reminderTextMinHeightConstraint?.updateOffset(160)
        self.reminderTextMaxHeightConstraint?.updateOffset(160)
        UIView.animateWithDuration(0.4) {
            self.underline.alpha = 0
            self.presetsButton?.alpha = 1
            
            //self.scrollView.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        }

    }
    
    override func pa_notificationKeyboardWillHide(notification: NSNotification) {
        self.moveScrollViewForKeyboard(scrollView, notification: notification, keyboardShowing: false)
        scrollView.contentOffset = CGPointZero
        scrollView.scrollEnabled = true
        changeButtonBottomOffset?.updateOffset(-5)
        self.reminderTextMinHeightConstraint?.updateOffset(0)
        self.reminderTextMaxHeightConstraint?.updateOffset(999)
        
        UIView.animateWithDuration(0.4) {
            self.underline.alpha = 1
            self.presetsButton?.alpha = 0
        }
        reminderTextView.setNeedsLayout()
        underline.setNeedsLayout()


    }

    
    func textViewDidEndEditing(textView: UITextView) {
        let newText = reminderTextView.attributedText.string.pa_trim()
        print("new text: \(newText)")
        
        if (newText.isEmpty) {
            self.reminderTextView.attributedText = createReminderText()
            return;
        }
        
        
        let settings = AppDelegate.delegate().settings
        settings.setReminderAndUpdateHistory(newText)
        settings.save()
        

        //scrollView.backgroundColor = UIColor.whiteColor()

    }
    
    func textViewDidBeginEditing(textView: UITextView) {
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
        
        let textOffsetFromHeader = 40
        
        headerLabel = createHeaderViews(scrollView, titleText: titleText, doneButtonText: "done", doneButtonAction: #selector(SmartTextViewController.doneButtonPressed(_:)))
        
        // main text view
        textView = UITextView.createCustomTextView()
        scrollView.addSubview(textView)
        
        textView.snp_makeConstraints { make in
            make.top.equalTo(headerLabel.snp_baseline).offset(textOffsetFromHeader)
            make.leading.equalTo(scrollView.snp_leading).offset(textInset)
            make.trailing.equalTo(scrollView.snp_trailing).offset(-textInset)
            make.width.equalTo(view.snp_width).offset(-textInset*2)
            //make.bottom.equalTo(scrollView.snp_bottom)
            
            // text heigh constraint so we can shrink this view
            self.textHeightConstraint = make.height.lessThanOrEqualTo(CGFloat(1000)).constraint // DEBUG remove
        }
        
        // this should be in a subclass or whatever
        if (isSettingsScreen) {
            reminderTextView = UITextView.createCustomTextView()
            scrollView.addSubview(reminderTextView)
            reminderTextView.snp_makeConstraints { make in
                make.top.equalTo(textView.snp_bottom).offset(7)
                make.width.equalTo(textView.snp_width)
                make.left.equalTo(textView.snp_left)
                self.reminderTextMaxHeightConstraint = make.height.lessThanOrEqualTo(999.0).constraint
                self.reminderTextMinHeightConstraint = make.height.greaterThanOrEqualTo(0.0).constraint
                make.bottom.equalTo(scrollView.snp_bottom).offset(-30)
            }
            reminderTextView.editable = true
            reminderTextView.delegate = self

            reminderTextView.font = UIFont(name: Constants.RegularFont, size: Constants.TextBaseSize)
            reminderTextView.textColor = Constants.ActiveColor

            underline = DashedLineView()
            underline.placeBelowView(reminderTextView)
            
            presetsButton = ButtonView.fromNib() as ButtonView // note: "as.. " is only required because of swift bug?!
            view.addSubview(presetsButton!)
            presetsButton?.setText("Choose text from a list")
            presetsButton?.snp_makeConstraints { make in
                //make.top.equalTo(reminderTextView.snp_bottom).offset(0)
//                make.right.equalTo(0)

                make.left.equalTo(-1)
                make.right.equalTo(1)
                make.height.equalTo(40)
                //make.bottom.equalTo(scrollView.snp_bottom).offset(-30)
                changeButtonBottomOffset = make.bottom.equalTo(view.snp_bottomMargin).offset(-10).constraint
            }
            //presetsButton?.alpha = 0
            presetsButton?.button.addTarget(self, action: #selector(SmartTextViewController.presetsButtonPressed(_:)), forControlEvents: .TouchUpInside)
            
            let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: reminderTextView, action: #selector(UIResponder.resignFirstResponder))
            let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let resetButton = UIBarButtonItem(title: "Reset Text", style: .Done, target: self, action: #selector(SmartTextViewController.resetReminderText))

            let toolbar = UIToolbar(frame: CGRectMake(0 ,0, 320, 44))
            toolbar.items = [resetButton, spacer, doneButton]
            
            reminderTextView.inputAccessoryView = toolbar

        }
    }
    
    func resetReminderText() {
        reminderTextView.attributedText = NSAttributedString(string: Constants.DefaultReminderText)
        // note: resigning in the keyboard will get the new text stored in settings 
        // and also add all the formatting and so on
        reminderTextView.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
//        print("text frame: \(textView.frame)")
//        print("view: \(view.performSelector("recursiveDescription"))")
    }
    
    // MARK: Actions
    func handleSettingsChanged(notification: NSNotification?) {
        print("handle settings changed - new reminder text: \(AppDelegate.delegate().settings.reminderText)")
        if (isSettingsScreen) {
            textView.attributedText = createText()
            reminderTextView.attributedText = createReminderText()
            reminderTextView.endEditing(true)
        }
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func presetsButtonPressed(sender: AnyObject) {
//        print("presets")
//        let vc = ListViewController.createMain()
//        vc.title = "Choose Reminder Text"
//        //let nvc = UINavigationController(rootViewController: vc)
//        
//        vc.doneBlock = { newText in
//            print("done selecting")
//            if let text = newText {
//                print("different text")
//                //self.reminderTextView.text = text
//                self.resignCurrentFirstResponder()
//                //self.dismissKeyboardOnShow = true
//            }
//        }
//        
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        self.navigationController?.pushViewController(vc, animated: true)
        
        
        print("presets")
        let vc = HistoryListViewController()
        vc.title = "History"
        vc.doneBlock = { newText in
            print("done selecting")
            if let text = newText {
                print("different text")
                //self.reminderTextView.text = text
                self.resignCurrentFirstResponder()
                //self.dismissKeyboardOnShow = true
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    let popupBaseView = UIView(frame: CGRectZero)
    
    func textTapped(recognizer: UITapGestureRecognizer) {
        let textView = recognizer.view as! UITextView
        let locationTapped = recognizer.locationInView(textView)
        let value = textView.tagForLocation(locationTapped)
        
        textView.addSubview(popupBaseView)
        popupBaseView.frame = CGRect(x: locationTapped.x, y: locationTapped.y, width: 1, height: 1)

        if let value = value {
            switch value {
            case Tag.StartTime:
                showTimeControl(Tag.StartTime, text: "From", time: ReminderEngine.reminderEngine.startTimeAsDate(), popupBaseView: popupBaseView)
                break
                
            case Tag.EndTime:
                showTimeControl(Tag.EndTime, text: "To:", time: ReminderEngine.reminderEngine.endTimeAsDate(), popupBaseView: popupBaseView)
                break
                
            case Tag.NumberOfReminders:
                showNumRemindersControl("Reminders Per Day", number: AppDelegate.delegate().settings.remindersPerDay, popupBaseView: popupBaseView)
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
        let settings = AppDelegate.delegate().settings
        let numReminders = "\(settings.remindersPerDay) reminders"
        
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
        if (settings.endTimeIsPlusOneDay()) {
            attributedText.appendText(" +1", color: Constants.ActiveColor, lineHeightMultiple: 1.3)
        }
        
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
        if (self.reminderTextView != nil && self.reminderTextView.isFirstResponder()) {
            self.reminderTextView.resignFirstResponder()
        }
    }

    func showTimeControl(tag: String, text: String, time: NSDate, popupBaseView: UIView) {
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
            origin: popupBaseView)
        
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

    
    func showNumRemindersControl(title: String, number: Int, popupBaseView: UIView) {
        
        var rows = [String]()
        for ix in 1...30 {
            rows.append("\(ix)")
        }
        // increments of 5 until 50
        rows.appendContentsOf(["35", "40", "45", "50"])
        // increments of 100 for those crazy experiments
        rows.appendContentsOf(["100", "200"])//, "300", "400", "500"])
        let initialIndex = rows.indexOf("\(number)") ?? 11
        
        let actionSheetStringPicker = ActionSheetStringPicker(title: "Reminders Per Day", rows: rows, initialSelection: initialIndex,
            doneBlock: {
                picker, index, value in
                let settings = AppDelegate.delegate().settings
                let valueString: NSString = value as! NSString
                settings.remindersPerDay = valueString.integerValue
                //print("times per day set to: \(settings.remindersPerDay)")
                settings.save()
                picker.removeObserver(self, forKeyPath: "selectedIndex")
                return
            }, cancelBlock: { picker in
                picker.removeObserver(self, forKeyPath: "selectedIndex")
                return
            },
            origin: popupBaseView)
        actionSheetStringPicker.hideCancel = true
        actionSheetStringPicker.addObserver(self, forKeyPath: "selectedIndex", options: .New, context: nil)
        actionSheetStringPicker.showActionSheetPicker()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "selectedIndex") {
            if let picker = object as? ActionSheetStringPicker{
                let settings = AppDelegate.delegate().settings
                settings.remindersPerDay = (picker.selectedValueAsString() as NSString).integerValue
                settings.save()
            }
        }
    }

    
    func pickerChanged(sender: UIDatePicker) {
        print("picker changed to \(sender.date)")
    }
    
    
}


