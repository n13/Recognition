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
    }
    
    
    //MARK:  TableView stuff
    func rows() -> Int {
        return historyList.count() - 1
    }
    
    func textAtIndex(index: Int) -> String {
        return historyList.array[index+1]
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyList.count() - 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let text = textAtIndex(indexPath.row)
        let cell = tableView.dequeueReusableCellWithIdentifier("ListCell") as! ListCell
        cell.setData(text)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let text = textAtIndex(indexPath.row)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = .Checkmark
        }
        AppDelegate.delegate().settings.setReminderAndUpdateHistory(text)
        doneBlock?(newText: text)
        self.navigationController?.popViewControllerAnimated(true)
    }

}