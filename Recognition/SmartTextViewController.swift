//
//  SmartTextViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/8/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//


import UIKit

class SmartTextViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    var attributedText = NSMutableAttributedString()
    
    @IBOutlet weak var onOffSwitch: UISwitch!
    
    override func viewDidLoad() {
        
        // Title
        title = "Recognition"
        
        onOffSwitch.onTintColor = Constants.PurpleColor
        
        // Info button
        let infoButton = UIButton(type: .InfoLight)
        infoButton.addTarget(self, action: "InfoButtonPressed:", forControlEvents: .TouchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
        
        // switch in nav bar
        onOffSwitch.hidden = true
        let aSwitch = UISwitch()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: aSwitch)
        onOffSwitch = aSwitch
        onOffSwitch.addTarget(self, action: "switchPressed:", forControlEvents: .ValueChanged)
        
        // Tap recognizer
        let tappy = UITapGestureRecognizer(target: self, action: "textTapped:")
        textView.addGestureRecognizer(tappy)
        
        // Text
        createText()
        
        // Make sure the engine is on
        ReminderEngine.reminderEngine.initEngine()
        
        // UX config
        onOffSwitch.on = ReminderEngine.reminderEngine.isRunning
        updateStartStopButton()
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSettingsChanged:", name: Settings.Notifications.SettingsChanged, object: nil)

    }
    
    // MARK: Status bar
    //    override func preferredStatusBarStyle() -> UIStatusBarStyle {
    //        return .LightContent
    //    }

    
    // MARK: Actions
    func handleSettingsChanged(notification: NSNotification) {
        print("handle settings changed")
        createText()
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
        updateStartStopButton()
    }
    
    // MARK: UX
    func updateStartStopButton() {
        let running = ReminderEngine.reminderEngine.isRunning
//        statusLabel.textColor = running ? UIColor.purpleColor() : UIColor.lightGrayColor()
//        statusLabel.text = running ? "Running" : "Stopped"
        
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
    }
    
    
    
    func createText() {
        
        attributedText = NSMutableAttributedString()
        
        let numReminders = "\(AppDelegate.delegate().settings.remindersPerDay)"
        
        appendText("2-5 second\nmeditation\n\n", sizeAdjustment: 6, isBold: true, kerning: -0.6, color: Constants.GreyTextColor)

        appendText("schedule ")
        appendClickableText(numReminders, tag: Tag.NumberOfReminders)
        appendText(" reminders per day\n")
        appendText("\n")
        
        appendText("from\t")
        let startText = Constants.timeFormat.stringFromDate(ReminderEngine.reminderEngine.startTimeAsDate())
        appendClickableText(startText, tag: Tag.StartTime)
        appendText("\nto\t")
        
        let endText = Constants.timeFormat.stringFromDate(ReminderEngine.reminderEngine.endTimeAsDate())
        appendClickableText(endText, tag: Tag.EndTime)

        appendText("\n\ntelling me to\n")
        appendClickableText(AppDelegate.delegate().settings.reminderText, tag: Tag.ReminderText)
        
        textView.attributedText = attributedText
        
    }
    
    var paragraphStyle: NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.tabStops = [NSTextTab(textAlignment: NSTextAlignment.Left, location: 110, options: [:])]
        style.lineHeightMultiple = 0.9
        return style
    }

    static var timeFormat: NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle;
        formatter.dateStyle = .NoStyle;
        return formatter
    }

    
    func appendText(text: String, sizeAdjustment: CGFloat = 0.0, isBold:Bool=false, kerning: CGFloat = -1.0, color: UIColor = UIColor.blackColor())
    {
        let textSize = Constants.TextBaseSize+sizeAdjustment
        let font = UIFont(name: (isBold ? "HelveticaNeue-Bold":"HelveticaNeue-Medium"), size: textSize)!
        let attributes: [String:AnyObject] = [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName: paragraphStyle,
            NSKernAttributeName: kerning,
        ]
        attributedText.appendAttributedString(NSAttributedString(string: text, attributes: attributes))
    }
    
    
 
    func appendClickableText(text: String, tag: String) {
        let color = Constants.PurpleColor
        let textSize = Constants.TextBaseSize
        let attributes: [String:AnyObject] = [
            NSFontAttributeName : UIFont(name: "HelveticaNeue-Bold", size: textSize)!,
            NSForegroundColorAttributeName : color,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.PatternDot.rawValue | NSUnderlineStyle.StyleThick.rawValue,
            NSParagraphStyleAttributeName: paragraphStyle,
            Constants.SmartTag : tag
        ]
        attributedText.appendAttributedString(NSAttributedString(string: text, attributes: attributes))
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
