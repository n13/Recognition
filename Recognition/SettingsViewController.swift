//
//  MainViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 11/16/15.
//  Copyright © 2015 Nikolaus Heger. All rights reserved.
//

import UIKit
import NMRangeSlider
import SnapKit
import DateTools
import MessageUI


class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var wakeTimeSlider: NMRangeSlider!
    @IBOutlet weak var numberOfRemindersSlider: NMRangeSlider!
    @IBOutlet weak var reminderTextView: UITextView!
    @IBOutlet weak var feedbackButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = AppDelegate.delegate().settings
        
        let trackImage = UIImage.add_imageWithColor(Constants.ActiveColor, size: CGSize(width: 6, height: 2), cornerRadius: 1.0)

        
        wakeTimeSlider.minimumValue = 0
        wakeTimeSlider.maximumValue = 24
        wakeTimeSlider.lowerValue = settings.startTime
        wakeTimeSlider.upperValue = settings.stopTime
        wakeTimeSlider.stepValue = 0.5
        wakeTimeSlider.stepValueContinuously = false
        
        wakeTimeSlider.trackImage = trackImage
            
        wakeTimeSlider.labelTextTransform = { value in
            
            var fraction = (value - (Float(Int(value))))
            fraction *= 2
            
            
            let date = NSDate.hourAsDateToday(value)
            return Constants.timeFormat.stringFromDate(date)
        }
        
        numberOfRemindersSlider.minimumValue = 2
        numberOfRemindersSlider.maximumValue = 50
        numberOfRemindersSlider.upperValue = Float(settings.remindersPerDay)
        numberOfRemindersSlider.lowerHandleHidden = true
        numberOfRemindersSlider.stepValue = 1.0
        numberOfRemindersSlider.stepValueContinuously = false
        numberOfRemindersSlider.trackImage = trackImage

        
        for slider in [wakeTimeSlider, numberOfRemindersSlider] {
           slider.showTextLabelsForValue = true
        }
        
        reminderTextView.text = settings.reminderText
        
        feedbackButton.tintColor = Constants.ActiveColor
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
//        print("done!")
        let settings = AppDelegate.delegate().settings
        settings.startTime = wakeTimeSlider.lowerValue
        settings.stopTime = wakeTimeSlider.upperValue
        settings.remindersPerDay = Int(numberOfRemindersSlider.upperValue)
        settings.reminderText = reminderTextView.text!
        settings.save()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Feedback Email
    @IBAction func feedbackButtonPressed(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["nheger+feedback@gmail.com"])
        mailComposerVC.setSubject("Reminders App Feedback")
        mailComposerVC.setMessageBody("Love it/Hate it/Missing feature X...", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }

    
    
}
