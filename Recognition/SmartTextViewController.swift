//
//  SmartTextViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/8/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//


import UIKit

class SmartTextViewController: UIViewController {
    
    var scrollView = UIScrollView()
    var textView: UITextView!
    var headerLabel: UILabel!
    
    var attributedText = NSMutableAttributedString()
    var textStorage: NSTextStorage!

    var onOffSwitch = UISwitch()
    
    override func viewDidLoad() {
        
        // Title
        title = "Recognition"
        
        // Info button
        let infoButton = UIButton(type: .InfoLight)
        infoButton.addTarget(self, action: "InfoButtonPressed:", forControlEvents: .TouchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
        
        // switch in nav bar
//        let aSwitch = UISwitch()
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: aSwitch)
//        onOffSwitch = aSwitch
        onOffSwitch.addTarget(self, action: "switchPressed:", forControlEvents: .ValueChanged)
        
        // text view
        createTextView()

      
        // Tap recognizer
        let tappy = UITapGestureRecognizer(target: self, action: "textTapped:")
        textView.addGestureRecognizer(tappy)

        // Make sure the engine is on
        ReminderEngine.reminderEngine.initEngine()
        
        // UX config
        onOffSwitch.on = ReminderEngine.reminderEngine.isRunning
        updateStartStopButton()
        
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

        return UITextView(frame: newTextViewRect, textContainer: container)
    }
    
    // MARK: Text Rendering
    
    func createTextView() {
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(scrollView)
        
        scrollView.snp_makeConstraints{ make in
            make.top.equalTo(0)
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        // top label
        headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.numberOfLines = 0
        headerLabel.attributedText = attributedString("2-5 second\nmeditation", sizeAdjustment: 6, isBold: true, kerning: -0.6, color: Constants.GreyTextColor)
        
        scrollView.addSubview(headerLabel)
        headerLabel.snp_makeConstraints { make in
            make.top.equalTo(10)
            make.leading.equalTo(15)
        }
        
        // switch
        onOffSwitch.onTintColor = Constants.PurpleColor
        onOffSwitch.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(onOffSwitch)
        onOffSwitch.snp_makeConstraints { make in
            make.trailing.equalTo(scrollView.snp_trailingMargin)
            make.centerY.equalTo(headerLabel.snp_centerY)
        }

        
        // main text view
        textView = createCustomTextView()
        textView.editable = false
        textView.scrollEnabled = false
        textView.clipsToBounds = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        scrollView.addSubview(textView)
        
        let textInset = 15
        
        textView.snp_makeConstraints { make in
            //make.top.equalTo(scrollView.snp_top)
            make.top.equalTo(headerLabel.snp_baseline).offset(55) // for scroll view
            
            make.leading.equalTo(scrollView.snp_leading).offset(textInset)
            make.trailing.equalTo(scrollView.snp_trailing).offset(-textInset)
            make.bottom.equalTo(scrollView.snp_bottom)
//            make.leading.equalTo(textInset)
//            make.trailing.equalTo(-textInset)
            
            
            make.width.equalTo(view.snp_width).offset(-textInset*2)
        }
        
        // debug
        headerLabel.backgroundColor = UIColor.redColor()
        textView.backgroundColor = UIColor.greenColor()
        scrollView.backgroundColor = UIColor.orangeColor()
        
        //scrollView.contentSize = CGSize(width: 400, height: 900)
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
    
    func createText() -> NSMutableAttributedString {
        
        attributedText = NSMutableAttributedString()
        
        let numReminders = "\(AppDelegate.delegate().settings.remindersPerDay) reminders"
        
        //appendText("2-5 second\nmeditation\n\n", sizeAdjustment: 6, isBold: true, kerning: -0.6, color: Constants.GreyTextColor)

        appendText("schedule\n")
        appendClickableText(numReminders, tag: Tag.NumberOfReminders)
        appendText("\nper day\n")
        appendText("\n")
        
        appendText("from\t")
        let startText = Constants.timeFormat.stringFromDate(ReminderEngine.reminderEngine.startTimeAsDate())
        appendClickableText(startText, tag: Tag.StartTime)
        appendText("\nto\t")
        
        let endText = Constants.timeFormat.stringFromDate(ReminderEngine.reminderEngine.endTimeAsDate())
        appendClickableText(endText, tag: Tag.EndTime)

        appendText("\n\ntelling me to\n")
        appendClickableText(AppDelegate.delegate().settings.reminderText, tag: Tag.ReminderText, dottedLine: false, fullWidthUnderline: true)
        appendText("\n")
        
        return attributedText
        
    }
    
    var paragraphStyle: NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.tabStops = [NSTextTab(textAlignment: NSTextAlignment.Left, location: 110, options: [:])]
        style.lineHeightMultiple = 0.95

        style.headIndent = 10
        style.firstLineHeadIndent = 10

        return style
    }

    static var timeFormat: NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle;
        formatter.dateStyle = .NoStyle;
        return formatter
    }

    
    func attributedString(text: String, sizeAdjustment: CGFloat = 0.0, isBold:Bool=false, kerning: CGFloat = -1.0, color: UIColor = UIColor.blackColor()) -> NSAttributedString {
        let textSize = Constants.TextBaseSize+sizeAdjustment
        let font = UIFont(name: (isBold ? "HelveticaNeue-Bold":"HelveticaNeue-Medium"), size: textSize)!
        
        let style:NSMutableParagraphStyle = paragraphStyle.mutableCopy() as! NSMutableParagraphStyle
        
        if (sizeAdjustment>0.0) {
            style.headIndent = 0
            style.firstLineHeadIndent = 0
            style.lineHeightMultiple = 0.75

        } else {
            //paragraphStyle.headIndent = 0

        }
        
        let attributes: [String:AnyObject] = [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName: style,
            NSKernAttributeName: kerning,
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func appendText(text: String, sizeAdjustment: CGFloat = 0.0, isBold:Bool=false, kerning: CGFloat = -1.0, color: UIColor = UIColor.blackColor())
    {
        attributedText.appendAttributedString(attributedString(text, sizeAdjustment: sizeAdjustment, isBold: isBold, kerning: kerning, color: color))
    }
    
    
    func appendClickableText(text: String, tag: String, dottedLine: Bool = true, fullWidthUnderline: Bool = false) {
        let color = Constants.PurpleColor
        let textSize = Constants.TextBaseSize
        var underlineStyle = NSUnderlineStyle.StyleThick.rawValue
        if (dottedLine) {
            underlineStyle |= NSUnderlineStyle.PatternDot.rawValue
        }
        var attributes: [String:AnyObject] = [
            NSFontAttributeName : UIFont(name: "HelveticaNeue-Bold", size: textSize)!,
            NSForegroundColorAttributeName : color,
            NSUnderlineStyleAttributeName :  underlineStyle,
            NSParagraphStyleAttributeName: paragraphStyle,
            Constants.SmartTag : tag,
        ]
        if (fullWidthUnderline) {
            attributes[Constants.SuperUnderlineStyle] = true
        }
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
