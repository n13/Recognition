//
//  ListViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 5/4/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

class ListViewController: UITableViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var reminderTexts: [String] = []
    let historyList = AppDelegate.delegate().settings.history

    //MARK: View
    override func viewDidLoad() {
        title = "Choose Reminder Text"
        addCancelButton()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        segmentedControl.tintColor = Constants.ActiveColor
        
    }
    
    
    //MARK: Actions
    @IBAction func segmentedControlSelected(sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    // list shit
    func rows() -> Int {
        return segmentedControl.selectedSegmentIndex == 0 ? historyList.count() - 1 : reminderTexts.count
    }
    
    func textAtIndex(index: Int) -> String {
        if segmentedControl.selectedSegmentIndex == 0 {
            return historyList.array[index+1]
        } else {
            return reminderTexts[index]
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentedControl.selectedSegmentIndex == 0 ?
        historyList.count() - 1 :
        reminderTexts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let text = textAtIndex(indexPath.row)
        let cell = tableView.dequeueReusableCellWithIdentifier("ListCell") as! ListCell
        cell.setData(text)
        cell.accessoryType = .Checkmark
        cell.accessoryType = .None
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let text = textAtIndex(indexPath.row)
        AppDelegate.delegate().settings.setReminderAndUpdateHistory(text)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // TODO 
    // switch between
    
}
