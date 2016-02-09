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
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        
        title = "Recognition Reminders"
        
        let tappy = UITapGestureRecognizer(target: self, action: "textTapped:")
        textView.addGestureRecognizer(tappy)
        
        createText()
        
        ReminderEngine.reminderEngine.initEngine()
        
        onOffSwitch.on = ReminderEngine.reminderEngine.isRunning
        
        updateStartStopButton()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSettingsChanged:", name: Settings.Notifications.SettingsChanged, object: nil)

    }
    
    func handleSettingsChanged(notification: NSNotification) {
        print("handle settings changed")
        createText()
    }
    
    @IBAction func switchPressed(sender: AnyObject) {
        if (onOffSwitch.on) {
            ReminderEngine.reminderEngine.start()
        } else {
            ReminderEngine.reminderEngine.stop()
        }
        updateStartStopButton()
    }
    
    func updateStartStopButton() {
        let running = ReminderEngine.reminderEngine.isRunning
        statusLabel.textColor = running ? UIColor.greenColor() : UIColor.lightGrayColor()
        statusLabel.text = running ? "Running" : "Stopped"
        
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
        
        appendText("Schedule ")
        appendClickableText(numReminders, tag: Tag.NumberOfReminders)
        appendText(" reminders per day\n")
        appendText("\n")
        
        appendText("from\t\t")
        let startText = Constants.timeFormat.stringFromDate(ReminderEngine.reminderEngine.startTimeAsDate())
        appendClickableText(startText, tag: Tag.StartTime)
        appendText("\nto\t\t\t\t")
        
        let endText = Constants.timeFormat.stringFromDate(ReminderEngine.reminderEngine.endTimeAsDate())
        appendClickableText(endText, tag: Tag.EndTime)

        appendText("\n\ntelling me to\n")
        appendClickableText(AppDelegate.delegate().settings.reminderText, tag: Tag.ReminderText)
        
        textView.attributedText = attributedText
    }
    
    let textSize : CGFloat = 30
    
    func appendText(text: String) {
        let color = UIColor.blackColor()
        let attributes: [String:AnyObject] = [
            NSFontAttributeName : UIFont(name: "HelveticaNeue-Medium", size: textSize)!,
            NSForegroundColorAttributeName : color,
            //NSUnderlineColorAttributeName : color,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.PatternDash.rawValue,

        ]
        attributedText.appendAttributedString(NSAttributedString(string: text, attributes: attributes))
    }
 
    func appendClickableText(text: String, tag: String) {
        let color = UIColor.purpleColor()
        let attributes: [String:AnyObject] = [
            NSFontAttributeName : UIFont(name: "HelveticaNeue-Bold", size: textSize)!,
            NSForegroundColorAttributeName : color,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.PatternDot.rawValue | NSUnderlineStyle.StyleThick.rawValue,
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
                let vc = SettingsViewController.createMain()
                let nc = UINavigationController(rootViewController: vc)
                nc.modalTransitionStyle = .FlipHorizontal
                presentViewController(nc, animated: true, completion: nil)
            }
        }
        
        
    }
    
    
}
