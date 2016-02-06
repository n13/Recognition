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
    
    @IBOutlet weak var stoppedLabel: UILabel!
    
    var timeFormat: NSDateFormatter {
       let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle;
        formatter.dateStyle = .NoStyle;
        return formatter
    }

    
    let reminderEngine = ReminderEngine.reminderEngine

    // MARK: View
    override func viewDidLoad() {
        updateStartButton()
        updateMainLabelText()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMainLabelText", name: Settings.Notifications.SettingsChanged, object: nil)
        
        // init reminder engine
        ReminderEngine.reminderEngine.initEngine()
        
        stoppedLabel.hidden = true

    }
    
    func updateMainLabelText()  {
        let s = "Remind me \(AppDelegate.delegate().settings.remindersPerDay) times a day, for a 2-5 second recognition session"
        self.mainLabel.text = s
        tableView.reloadData()
    }
    
    // MARK: Actions
    @IBAction func startStopButtonPressed(sender: AnyObject) {
        if (reminderEngine.isRunning) {
            reminderEngine.stop()
        } else {
            reminderEngine.start()
        }
        print((reminderEngine.isRunning ? "running" : "stopped"))
        updateStartButton()
    }
        
    func updateStartButton() {
        if (reminderEngine.isRunning) {
            startStopButton.setTitle("Stop", forState: .Normal)
            startStopButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        } else {
            startStopButton.setTitle("Start", forState: .Normal)
            startStopButton.setTitleColor(nil, forState: .Normal)
        }
        tableView.reloadData()
    }
        
    @IBAction func changeSettingsPushed(sender: UIButton) {
    }
    
//    var filteredDates = [NSDate]() {
//        didSet {
//            tableView.reloadData()
//        }
//    }
//    
//
//    @IBAction func selectorChanged(sender: UISegmentedControl) {
//        filterDates()
//    }
//    
//    func filterDates() {
//        if (tableSelector.selectedSegmentIndex == 2) {
//            filteredDates = reminderEngine.futureReminders
//        } else {
//            let daysAgo = tableSelector.selectedSegmentIndex == 0 ? 0 : 6
//            filteredDates = reminderEngine.futureReminders.filter { $0.daysAgo() <= daysAgo }
//        }
//    }
    
    // MARK: TableView
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return reminderEngine.isRunning ? "Reminder times" : "Stopped. Push Start to start."
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    // MARK: Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderEngine.futureReminders.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TimeCell = tableView.dequeueReusableCellWithIdentifier("tc") as! TimeCell
        let date = reminderEngine.futureReminders[indexPath.row]
        let nowTime = NSDate()
        cell.timeLabel.text = "\(timeFormat.stringFromDate(date))"
        if date.isBeforeHourToday(nowTime) {
            cell.timeLabel.textColor = UIColor.lightGrayColor()
        } else {
            cell.timeLabel.textColor = UIColor.darkGrayColor()
        }
        return cell
    }
    

}
