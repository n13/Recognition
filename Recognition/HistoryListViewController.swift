//
//  HistoryListViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 5/8/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//


class HistoryListViewController: ListViewController2 {
    
    let historyList = AppDelegate.delegate().settings.history

    override func viewDidLoad() {
        titleText = "History"
        doneButtonText = "cancel"
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    
    //MARK:  TableView stuff
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func rows() -> Int {
        return historyList.count()
    }
    
    func textAtIndex(indexPath: NSIndexPath) -> String {
        return indexPath.section == 0 ? historyList.array[indexPath.row] : Constants.DefaultReminderText
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? historyList.count() : 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let text = textAtIndex(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier("ListCell") as! ListCell
        cell.setData(text)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let text = textAtIndex(indexPath)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = .Checkmark
        }
        AppDelegate.delegate().settings.setReminderAndUpdateHistory(text)
        doneBlock?(newText: text)
        self.navigationController?.popViewControllerAnimated(true)
    }

}