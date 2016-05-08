//
//  ListViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 5/4/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

import EVCloudKitDao

class ListViewController: UITableViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var doneBlock: ((newText:String?) -> ())?
    var reminderTexts: [String] = [] {
        didSet {
            if (segmentedControl.selectedSegmentIndex == 1) {
                self.tableView?.reloadData()
            }
        }
    }
    let historyList = AppDelegate.delegate().settings.history

    let dao: EVCloudKitDao = EVCloudKitDao.publicDBForContainer("iCloud.com.recognitionmeditation")

    //MARK: View
    override func viewDidLoad() {
        title = "Choose Reminder Text"
        addCancelButton()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .None
        segmentedControl.tintColor = Constants.ActiveColor
        
        reloadReminderTexts()
        
    }
    func reloadReminderTexts() {
        // test EV cloud kit dao
        dao.query(ReminderText()
            , completionHandler: { results in
                
                for result in results.results {
                    print("foo: "+result.Text + " \(result.Votes)")
                }
                
                EVLog("query : result count = \(results.results.count)")
                
                var reminderTexts = results.results
                reminderTexts.sortInPlace { rt1, rt2 in
                    rt1.Votes > rt2.Votes
                }
                self.reminderTexts = reminderTexts.map { $0.Text }
                return true
            }, errorHandler: { error in
                EVLog("<--- ERROR query Message")
        })
        

    }
    
    //MARK: Actions
    @IBAction func segmentedControlSelected(sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    //MARK:  TableView stuff
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
        doneBlock?(newText: text)
    }
    
    // TODO 
    // switch between
    
}
