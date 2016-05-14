//
//  ListViewController2.swift
//  Recognition
//
//  Created by Nikolaus Heger on 5/8/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

class ListViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView()
    var headerLabel: UILabel!
    
    // set these
    var titleText: String!
    var doneButtonText: String!
    var doneBlock: ((newText:String?) -> ())?

    
    override func viewDidLoad() {
        //let headerInset = 15
        view.backgroundColor = UIColor.whiteColor()
        headerLabel = createHeaderViews(view, titleText: titleText, doneButtonText: doneButtonText, doneButtonAction: #selector(ListViewController2.cancelButtonPressed(_:)))
        
        
        view.addSubview(tableView)
        tableView.snp_makeConstraints { make in
            make.top.equalTo(headerLabel.snp_bottom).offset(40)
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.bottom.equalTo(0)
        }
        tableView.registerClass(ListCell.self, forCellReuseIdentifier: "ListCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        doneBlock?(newText: nil)
        self.navigationController?.popViewControllerAnimated(true)
        //dismissViewControllerAnimated(true, completion: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
