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
    
    let reminderEngine = ReminderEngine.reminderEngine

    // MARK: View
    override func viewDidLoad() {
        updateStartButton()
        updateMainLabelText()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMainLabelText", name: Settings.Notifications.SettingsChanged, object: nil)
    }
    
    func updateMainLabelText()  {
        let s = "Remind me \(AppDelegate.delegate().settings.remindersPerDay) times a day, for a 2-5 second recognition session"
        self.mainLabel.text = s
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
    }
        
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
            filteredDates = reminderEngine.futureReminders
        } else {
            let daysAgo = tableSelector.selectedSegmentIndex == 0 ? 0 : 6
            filteredDates = reminderEngine.futureReminders.filter { $0.daysAgo() <= daysAgo }
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Reminder times"
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
    

}
