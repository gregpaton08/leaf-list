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

        // Do any additional setup after loading the view.
        for childView in childViewControllers {
            if let detailsTableView = childView as? DetailsTableViewController {
                detailsTableView.task = task
            } else if var taskDisplay = childView as? TaskDisplay {
                taskDisplay.task = task
                taskDisplay.displayStyle = displayStyle
                taskDisplay.showCompleted = showCompleted
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
