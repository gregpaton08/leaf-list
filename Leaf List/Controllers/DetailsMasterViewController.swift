//
//  DetailsMasterViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 8/7/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit
import CoreData

class DetailsMasterViewController: UIViewController, TaskDisplay {
    
    // MARK: - API
    
    var task: Task?
    var displayStyle: TaskDisplayStyle = .group
    var showCompleted: Bool = false
    
    // MARK: View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = task?.name

        // Do any additional setup after loading the view.
        for childView in childViewControllers {
            if var taskDisplay = childView as? TaskDisplay {
                taskDisplay.initFromTaskDisplay(self)
            }
        }
    }
}