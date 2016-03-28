//
//  HomeViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/25/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import UIKit
import SnapKit
import MessageUI

class HomeViewController:
    UIViewController,
    MFMailComposeViewControllerDelegate,
    UIGestureRecognizerDelegate
{

    var scrollView = UIScrollView()
    var titleLabel = UILabel()
    var textView: UITextView!
    var textHeightConstraint : Constraint? = nil
    let headerInset = Constants.TextInset
    let blockheight = 70
    
    var alertVC: UIAlertController?

    // MARK: View
    override func viewDidLoad() {
        
        textView = UITextView.createCustomTextView()
        textView.scrollEnabled = false
        // UX
        setupViews()
        textView.attributedText = createMainText()

        scrollView.delaysContentTouches = false
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.handleSettingsChanged(_:)), name: Settings.Notifications.SettingsChanged, object: nil)

        updateStatus(false)
        
        // listen to notifications coming in
        addObserverForNotification(Constants.LocalNotificationArrived, selector:  #selector(HomeViewController.handleIncomingNotification))
        
        // listen to the user answering notifications dialog
        addObserverForNotification(Constants.UserAnsweredNotificationsDialog, selector:  #selector(HomeViewController.handleUserAnsweredNotificationsDialog))
        addObserverForNotification(UIApplicationDidBecomeActiveNotification, selector:  #selector(HomeViewController.handleApplicationDidBecomeActive))

    }
    
    func handleApplicationDidBecomeActive() {
        //print("app is becoming active - check notification status")
        // Note: If this fails, then worst case we show the dialog too much - that's OK
        // The worst that can happen is that we show the dialog when we launch for the first time
        // But that does not appear to happen. 
        if (AppDelegate.delegate().notificationState == .AskedAndAnswered) {
            checkNotificationsAreEnabled()
        }
    }
    
    func handleUserAnsweredNotificationsDialog() {
        //print("user answered notifications dialog... checking for notification settings!")
        checkNotificationsAreEnabled()
    }
    

    func handleIncomingNotification() {
        let message = AppDelegate.delegate().settings.reminderText
        print("handle incoming notification: \(message)")
//        alertVC = UIAlertController(title: "Recognition", message: message, preferredStyle: .Alert)
//        presentViewController(alertVC!, animated: true, completion: { [weak self] in
//            self?.alertVC = nil
//        })
    }
    
    override func viewWillAppear(animated: Bool) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        if (AppDelegate.delegate().notificationState == .AskedAndAnswered) {
            print("checking on notifications")
            checkNotificationsAreEnabled()
        }
    }
    
    func checkNotificationsAreEnabled() {
        // check notification status - except not on first launch. 
        // On first launch the user will be presented with the system notifications dialog. So we don't check or 
        // Do anything
                
        if let settings = UIApplication.sharedApplication().currentUserNotificationSettings() {
            if (settings.types.rawValue == UIUserNotificationType.None.rawValue ) {
                print("settings OFF, handling...")
                let alertVC = UIAlertController(title: "Notifications are OFF", message: "Notifications are off so you will not receive any reminders. Please turn on notifications in Settings.", preferredStyle: .ActionSheet)
                alertVC.addAction(UIAlertAction(title: "Open Settings", style: .Default) { value in
                    print("tapped default button")
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                    })
                alertVC.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                presentViewController(alertVC, animated: true, nil)
            }
        }
    }
    
    // MARK: UX State
    func updateStatus(animated: Bool) {
        let running = ReminderEngine.reminderEngine.isRunning
        
        // Note: This animation can be jumpy if updating the text prior - I guess because updating the text
        // and the new height get set on the new layout call and the text outside the bounds isn't even rendered
        // So the text disappears, and then the view animates to its new size.

        // Solution - animation layered two times... the first one is basically just setting the text, and waiting for that to 
        // finish. The second one moves the text.
        if (animated) {
            UIView.animateWithDuration(0.05, animations: {
                    self.textView.attributedText = self.createMainText()
                    self.view.layoutIfNeeded()
                },
                completion: { b in
                    self.textHeightConstraint!.updateOffset(CGFloat(running ? 1000 : Constants.ShortTextHeight))
                    UIView.animateWithDuration(0.4) {
                        self.view.layoutIfNeeded()
                    }
            })
            
        } else {
            self.textView.attributedText = self.createMainText()
            self.textHeightConstraint!.updateOffset(CGFloat(running ? 1000 : Constants.ShortTextHeight))
        }

    }

    // MARK: UX Generation
    func setupViews() {
        self.automaticallyAdjustsScrollViewInsets = false
        
        // scroll view
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.snp_makeConstraints{ make in
            make.edges.equalTo(view)
        }
        
        // title label
        titleLabel.numberOfLines = 0
        let headerText = NSMutableAttributedString.mm_attributedString("recognition", sizeAdjustment: 16, isBold: true, kerning: -1.4, color: Constants.BlackTextColor)
        headerText.applyAttribute(NSFontAttributeName, value: UIFont(name: Constants.BoldFont, size: 50)!)
        titleLabel.attributedText = headerText
        scrollView.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { make in
            make.top.equalTo(self.view.snp_top).offset(40) // topLayoutGuide.length seems 0...
            make.leading.equalTo(headerInset)
        }


        // need to draw underline as standard underlines are way too close to the text, which can't be adjusted
        let underline = DashedLineView()
        underline.placeBelowView(titleLabel)

        let underLabel = UILabel()
        let utext = NSMutableAttributedString.mm_attributedString("meditation", sizeAdjustment: 16, isBold: true, kerning: 0.2, color: Constants.BlackTextColor)
        utext.applyAttribute(NSFontAttributeName, value: UIFont(name: Constants.BoldFont, size: 50)!)
        underLabel.attributedText = utext
        scrollView.addSubview(underLabel)
        underLabel.snp_makeConstraints { make in
            make.top.equalTo(underline.snp_bottom).offset(-4) // topLayoutGuide.length seems 0...
            make.leading.equalTo(headerInset)
        }
        underLabel.hidden = true


        // Text view
        scrollView.addSubview(textView)
        textView.snp_makeConstraints { make in
//            make.top.equalTo(underLabel.snp_bottom).offset(36)
            make.top.equalTo(underline.snp_bottom).offset(36)
            make.leading.equalTo(scrollView.snp_leading).offset(headerInset)
            make.trailing.equalTo(scrollView.snp_trailing).offset(-headerInset)
            make.width.equalTo(view.snp_width).offset(-headerInset*2)
            
            // text heigh constraint so we can shrink this view
            self.textHeightConstraint = make.height.lessThanOrEqualTo(CGFloat(1000)).constraint
        }
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTapOnText:"))
        
        let screenSize = UIScreen.mainScreen().bounds.size
        
        let offsetFromBottom:CGFloat = Constants.isIpad() ? 166 : 33
        
        // Change Settings button
        let changeSettingsButton = addLabelButton(Constants.EditSettingsText, action: "changeSettingsPressed:")
        changeSettingsButton.snp_makeConstraints { make in
            //make.bottom.equalTo(self.view.snp_bottom).offset(-80)
            make.bottom.equalTo(self.scrollView.snp_top).offset(screenSize.height - offsetFromBottom)
            make.leading.equalTo(view.snp_leading).offset(headerInset)
        }

        let howToOffset:CGFloat = Constants.isIpad() ? 20 : 28
        // How to button
        let howButton = addLabelButton("How to.", action: "howButtonPressed:")
        howButton.snp_makeConstraints { make in
            make.top.equalTo(changeSettingsButton.snp_bottom).offset(howToOffset)
            make.leading.equalTo(view.snp_leading).offset(headerInset)
            //make.bottom.equalTo(self.scrollView.snp_bottom).offset(-20)
        }
        
        // Feedback button
        let feedbackButton = addLabelButton("Send feedback.", action: "sendFeedbackPressed:")
        feedbackButton.snp_makeConstraints { make in
            make.top.equalTo(howButton.snp_bottom).offset(20)
            make.leading.equalTo(view.snp_leading).offset(headerInset)
            make.bottom.equalTo(self.scrollView.snp_bottom).offset(-20)
        }
    }
    
    func addLabelButton(title: String, action: Selector) -> UILabel {
        let label = UILabel()
        label.userInteractionEnabled = true
        label.attributedText = createButtonText(title)
        scrollView.addSubview(label)
        let tappy = UITapGestureRecognizer(target: self, action: action)
        label.addGestureRecognizer(tappy)
        tappy.delegate = self
        DashedLineView().placeBelowView(label)
        return label
    }
    
    // MARK: Notifications
    func handleSettingsChanged(notification: NSNotification?) {
        print("handle settings changed")
        textView.attributedText = createMainText()
        updateStatus(false)
    }
    
    // MARK: Actions
    func handleTapOnText(recognizer: UITapGestureRecognizer) {
        let tag = textView.tagForLocation(recognizer.locationInView(textView))
        if let tag = tag {
            print("tag: \(tag)")
            if tag == "onoff" {
                onOffPressed()
            }
        } else {
            print("no tag")
        }
    }

    func sendFeedbackPressed(sender: UIGestureRecognizer) {
        print("send feedback")
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setSubject("Recognition App Feedback!")
            controller.setMessageBody("", isHTML: false)
            controller.setToRecipients(["nheger+recognition@gmail.com"])
            presentViewController(controller, animated: true, completion: nil)
        } else {
            print("device can't send email")
        }
    }
    
    func howButtonPressed(sender: UIGestureRecognizer) {
        print("change settings")
        let vc = SmartTextViewController.createMain()
        
        let text = "" +
            "Take two to five seconds to let go of all thoughts.\n\n" +
            "If thoughts still arise, don't give them much attention.\n\n" +
            "Then, as best as you can, try to feel your own existence.\n\n" +
            //"Try to feel the \"I am\".\n\n" +
            "Apply yourself sincerely to this practice - sincerity is the only requirement for success.\n\n" +
            "Enjoy!"

        vc.isSettingsScreen = false
        vc.titleText = "How to"
        vc.bodyText = text
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func changeSettingsPressed(sender: UIGestureRecognizer) {
        print("change settings")
        let vc = SmartTextViewController.createMain()
        //let nav = UINavigationController(rootViewController: vc)
        //nav.modalTransitionStyle = .FlipHorizontal
        vc.modalTransitionStyle = .FlipHorizontal
        presentViewController(vc, animated: true, completion: nil)

    }
    
    func onOffPressed() {
        print("on off")
        if (ReminderEngine.reminderEngine.isRunning) {
            ReminderEngine.reminderEngine.stop()
        } else {
            ReminderEngine.reminderEngine.start()
        }
        updateStatus(true)
    }
    
    // MARK: Text
    func createMainText() -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString()
        let numReminders = "\(AppDelegate.delegate().settings.remindersPerDay)"
        
        attributedText.appendAttributedString(createNormalText("Reminders are "))
        attributedText.appendAttributedString(createOnOffText())
        attributedText.appendAttributedString(createNormalText("\n"))
        attributedText.appendAttributedString(NSMutableAttributedString.spacerLine(0.3))

        // 24 times a day,
        attributedText.appendAttributedString(createBoldText("\(numReminders) reminders per day"))
        
        /**
        attributedText.appendAttributedString(createNormalText("from "))
        attributedText.appendAttributedString(createBoldText("\(ReminderEngine.reminderEngine.startTimeAsDate().asHoursString().lowercaseString)"))
        attributedText.appendAttributedString(createNormalText(" to "))
        attributedText.appendAttributedString(createBoldText("\(ReminderEngine.reminderEngine.endTimeAsDate().asHoursString().lowercaseString):\n"))
        attributedText.appendAttributedString(createNormalText("telling me to:\n"))
        attributedText.appendAttributedString(NSMutableAttributedString.spacerLine(0.2))
        attributedText.appendAttributedString(createBoldText("\(AppDelegate.delegate().settings.reminderText)"))
        */
        return attributedText
    }
    
    func createNormalText(s: String) -> NSMutableAttributedString {
        
        // letter spacing -0.9
        // line height 43
        
        let font = UIFont(name: Constants.RegularFont, size: Constants.HomeBaseSize)!
        let text = NSMutableAttributedString(string: s)

        text.applyAttribute(NSFontAttributeName, value: font)
        text.applyAttribute(NSKernAttributeName, value: -0.9)
        text.applyAttribute(NSForegroundColorAttributeName, value: UIColor.nkrLogotypeLightColor())

        return text

    }
    
    func createBoldText(s: String) -> NSMutableAttributedString {
        let font = UIFont(name: Constants.MediumFont, size: Constants.HomeBaseSize)!
        let text = NSMutableAttributedString(string: s)
        
        text.applyAttribute(NSFontAttributeName, value: font)
        text.applyAttribute(NSKernAttributeName, value: -1.0)
        text.applyAttribute(NSForegroundColorAttributeName, value: UIColor.nkrLogotypeLightColor())

        return text
    }
    
    func createButtonText(s: String, size: CGFloat = Constants.OnOffButtonSize) -> NSMutableAttributedString {
        let font = UIFont(name: Constants.RegularFont, size: size)!
        let text = NSMutableAttributedString(string: s)
        
        text.applyAttribute(NSFontAttributeName, value: font)
        text.applyAttribute(NSKernAttributeName, value: -0.5)
        text.applyAttribute(NSForegroundColorAttributeName, value: UIColor.nkrReddishOrangeColor())
        
        return text
    }
    
    func createOnOffText() -> NSMutableAttributedString {
        // line height 60
        // letter spacing -0.5
        
        let running = ReminderEngine.reminderEngine.isRunning
        
        let offColor = UIColor.nkrPaleSalmonColor()
        
        let font = UIFont(name: Constants.BoldFont, size: Constants.OnOffButtonSize)!
        let onText = NSMutableAttributedString(string: "on")
        onText.applyAttribute(NSForegroundColorAttributeName, value: running ? Constants.ActiveColor : offColor)
        let offText = NSMutableAttributedString(string: "off")
        offText.applyAttribute(NSFontAttributeName, value: font)
        offText.applyAttribute(NSForegroundColorAttributeName, value: running ? offColor : Constants.ActiveColor)
        
        // combine the two
        onText.appendAttributedString(offText)
        
        onText.applyAttribute(NSFontAttributeName, value: font)
        onText.applyAttribute(Constants.SmartTag, value: "onoff")
        onText.applyAttribute(NSKernAttributeName, value: -1)

        return onText
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
