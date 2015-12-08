//
//  MainViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 12/3/15.
//  Copyright © 2015 Nikolaus Heger. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableSelector: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var changeSettingsButton: UIButton!
    @IBOutlet weak var startStopButton: UIButton!

    var isRunning = false
    var expiredReminders = [NSDate]()
    var futureReminders = [NSDate]()
    
    @IBAction func startStopButtonPressed(sender: AnyObject) {
        if (isRunning) {
            isRunning = false
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            futureReminders = [NSDate]()
        } else {
            isRunning = true
            futureReminders = createReminderTimesForToday()
            scheduleNextReminder()
        }
        print((isRunning ? "running" : "stopped"))
        updateStartButton()
    }
    
    func scheduleNextReminder() {
        if futureReminders.count > 0 {
            let date = futureReminders.removeFirst()
            UILocalNotification.scheduleAlert("Take 2-5 seconds to recognize that you exist. Let go of all thoughts.", fireDate: date)
        }
    }
    
    func updateStartButton() {
        if (isRunning) {
            startStopButton.setTitle("Stop", forState: .Normal)
            startStopButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        } else {
            startStopButton.setTitle("Start", forState: .Normal)
            startStopButton.setTitleColor(nil, forState: .Normal)
        }
    }
    
    // this is out data model
    var reminders = [NSDate]()
    
    var filteredDates = [NSDate]() {
        didSet {
            tableView.reloadData()
        }
    }
    

    @IBAction func changeSettingsPushed(sender: UIButton) {
    }
    
    @IBAction func selectorChanged(sender: UISegmentedControl) {
        filterDates()
    }
    
    func filterDates() {
        if (tableSelector.selectedSegmentIndex == 2) {
            filteredDates = reminders
        } else {
            let daysAgo = tableSelector.selectedSegmentIndex == 0 ? 0 : 6
            filteredDates = reminders.filter { $0.daysAgo() <= daysAgo }
        }
    }
    

    override func viewDidLoad() {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDates.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(filteredDates[indexPath.row])"
        return cell
    }
    
    // Model
    func createReminderTimesForToday() -> [NSDate] {
        
        let today = NSDate()
        
        let settings = AppDelegate.delegate().settings
        
        let startTime = NSDate(year: today.year(), month: today.month(), day: today.day(), hour: Int(settings.startTime), minute: 0, second: 0)
        
        print("start: \(startTime.toLocalString())")
        
        let endTime = NSDate(year: today.year(), month: today.month(), day: today.day(), hour: Int(settings.stopTime), minute: 0, second: 0)
        
        print("end: \(endTime.toLocalString()) ")
        
        let totalMinutes: Float = Float(startTime.minutesEarlierThan(endTime))
        let numberOfReminders: Int = Int(settings.remindersPerDay)
        let lowerMinutes = Int(min(totalMinutes/Float(numberOfReminders), settings.intervalMin))
        let upperMinutes = Int(settings.intervalMax)
        
        // create random distribution by projecting a time onto the actual time
        var reminderTimes = [NSDate]()
        var fireTime = startTime
        for _ in 1..<numberOfReminders {
            fireTime = fireTime.dateByAddingMinutes(Int.random(lowerMinutes, upper: upperMinutes))
            if fireTime.isLaterThan(NSDate()) {
                reminderTimes.append(fireTime)
                print("added reminder time: \(fireTime.toLocalString())")
            } else {
                print("ignored reminder time: \(fireTime.toLocalString())")
            }
        }
        return reminderTimes
    }

}
