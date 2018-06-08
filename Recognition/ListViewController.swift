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

    var doneBlock: ((_ newText:String?) -> ())?
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
        tableView.separatorStyle = .none
        segmentedControl.tintColor = Constants.ActiveColor
        
        reloadReminderTexts()
        
    }
    func reloadReminderTexts() {
        // test EV cloud kit dao
        dao.query(ReminderText()
            , completionHandler: { results, finished in
                
                for result in results {
                    print("foo: "+result.Text + " \(result.Votes)")
                }
                
                EVLog("query : result count = \(results.count)")
                
                var reminderTexts = results
                reminderTexts.sort { rt1, rt2 in
                    rt1.Votes > rt2.Votes
                }
                self.reminderTexts = reminderTexts.map { $0.Text }
                return true
            }, errorHandler: { error in
                EVLog("<--- ERROR query Message")
        })
        

    }
    
    //MARK: Actions
    @IBAction func segmentedControlSelected(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    //MARK:  TableView stuff
    func rows() -> Int {
        return segmentedControl.selectedSegmentIndex == 0 ? historyList.count() - 1 : reminderTexts.count
    }
    
    func textAtIndex(_ index: Int) -> String {
        if segmentedControl.selectedSegmentIndex == 0 {
            return historyList.array[index+1]
        } else {
            return reminderTexts[index]
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentedControl.selectedSegmentIndex == 0 ?
        historyList.count() - 1 :
        reminderTexts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text = textAtIndex(indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! ListCell
        cell.setData(text)
        cell.accessoryType = .checkmark
        cell.accessoryType = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = textAtIndex(indexPath.row)
        AppDelegate.delegate().settings.setReminderAndUpdateHistory(text)
        self.navigationController?.popViewController(animated: true)
        doneBlock?(text)
    }
    
    // TODO 
    // switch between
    
}
