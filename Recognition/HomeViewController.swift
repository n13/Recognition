//
//  HomeViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 2/25/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        
        // UX
        setupViews()

        updateStatus()
    }
    
    var scrollView = UIScrollView()
    var titleLabel = UILabel()
    var statusLabel = UILabel()
    
    let headerInset = Constants.TextInset
    let blockheight = 70

    var remindersPerDayBlock: BlockView!
    var remainingBlock: BlockView!
    var nextReminderBlock: BlockView!

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
        headerText.applyAttribute(NSUnderlineColorAttributeName, value: Constants.ActiveColor)
        headerText.applyAttribute(NSFontAttributeName, value: UIFont(name: Constants.ExtraHeavyFont, size: 50)!)
        titleLabel.attributedText = headerText
        scrollView.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { make in
            make.top.equalTo(40) // topLayoutGuide.length seems 0...
            make.leading.equalTo(headerInset)
            make.trailing.equalTo(-headerInset)
        }

        // need to draw underline as standard underlines are way too close to the text, which can't be adjusted
        let underline = DashedLineView()
        underline.dashShape.strokeColor = Constants.ActiveColor.CGColor
        underline.dashShape.lineWidth = 4
        scrollView.addSubview(underline)
        underline.snp_makeConstraints { make in
            make.top.equalTo(titleLabel.snp_baseline).offset(15)
            make.left.equalTo(titleLabel.snp_left)
            make.right.equalTo(titleLabel.snp_right)
        }
        
        // top label
        let headerLabel = UILabel()
        headerLabel.numberOfLines = 0
        headerLabel.attributedText = NSMutableAttributedString.mm_attributedString("2-5 second\nmeditation", sizeAdjustment: 6, isBold: true, kerning: -0.6, color: Constants.GreyTextColor, lineHeightMultiple: 0.8)
        scrollView.addSubview(headerLabel)
        headerLabel.snp_makeConstraints { make in
            make.top.equalTo(underline.snp_bottom).offset(20) // topLayoutGuide.length seems 0...
            make.leading.equalTo(headerInset)
            make.trailing.equalTo(-headerInset)
        }
        
        

        
        // status text
