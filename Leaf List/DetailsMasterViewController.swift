//
//  DetailsMasterViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 8/7/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit
import CoreData

class DetailsMasterViewController: UIViewController {
    
    // MARK: - API
    
    var task: Task?
    var showCompletedTasks = false
    
    // MARK: View

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for childView in childViewControllers {
            if let detailsTableView = childView as? DetailsTableViewController {
                detailsTableView.task = task
            } else if let taskTableView = childView as? TaskTableViewController {
                taskTableView.parentTask = task
                taskTableView.showCompletedTasks = showCompletedTasks
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
