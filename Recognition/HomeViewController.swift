//
//  HomeViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/25/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {

    var scrollView = UIScrollView()
    var titleLabel = UILabel()
    var textView: UITextView!
    var textHeightConstraint : Constraint? = nil
    let headerInset = Constants.TextInset
    let blockheight = 70

    override func viewDidLoad() {
        
        textView = UITextView.createCustomTextView()
        
        // UX
        setupViews()

        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSettingsChanged:", name: Settings.Notifications.SettingsChanged, object: nil)

        updateStatus(false)
    }
    
    func updateStatus(animated: Bool) {
        textView.attributedText = createMainText()
        
        let running = ReminderEngine.reminderEngine.isRunning
        self.textHeightConstraint!.updateOffset(CGFloat(running ? 1000 : 40))
        if (animated) {
            UIView.animateWithDuration(0.4) {
                self.view.layoutIfNeeded()
            }
        } else {
        }

    }

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
        headerText.applyAttribute(NSFontAttributeName, value: UIFont(name: Constants.ExtraHeavyFont, size: 50)!)
        titleLabel.attributedText = headerText
        scrollView.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { make in
            make.top.equalTo(40) // topLayoutGuide.length seems 0...
            make.leading.equalTo(headerInset)
        }


        // need to draw underline as standard underlines are way too close to the text, which can't be adjusted
        let underline = DashedLineView()
        underline.placeBelowView(titleLabel)

        let underLabel = UILabel()
        let utext = NSMutableAttributedString.mm_attributedString("meditation", sizeAdjustment: 16, isBold: true, kerning: 0.2, color: Constants.BlackTextColor)
        utext.applyAttribute(NSFontAttributeName, value: UIFont(name: Constants.ExtraHeavyFont, size: 50)!)
        underLabel.attributedText = utext
        scrollView.addSubview(underLabel)
        underLabel.snp_makeConstraints { make in
            make.top.equalTo(underline.snp_bottom).offset(-4) // topLayoutGuide.length seems 0...
            make.leading.equalTo(headerInset)
        }


        // Text view
        scrollView.addSubview(textView)
        textView.snp_makeConstraints { make in
            make.top.equalTo(underLabel.snp_bottom).offset(36)
//            make.top.equalTo(underline.snp_bottom).offset(36)
            make.leading.equalTo(scrollView.snp_leading).offset(headerInset)
            make.trailing.equalTo(scrollView.snp_trailing).offset(-headerInset)
            make.width.equalTo(view.snp_width).offset(-headerInset*2)
            
            // text heigh constraint so we can shrink this view
            self.textHeightConstraint = make.height.lessThanOrEqualTo(CGFloat(1000)).constraint // DEBUG remove
        }
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTapOnText:"))

        // Change Settings button
        let changeSettingsButton = UILabel()
        changeSettingsButton.userInteractionEnabled = true
        changeSettingsButton.attributedText = createButtonText(Constants.EditSettingsText)
        scrollView.addSubview(changeSettingsButton)
        changeSettingsButton.snp_makeConstraints { make in
            make.top.equalTo(textView.snp_bottom).offset(15)
            //make.bottom.equalTo(self.view.snp_bottom).offset(-50)
            make.bottom.equalTo(scrollView.snp_bottom).offset(-20)
            make.leading.equalTo(view.snp_leading).offset(headerInset)
        }
        changeSettingsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "changeSettingsPressed:"))
        DashedLineView().placeBelowView(changeSettingsButton)

    }
    
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
    
    func handleSettingsChanged(notification: NSNotification?) {
        print("handle settings changed")
        updateStatus(false)
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
    
    let BaseSize:CGFloat = 32
    let OnOffButtonSize:CGFloat = 34
    
    func createNormalText(s: String) -> NSMutableAttributedString {
        
        // letter spacing -0.9
        // line height 43
        
        let font = UIFont(name: "HelveticaNeue", size: BaseSize)!
        let text = NSMutableAttributedString(string: s)

        text.applyAttribute(NSFontAttributeName, value: font)
        text.applyAttribute(NSKernAttributeName, value: -0.9)
        text.applyAttribute(NSForegroundColorAttributeName, value: UIColor.nkrLogotypeLightColor())

        return text

    }
    
    func createBoldText(s: String) -> NSMutableAttributedString {
        let font = UIFont(name: "HelveticaNeue-Medium", size: BaseSize)!
        let text = NSMutableAttributedString(string: s)
        
        text.applyAttribute(NSFontAttributeName, value: font)
        text.applyAttribute(NSKernAttributeName, value: -1.0)
        text.applyAttribute(NSForegroundColorAttributeName, value: UIColor.nkrLogotypeLightColor())

        return text
    }
    
    func createButtonText(s: String) -> NSMutableAttributedString {
        let font = UIFont(name: "HelveticaNeue", size: OnOffButtonSize)!
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
        
        let font = UIFont(name: "HelveticaNeue", size: OnOffButtonSize)!
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
    
    
}
