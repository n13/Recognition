//
//  MainViewController.swift
//  Recognition
//
//  Created by Nikolaus Heger on 11/16/15.
//  Copyright © 2015 Nikolaus Heger. All rights reserved.
//

import UIKit
import NMRangeSlider
import SnapKit

class MainViewController: UITableViewController {
    @IBOutlet weak var wakeTimeSlider: NMRangeSlider!
    @IBOutlet weak var intervalSlider: NMRangeSlider!
    @IBOutlet weak var numberOfRemindersSlider: NMRangeSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wakeTimeSlider.minimumValue = 0
        wakeTimeSlider.maximumValue = 24
        wakeTimeSlider.lowerValue = 8
        wakeTimeSlider.upperValue = 21
        wakeTimeSlider.minimumRange = 1
        
        intervalSlider.minimumValue = 2
        intervalSlider.maximumValue = 120
        intervalSlider.lowerValue = 10
        intervalSlider.upperValue = 60
        intervalSlider.minimumRange = 1

        numberOfRemindersSlider.minimumValue = 2
        numberOfRemindersSlider.maximumValue = 30
        numberOfRemindersSlider.upperValue = 12
        numberOfRemindersSlider.lowerHandleHidden = true
        
        for slider in [wakeTimeSlider, intervalSlider, numberOfRemindersSlider] {
           slider.showTextLabelsForValue = true
            //            slider.snp_makeConstraints { make in
//                make.edges.equalTo(UIEdgeInsets(top: 10,left: 10,bottom: 10, right: 10))
//            }
            
        }
    }
    
}
