//
//  MainViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 12/3/15.
//  Copyright © 2015 Nikolaus Heger. All rights reserved.
//

import Cocoa

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableSelector: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var changeSettingsButton: UIButton!
    
    var reminders = [NSDaste]()
    

    @IBAction func changeSettingsPushed(sender: UIButton) {
    }
    
    @IBAction func selectorChanged(sender: UISegmentedControl) {
    }
    

    func viewDidLoad() {
        
    }
    
}
