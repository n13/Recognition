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
    var changeButtonBottomOffset : Constraint? = nil
    
    // generalization options
    var titleText: String = "Edit\nsettings"
    var bodyText: String?
    var isSettingsScreen = true
    
    var reminderTextMaxHeightConstraint : Constraint? = nil
    var reminderTextMinHeightConstraint : Constraint? = nil
    
    var editMode = false

    // MARK: View
    override func viewDidLoad() {
        
        // Title
        title = "Settings"
        
        // Done button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SmartTextViewController.doneButtonPressed(_:)))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName:Constants.ActiveColor], for: UIControlState())
        navigationController?.isNavigationBarHidden = true
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(SmartTextViewController.handleSettingsChanged(_:)), name: NSNotification.Name(rawValue: Settings.Notifications.SettingsChanged), object: nil)
        
        self.pa_addKeyboardListeners()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.navigationController != nil && !self.navigationController!.isNavigationBarHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func pa_notificationKeyboardWillShow(_ notification: Notification) {
        print("keyboard will show")
        if (!editMode) {
            editMode = true
            self.moveScrollView(forKeyboard: scrollView, notification: notification, keyboardShowing: true)
            scrollView.contentOffset = CGPoint(x: 0, y: reminderTextView.frame.origin.y - 20)
            scrollView.isScrollEnabled = false
            scrollView.delaysContentTouches = false
            
            let info = notification.userInfo
            let kbSize = (info?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
            if kbSize != nil {
                changeButtonBottomOffset?.updateOffset(amount: -kbSize.height+1)
            }
            self.reminderTextView.isScrollEnabled = true
            self.reminderTextMinHeightConstraint?.updateOffset(amount: 240)
            self.reminderTextMaxHeightConstraint?.updateOffset(amount: 240)
            UIView.animate(withDuration: 0.4, animations: {
                self.underline.alpha = 0
            }) 
        }
    }
    
    // NOTE: This can come in multiple times.
    override func pa_notificationKeyboardWillHide(_ notification: Notification) {

        self.moveScrollView(forKeyboard: scrollView, notification: notification, keyboardShowing: false)

    }

    
    func textViewDidEndEditing(_ textView: UITextView) {
        let newText = reminderTextView.attributedText.string.pa_trim()
        print("end editing. new text: \(newText)")

        editMode = false

        scrollView.contentOffset = CGPoint.zero
        scrollView.isScrollEnabled = true
        scrollView.delaysContentTouches = true
        
        changeButtonBottomOffset?.updateOffset(amount: -5)
        
        self.reminderTextView.isScrollEnabled = false
        self.reminderTextMinHeightConstraint?.updateOffset(amount: 0)
        self.reminderTextMaxHeightConstraint?.updateOffset(amount: 999)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.underline.alpha = 1
        }) 
        reminderTextView.setNeedsLayout()
        underline.setNeedsLayout()

        if (newText.isEmpty) {
            // do nothing
            self.reminderTextView.attributedText = createReminderText()
        } else {
            let settings = AppDelegate.delegate().settings
            settings.setReminderAndUpdateHistory(newText)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("begin editing")
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
        
        let headerViews = createHeaderViews(scrollView, titleText: titleText, doneButtonText: "done", doneButtonAction: #selector(SmartTextViewController.doneButtonPressed(_:)))
        headerLabel = headerViews.headerLabel
        
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
            reminderTextView.isEditable = true
            reminderTextView.delegate = self

            reminderTextView.font = UIFont(name: Constants.RegularFont, size: Constants.TextBaseSize)
            reminderTextView.textColor = Constants.ActiveColor

            underline = DashedLineView()
            underline.placeBelowView(reminderTextView)
            
            let historyButton = UIBarButtonItem(title: "History →", style: .done, target: self, action: #selector(SmartTextViewController.historyButtonPressed(_:)))
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: reminderTextView, action: #selector(UIResponder.resignFirstResponder))
            
            let toolbar = UIToolbar(frame: CGRect(x: 0 ,y: 0, width: 320, height: 44))
            toolbar.items = [historyButton, spacer, doneButton]
            
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
    func handleSettingsChanged(_ notification: Notification?) {
        print("handle settings changed - new reminder text: \(AppDelegate.delegate().settings.reminderText)")
        if (isSettingsScreen) {
            textView.attributedText = createText()
            reminderTextView.attributedText = createReminderText()
            reminderTextView.endEditing(true)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func historyButtonPressed(_ sender: AnyObject) {
        print("history")

        self.resignCurrentFirstResponder()

        let vc = HistoryListViewController()
        vc.title = "History"
        vc.doneBlock = { newText in
            print("done selecting")
            if let text = newText {
                print("new text: \(text)")
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    let popupBaseView = UIView(frame: CGRect.zero)
    
    func textTapped(_ recognizer: UITapGestureRecognizer) {
        let textView = recognizer.view as! UITextView
        let locationTapped = recognizer.location(in: textView)
        let value = textView.tagForLocation(locationTapped)
        
        textView.addSubview(popupBaseView)
        popupBaseView.frame = CGRect(x: locationTapped.x, y: locationTapped.y, width: 1, height: 1)

        if let value = value {
            switch value {
            case Tag.StartTime:
                showTimeControl(Tag.StartTime, text: "From", time: ReminderEngine.reminderEngine.startTimeAsDate() as Date, popupBaseView: popupBaseView)
                break
                
            case Tag.EndTime:
                showTimeControl(Tag.EndTime, text: "To:", time: ReminderEngine.reminderEngine.endTimeAsDate() as Date, popupBaseView: popupBaseView)
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
    
    func createOnOffText(_ isOnLabel: Bool) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString()
        let sizeAdjustment: CGFloat = 0
        attributedText.appendText((isOnLabel) ? "on" : "off", sizeAdjustment: sizeAdjustment, color: Constants.ActiveColor)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.right
        
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        
        return attributedText
    }
    
    func releaseFirstResponder() {
        if (self.reminderTextView != nil && self.reminderTextView.isFirstResponder) {
            self.reminderTextView.resignFirstResponder()
        }
    }

    func showTimeControl(_ tag: String, text: String, time: Date, popupBaseView: UIView) {
        let isStartDate = tag == Tag.StartTime
        let picker = ActionSheetDatePicker(
            title: text,
            datePickerMode: UIDatePickerMode.time,
            selectedDate: time,
            doneBlock: { picker, selectedDate, origin in
                print("\(selectedDate)")
                self.setDate(selectedDate as! Date, isStartDate: isStartDate)
            },
            cancel: { picker in
            },
            origin: popupBaseView)
        
        picker?.hideCancel = true
        picker?.minuteInterval = 30
        picker?.show()

        print("picker.pickerView \(picker?.pickerView)")
        if let pickerView = picker?.pickerView as? UIDatePicker {
            print("adding observer")
            pickerView.addTarget(self, action: (isStartDate ? #selector(SmartTextViewController.startDateChanged(_:)) : #selector(SmartTextViewController.endDateChanged(_:))), for: UIControlEvents.valueChanged)
        }
    }
    
    func startDateChanged(_ datePicker: UIDatePicker) {
        setDate(datePicker.date, isStartDate: true)
    }
    func endDateChanged(_ datePicker: UIDatePicker) {
        setDate(datePicker.date, isStartDate: false)
    }
    
    func setDate(_ selectedDate: Date, isStartDate: Bool) {
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

    
    func showNumRemindersControl(_ title: String, number: Int, popupBaseView: UIView) {
        
        var rows = [String]()
        for ix in 1...30 {
            rows.append("\(ix)")
        }
        // increments of 5 until 50
        rows.append(contentsOf: ["35", "40", "45", "50"])
        // increments of 100 for those crazy experiments
        rows.append(contentsOf: ["100", "200", "300", "400", "500"])
        let initialIndex = rows.index(of: "\(number)") ?? 11
        
        let actionSheetStringPicker = ActionSheetStringPicker(title: "Reminders Per Day", rows: rows, initialSelection: initialIndex,
            doneBlock: {
                picker, index, value in
                let settings = AppDelegate.delegate().settings
                let valueString: NSString = value as! NSString
                settings.remindersPerDay = valueString.integerValue
                //print("times per day set to: \(settings.remindersPerDay)")
                settings.save()
                picker?.removeObserver(self, forKeyPath: "selectedIndex")
                return
            }, cancel: { picker in
                picker?.removeObserver(self, forKeyPath: "selectedIndex")
                return
            },
            origin: popupBaseView)
        actionSheetStringPicker?.hideCancel = true
        actionSheetStringPicker?.addObserver(self, forKeyPath: "selectedIndex", options: .new, context: nil)
        actionSheetStringPicker?.show()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "selectedIndex") {
            if let picker = object as? ActionSheetStringPicker{
                let settings = AppDelegate.delegate().settings
                settings.remindersPerDay = (picker.selectedValueAsString() as NSString).integerValue
                settings.save()
            }
        }
    }

    
    func pickerChanged(_ sender: UIDatePicker) {
        print("picker changed to \(sender.date)")
    }
    
    
}


