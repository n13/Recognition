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
    var errorLabel: UILabel?
    var textHeightConstraint : Constraint? = nil
    var changeSettingsButtonBottomOffsetConstraint : Constraint? = nil
    let headerInset = Constants.TextInset
    let blockheight = 70
    let offsetFromBottom:CGFloat = 88//Constants.isIpad() ? 166 : 60

    var alertVC: UIAlertController?

    // MARK: View
    override func viewDidLoad() {
        
        // UX
        setupViews()
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.handleSettingsChanged(_:)), name: Settings.Notifications.SettingsChanged, object: nil)

        updateStatus(false)
        
        // listen to notifications coming in
        addObserverForNotification(Constants.LocalNotificationArrived, selector:  #selector(HomeViewController.handleIncomingNotification))
        
        // listen to the user answering notifications dialog
        addObserverForNotification(Constants.UserAnsweredNotificationsDialog, selector:  #selector(HomeViewController.handleUserAnsweredNotificationsDialog))
        addObserverForNotification(UIApplicationDidBecomeActiveNotification, selector:  #selector(HomeViewController.handleApplicationDidBecomeActive))        
        
        // debug test cloud kit
        
//        CKContainer *myContainer = [CKContainer defaultContainer];
//        CKDatabase *publicDatabase = [myContainer publicCloudDatabase];

        /*
        let container = CKContainer(identifier: "iCloud.com.recognitionmeditation")
        let publicDatabase = container.publicCloudDatabase
        let query = CKQuery(recordType: "ReminderText", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        
        publicDatabase.performQuery(query, inZoneWithID: nil) { results, error in
            print("found: \(results)")
            print("error: \(error)")
        }
        */
    }
    
    func handleApplicationDidBecomeActive() {
        //print("app is becoming active - check notification status")
        // Note: If this fails, then worst case we show the dialog too much - that's OK
        // The worst that can happen is that we show the dialog when we launch for the first time
        // But that does not appear to happen. 
        updateStatus(false)
    }
    
    func handleUserAnsweredNotificationsDialog() {
        //print("user answered notifications dialog... checking for notification settings!")
        updateStatus(false)
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
        super.viewDidAppear(animated)
        if (AppDelegate.delegate().notificationState == .AskedAndAnswered) {
            print("checking on notifications")
            checkNotificationsAreEnabled()
        }
        // bounce
//        if (!Constants.isIpad()) {
//            UIView.setAnimationDelay(1.0)
//            bounceMenu()
//        }
    }
    
    func bounceMenu_DISABLED() {
        let screenSize = UIScreen.mainScreen().bounds.size
        self.changeSettingsButtonBottomOffsetConstraint?.updateOffset(screenSize.height - 166)
        let duration = 0.2
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut)
        UIView.animateWithDuration(duration,
                                   animations: {
                                    print("bouncing up")
                                    self.view.layoutIfNeeded()
            },
                                   completion: { b in
                                    self.changeSettingsButtonBottomOffsetConstraint?.updateOffset(screenSize.height - self.offsetFromBottom)
                                    UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
                                    UIView.animateWithDuration(duration) {
                                        print("bouncing down")
                                        self.view.layoutIfNeeded()
                                    }
        })
        
    }
    
    func checkNotificationsAreEnabled() -> Bool {
        // check notification status - except not on first launch. 
        // On first launch the user will be presented with the system notifications dialog. So we don't check or 
        // Do anything
        if (AppDelegate.delegate().notificationState != .AskedAndAnswered) {
            return true
        }
        
        if let settings = UIApplication.sharedApplication().currentUserNotificationSettings() {
            if settings.types.rawValue == UIUserNotificationType.None.rawValue {
                print("Notifications disabled")
                return false;
            } else {
                return true
            }
        } else {
            // unable to figure it out, assume they're on - this should never happen
            print("Error: unable to determine notifications state!")
            return true
        }
    }
    
    // MARK: UX State
    func updateStatus(animated: Bool) {
        let running = ReminderEngine.reminderEngine.isRunning
        let notificationsEnabled = checkNotificationsAreEnabled()
        
        showHideErrorLabel(!notificationsEnabled)
        
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
                    self.textHeightConstraint!.updateOffset(CGFloat(running && notificationsEnabled ? 1000 : Constants.ShortTextHeight))
                    UIView.animateWithDuration(0.4) {
                        self.view.layoutIfNeeded()
                    }
            })
            
        } else {
            self.textView.attributedText = self.createMainText()
            self.textHeightConstraint!.updateOffset(CGFloat(running && notificationsEnabled ? 1000 : Constants.ShortTextHeight))
        }

    }

    // MARK: UX Generation
    func setupViews() {
        self.automaticallyAdjustsScrollViewInsets = false
        
        // scroll view
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delaysContentTouches = false
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
        textView = UITextView.createCustomTextView()
        textView.scrollEnabled = false
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
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeViewController.handleTapOnText(_:))))
        textView.attributedText = createMainText()

        let screenSize = UIScreen.mainScreen().bounds.size
        
        // buttons
        let buttons = [
            addLabelButton(Constants.EditSettingsText, action: #selector(HomeViewController.changeSettingsPressed(_:))),
            addLabelButton("Share.", action: #selector(HomeViewController.shareButtonPressed(_:))),
            addLabelButton("How to.", action: #selector(HomeViewController.howButtonPressed(_:))),
            addLabelButton("Send feedback.", action: #selector(HomeViewController.sendFeedbackPressed(_:)))
        ]
        let howToOffset:CGFloat = 20//Constants.isIpad() ? 20 : 28

        // space out the buttons vertically
        for (index, button) in buttons.enumerate() {
            button.snp_makeConstraints { make in
                if (index == 0) {
                    changeSettingsButtonBottomOffsetConstraint = make.bottom.equalTo(self.scrollView.snp_top).offset(screenSize.height - offsetFromBottom).constraint
                } else {
                    make.top.equalTo(buttons[index-1].snp_bottom).offset(howToOffset)
                }
                make.leading.equalTo(view.snp_leading).offset(headerInset)
                if (index == buttons.count-1) {
                    make.bottom.equalTo(self.scrollView.snp_bottom).offset(-20)
                }
            }
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

    func changeSettingsPressed(sender: UIGestureRecognizer) {
        print("change settings")
        let vc = SmartTextViewController.createMain()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalTransitionStyle = .FlipHorizontal
        //vc.modalTransitionStyle = .FlipHorizontal
        presentViewController(nav, animated: true, completion: nil)

    }

    func shareButtonPressed(sender: UIGestureRecognizer) {
        print("share")
        let textToShare = "I love the Recognition Meditation app - check it out!"
        let vc = SmartTextViewController.createMain()

        let screenShotImage = vc.takeScreenshot()

        if let myWebsite = NSURL(string: "https://itunes.apple.com/us/app/recognition-meditation/id1085370087") {
            let objectsToShare = [textToShare, screenShotImage!, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
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

    func onOffPressed() {
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
        
        return attributedText
    }
    
    func showHideErrorLabel(show: Bool) {
        if errorLabel != nil && !show {
            errorLabel?.removeFromSuperview()
            scrollView.viewWithTag(33)?.removeFromSuperview()
            errorLabel = nil
        } else if (show && errorLabel == nil) {
            let label = UILabel()
            label.numberOfLines = 0
            label.attributedText = createButtonText("Notifications are off so you will not receive any reminders. Tap here to turn on notifications in System Settings", size: 20)
            scrollView.addSubview(label)
            label.snp_makeConstraints { make in
                make.top.equalTo(self.textView.snp_bottom).offset(20)
                make.leading.equalTo(scrollView.snp_leading).offset(headerInset)
                make.trailing.equalTo(scrollView.snp_trailing).offset(-headerInset)
            }
            label.userInteractionEnabled = true
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeViewController.errorLabelTapped)))
            errorLabel = label
            let underline = DashedLineView()
            underline.placeBelowView(label)
            underline.tag = 33
        }
    }
    
    func errorLabelTapped() {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
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
        let onColor = Constants.ActiveColor
        
        let font = UIFont(name: Constants.BoldFont, size: Constants.OnOffButtonSize)!
        let onText = NSMutableAttributedString(string: "on")
        onText.applyAttribute(NSForegroundColorAttributeName, value: running ? onColor : offColor)
        let offText = NSMutableAttributedString(string: "off")
        offText.applyAttribute(NSFontAttributeName, value: font)
        offText.applyAttribute(NSForegroundColorAttributeName, value: running ? offColor : onColor)
        
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
