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


class SettingsViewController: UITableViewController {
    @IBOutlet weak var wakeTimeSlider: NMRangeSlider!
    @IBOutlet weak var numberOfRemindersSlider: NMRangeSlider!
    @IBOutlet weak var reminderTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = AppDelegate.delegate().settings
        
        wakeTimeSlider.minimumValue = 0
        wakeTimeSlider.maximumValue = 24
        wakeTimeSlider.lowerValue = settings.startTime
        wakeTimeSlider.upperValue = settings.stopTime
        wakeTimeSlider.stepValue = 0.5
        wakeTimeSlider.stepValueContinuously = false
        
        wakeTimeSlider.labelTextTransform = { value in
            let hour = Int(value)
            let minute = (value - Float(hour)) >= 0.5 ? "30" : "00"
            return String(format: "%02d", hour) + ":" + minute
        }
        
        numberOfRemindersSlider.minimumValue = 2
        numberOfRemindersSlider.maximumValue = 50
        numberOfRemindersSlider.upperValue = Float(settings.remindersPerDay)
        numberOfRemindersSlider.lowerHandleHidden = true
        numberOfRemindersSlider.stepValue = 1.0
        numberOfRemindersSlider.stepValueContinuously = false

        
        for slider in [wakeTimeSlider, numberOfRemindersSlider] {
           slider.showTextLabelsForValue = true
        }
        
        reminderTextView.text = settings.reminderText
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
}
