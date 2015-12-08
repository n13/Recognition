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
    @IBOutlet weak var intervalSlider: NMRangeSlider!
    @IBOutlet weak var numberOfRemindersSlider: NMRangeSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wakeTimeSlider.minimumValue = 0
        wakeTimeSlider.maximumValue = 24
        wakeTimeSlider.lowerValue = 8
        wakeTimeSlider.upperValue = 21
        
        wakeTimeSlider.labelTextTransform = { value in
            let hour = Int(value)
            let minute = (value - Float(hour)) >= 0.5 ? "30" : "00"
            return String(format: "%02d", hour) + ":" + minute
        }
        
        //wakeTimeSlider.minimumRange = 1
        
        intervalSlider.minimumValue = 2
        intervalSlider.maximumValue = 120
        intervalSlider.lowerValue = 10
        intervalSlider.upperValue = 60
        //intervalSlider.minimumRange = 1

        numberOfRemindersSlider.minimumValue = 2
        numberOfRemindersSlider.maximumValue = 30
        numberOfRemindersSlider.upperValue = 12
        numberOfRemindersSlider.lowerHandleHidden = true
        
        for slider in [wakeTimeSlider, intervalSlider, numberOfRemindersSlider] {
           slider.showTextLabelsForValue = true
            //            slider.snp_makeConstraints { make in
//                make.edges.equalTo(UIEdgeInsets(top: 10,left: 10,bottom: 10, right: 10))
//            }
            
        }
    }
    @IBAction func doneButtonPressed(sender: AnyObject) {
        print("done!")
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func goButtonPressed(sender: UIButton) {
        
        let today = NSDate()
        
        let startTime = NSDate(year: today.year(), month: today.month(), day: today.day(), hour: Int(wakeTimeSlider.lowerValue), minute: 0, second: 0)
        
        print("start: \(startTime.toLocalString())")

        let endTime = NSDate(year: today.year(), month: today.month(), day: today.day(), hour: Int(wakeTimeSlider.upperValue), minute: 0, second: 0)

        
        print("end: \(endTime.toLocalString()) ")

        let totalMinutes: Float = Float(startTime.minutesEarlierThan(endTime))
        let numberOfReminders: Int = Int(numberOfRemindersSlider.upperValue)
        let lowerMinutes = Int(min(totalMinutes/Float(numberOfReminders), intervalSlider.minimumValue))
        let upperMinutes = Int(intervalSlider.upperValue)

        
        // create random distribution by projecting a time onto the actual time
        
        var reminderTimes = [NSDate]()
        var fireTime = startTime
        for _ in 1..<numberOfReminders {
            fireTime = fireTime.dateByAddingMinutes(Int.random(lowerMinutes, upper: upperMinutes))
            reminderTimes.append(fireTime)
            print("time: \(fireTime.toLocalString())")
        }
        
        
        
    }
}
