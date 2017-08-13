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
    
    @IBOutlet weak var detailsTableHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = task?.name

        // Do any additional setup after loading the view.
        updateChildren()
    }
    
    private func updateChildren() {
        for childView in childViewControllers {
            if var taskDisplay = childView as? TaskDisplay {
                taskDisplay.initFromTaskDisplay(self)
            }
            
            if let taskTableView = childView as? TaskTableViewController {
                taskTableView.hasSearchBar = false
                
                // Set the task table view as the navigation controller delegate so that the completed button status can be passed back when this view is popped off the stack.
                navigationController?.delegate = taskTableView
            }
        }
    }
}
