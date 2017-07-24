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
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 2
    }

    func rows() -> Int {
        return historyList.count()
    }
    
    func textAtIndex(_ indexPath: IndexPath) -> String {
        return indexPath.section == 0 ? historyList.array[indexPath.row] : Constants.DefaultReminderText
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? historyList.count() : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text = textAtIndex(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! ListCell
        cell.setData(text)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let text = textAtIndex(indexPath)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        AppDelegate.delegate().settings.setReminderAndUpdateHistory(text)
        doneBlock?(text)
        self.navigationController?.popViewController(animated: true)
    }

}
