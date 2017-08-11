//
//  MoreTableViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 8/6/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

class MoreTableViewController: UITableViewController {
    
    @IBAction func emptyTrashButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Empty Trash?", message: "Are you sure you want to empty the trash? This action cannot be undone.", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            
        }
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            // Delete tasks in trash
        }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let taskVC = segue.destination as? TaskTableViewController {
            taskVC.displayStyle = .trash
            taskVC.showCompleted = true
        }
    }

}
