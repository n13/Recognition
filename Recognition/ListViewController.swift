import UIKit
import CloudKit

class ListViewController: UITableViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var doneBlock: ((_ newText: String?) -> ())?
    var reminderTexts: [String] = [] {
        didSet {
            if (segmentedControl.selectedSegmentIndex == 1) {
                self.tableView?.reloadData()
            }
        }
    }
    let historyList = AppDelegate.delegate().settings.history

    //MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Choose Reminder Text"
        addCancelButton()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        segmentedControl.tintColor = Constants.ActiveColor
        
        reloadReminderTexts()
    }

    func reloadReminderTexts() {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "ReminderText", predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { results, error in
            if let error = error {
                print("Error fetching ReminderTexts: \(error.localizedDescription)")
                return
            }
            
            guard let records = results else { return }
            
            var reminderTexts: [ReminderText] = []
            for record in records {
                if let reminder = ReminderText(record: record) {
                    reminderTexts.append(reminder)
                    print("foo: \(reminder.text) \(reminder.votes)")
                }
            }
            
            reminderTexts.sort { $0.votes > $1.votes }
            self.reminderTexts = reminderTexts.map { $0.text }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
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
            return historyList.array[index + 1]
        } else {
            return reminderTexts[index]
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentedControl.selectedSegmentIndex == 0 ? historyList.count() - 1 : reminderTexts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text = textAtIndex(indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! ListCell
        cell.setData(text)
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

class ReminderText {
    var recordID: CKRecord.ID?
    var text: String
    var votes: Int64
    
    init(text: String, votes: Int64) {
        self.text = text
        self.votes = votes
    }
    
    init?(record: CKRecord) {
        guard
            let text = record["Text"] as? String,
            let votes = record["Votes"] as? Int64
        else { return nil }
        
        self.recordID = record.recordID
        self.text = text
        self.votes = votes
    }
    
    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: "ReminderText")
        record["Text"] = text as CKRecordValue
        record["Votes"] = votes as CKRecordValue
        return record
    }
}
