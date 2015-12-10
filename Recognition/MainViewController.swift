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

    var isRunning: Bool {
        get {
            return AppDelegate.delegate().settings.running
        }
        set(value) {
            AppDelegate.delegate().settings.running = value
        }
    }
    
    var expiredReminders = [NSDate]()
    var futureReminders = [NSDate]()
    
    // MARK: View
    override func viewDidLoad() {
        updateStartButton()
    }
    
    // MARK: Actions
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
            var date = futureReminders.removeFirst()
            
            print("now time: \(NSDate())")
            print("next reminder fires at: \(date)")
            
            // TODO: Remove. This is for debugging. Fire in 3 seconds
            date = NSDate().dateByAddingSeconds(3)
            
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
    

    // MARK: Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDates.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(filteredDates[indexPath.row])"
        return cell
    }
    
    
    // MARK: Model
    func createReminderTimesForToday() -> [NSDate] {
        
        let nowTime = NSDate()
        
        let settings = AppDelegate.delegate().settings
        
        var startTime = NSDate(year: nowTime.year(), month: nowTime.month(), day: nowTime.day(), hour: Int(settings.startTime), minute: 0, second: 0)
        
        print("start: \(startTime.toLocalString())")
        
        let endTime = NSDate(year: nowTime.year(), month: nowTime.month(), day: nowTime.day(), hour: Int(settings.stopTime), minute: 0, second: 0)
        
        print("end: \(endTime.toLocalString()) ")
        
        let totalMinutes: Float = Float(endTime.minutesLaterThan(startTime))
        var numberOfReminders: Int = Int(settings.remindersPerDay)
        let lowerMinutes = Int(min(totalMinutes/Float(numberOfReminders), settings.intervalMin))
        let upperMinutes = Int(settings.intervalMax)
        
        // app starts in the middle of the day, only do some of the reminders
        if nowTime.isLaterThan(startTime) {
            let minutesExpired = Float(nowTime.minutesLaterThan(startTime))
            let numberOfRemindersRemaining = Float(numberOfReminders) * (1 - (minutesExpired / totalMinutes))
            numberOfReminders = Int(ceil(numberOfRemindersRemaining))
            startTime = nowTime
        }
        
        // create random distribution by projecting a time onto the actual time
        var reminderTimes = [NSDate]()
        var fireTime = startTime
        for _ in 0..<numberOfReminders {
            fireTime = fireTime.dateByAddingMinutes(Int.random(lowerMinutes, upper: upperMinutes))
            if fireTime.isEarlierThan(NSDate()) {
                reminderTimes.append(fireTime)
                print("added reminder time: \(fireTime.toLocalString())")
            } else {
                print("ignored reminder time: \(fireTime.toLocalString())")
            }
        }
        return reminderTimes
    }

}
