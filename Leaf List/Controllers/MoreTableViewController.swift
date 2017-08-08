//
//  MoreTableViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 8/6/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

class MoreTableViewController: UITableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let taskVC = segue.destination as? TaskTableViewController {
            taskVC.displayStyle = .trash
            taskVC.showCompleted = true
        }
    }

}