//        statusLabel.numberOfLines = 0
//        statusLabel.attributedText = createStatusText()
//        scrollView.addSubview(statusLabel)
//        statusLabel.snp_makeConstraints { make in
//            make.top.equalTo(titleLabel.snp_baseline).offset(45)
//            make.leading.equalTo(view.snp_leading).offset(headerInset)
//            make.trailing.equalTo(view.snp_trailing).offset(-headerInset)
//        }
        
        // 
        
        remindersPerDayBlock = createBlockView("times per day")
        remindersPerDayBlock.setNumberText("12") // debug
        remindersPerDayBlock.snp_makeConstraints { make in
            //make.top.equalTo(titleLabel.snp_baseline).offset(45)
            make.top.equalTo(headerLabel.snp_baseline).offset(0)
        }
        
        remainingBlock = createBlockView("remaining")
        remainingBlock.setNumberText("2") // debug
        remainingBlock.snp_makeConstraints { make in
            make.top.equalTo(remindersPerDayBlock.snp_bottom).offset(0)
        }
        
        nextReminderBlock = createBlockView("next")
        nextReminderBlock.labelOnLeft = true
        nextReminderBlock.setNumberText("12:20 AM") // debug
        nextReminderBlock.snp_makeConstraints { make in
            make.top.equalTo(remainingBlock.snp_bottom).offset(0)
        }
        
        //remindersPerDayBlock.backgroundColor = UIColor.yellowColor()
        
        // Change Settings button
        let changeSettingsButton = UIButton()
        changeSettingsButton.setTitle("Change Settings", forState: .Normal)
        changeSettingsButton.setTitleColor(Constants.ActiveColor, forState: .Normal)
        scrollView.addSubview(changeSettingsButton)
        changeSettingsButton.snp_makeConstraints { make in
            make.bottom.equalTo(view.snp_bottom).offset(-20)
            make.leading.equalTo(view.snp_leading).offset(headerInset)
            make.trailing.equalTo(view.snp_trailing).offset(-headerInset)
            make.height.equalTo(40)
        }
        changeSettingsButton.layer.borderWidth = 2
        changeSettingsButton.layer.borderColor = Constants.ActiveColor.CGColor
        changeSettingsButton.addTarget(self, action: "changeSettingsPressed:", forControlEvents: .TouchUpInside)
        
        // On/Off button
        let onOffLabel = UIView()
        scrollView.addSubview(onOffLabel)
        onOffLabel.snp_makeConstraints { make in
            make.bottom.equalTo(changeSettingsButton.snp_top).offset(-15)
            make.height.equalTo(changeSettingsButton.snp_height)
            make.leading.equalTo(view.snp_leading).offset(headerInset)
            make.trailing.equalTo(view.snp_trailing).offset(-headerInset)
        }
        onOffLabel.layer.borderWidth = 2
        onOffLabel.layer.borderColor = Constants.ActiveColor.CGColor

        let label = UILabel()
        label.text = "Notifications"
        label.textColor = Constants.ActiveColor
        onOffLabel.addSubview(label)
        label.snp_makeConstraints { make in
            make.edges.equalTo(onOffLabel).inset(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
        }

        let button = UISwitch()
        onOffLabel.addSubview(button)
        button.snp_makeConstraints { make in
            make.trailing.equalTo(-15)
            make.centerY.equalTo(0)
        }
        button.addTarget(self, action: "onOffPressed:", forControlEvents: .ValueChanged)
        button.on = ReminderEngine.reminderEngine.isRunning
        

    }
    
    func createBlockView(labelText: String) -> BlockView {
        let chunk = BlockView()
        chunk.setLabelText(labelText)
        scrollView.addSubview(chunk)
        chunk.snp_makeConstraints { make in
            make.leading.equalTo(view.snp_leading).offset(headerInset)
            make.trailing.equalTo(view.snp_trailing).offset(-headerInset)
            make.height.equalTo(blockheight)
        }

        return chunk
    }
    
    
    func changeSettingsPressed(sender: UIButton) {
        print("change settings")
        let vc = SmartTextViewController.createMain()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalTransitionStyle = .FlipHorizontal
        presentViewController(nav, animated: true, completion: nil)

    }
    
    func onOffPressed(sender: UISwitch) {
        print("on off")
        if sender.on != ReminderEngine.reminderEngine.isRunning {
            if (ReminderEngine.reminderEngine.isRunning) {
                ReminderEngine.reminderEngine.stop()
            } else {
                ReminderEngine.reminderEngine.start()
            }
        }
        statusLabel.attributedText = createStatusText()
    }
    
    func updateStatus() {
        let reminderEngine = ReminderEngine.reminderEngine
        let numReminders = reminderEngine.futureReminders.count
        let running = reminderEngine.isRunning
        let startTime = reminderEngine.startTimeAsDate()
        let endTime = reminderEngine.endTimeAsDate()
        let nextReminderDate = reminderEngine.nextReminderToday()
        let remindersRemainingToday = reminderEngine.remindersRemainingToday()
        let remindersRemainingTodayString = remindersRemainingToday > 0 ? "\(remindersRemainingToday)" : "no"
        
        remindersPerDayBlock.setNumberText("\(numReminders)")
        remainingBlock.setNumberText("\(remindersRemainingToday)")
        if (nextReminderDate != nil) {
            nextReminderBlock.setNumberText("\(nextReminderDate!.asHoursString().lowercaseString)")
        } else {
            nextReminderBlock.setNumberText("")
        }
    }


    func createStatusText() -> NSMutableAttributedString {
        let reminderEngine = ReminderEngine.reminderEngine
        let numReminders = reminderEngine.futureReminders.count
        let running = reminderEngine.isRunning
        let startTime = reminderEngine.startTimeAsDate()
        let endTime = reminderEngine.endTimeAsDate()
        let nextReminderDate = reminderEngine.nextReminderToday()
        let remindersRemainingToday = reminderEngine.remindersRemainingToday()
        let remindersRemainingTodayString = remindersRemainingToday > 0 ? "\(remindersRemainingToday)" : "no"
        
        var text: NSMutableAttributedString
        if reminderEngine.isRunning {
            var nextReminderString: String? = nil
            if let nextReminderDate = nextReminderDate {
                nextReminderString = "The next reminder is at "+nextReminderDate.asHoursString()
            } else if reminderEngine.futureReminders.count > 0 {
                nextReminderString = "The next reminder is tomorrow at " + reminderEngine.futureReminders[0].asHoursString()
            }
            
            text = NSMutableAttributedString.mm_attributedString("Reminders are enabled\n")
            
            //let betweenT = "between \(startTime.asHoursString()) and \(endTime.asHoursString())\n"
            
            text.appendText("We will send you \(numReminders) reminders per day.\n")
            text.appendText("\(remindersRemainingTodayString) more reminders today.\n")
            if (nextReminderString != nil) {
                text.appendText("\(nextReminderString!)")
            }
        } else {
            text = NSMutableAttributedString.mm_attributedString("Reminders are disabled\n")
        }
        
        text.applyAttribute(NSFontAttributeName, value: UIFont(name: Constants.LightFont, size: 20)!)
        
        return text
    }
    
}
