//
//  ListViewController2.swift
//  Recognition
//
//  Created by Nikolaus Heger on 5/8/16.
//  Copyright © 2016 Nikolaus Heger. All rights reserved.
//

class ListViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView()
    
    // set these
    var titleText: String!
    var doneButtonText: String!
    var doneBlock: ((_ newText:String?) -> ())?

    
    override func viewDidLoad() {
        //let headerInset = 15
        view.backgroundColor = UIColor.white
        let headerViews = createHeaderViews(view, titleText: titleText, doneButtonText: doneButtonText, doneButtonAction: #selector(ListViewController2.cancelButtonPressed(_:)))
                
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerViews.headerLabel.snp.bottom).offset(10)
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.bottom.equalTo(0)
        }
        tableView.register(ListCell.self, forCellReuseIdentifier: "ListCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        doneBlock?(nil)
        self.navigationController?.popViewController(animated: true)
        //dismissViewControllerAnimated(true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
