//
//  MoreTableViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 8/6/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit
import CoreData

class MoreTableViewController: UITableViewController {
    
    @IBAction func emptyTrashButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Empty Trash?", message: "Are you sure you want to empty the trash? This action cannot be undone.", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            let context = AppDelegate.viewContext
            context.perform({
                let request: NSFetchRequest<Task> = Task.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "dateDeleted", ascending: false)]
                request.predicate = NSPredicate(format: "taskDeleted == YES")
                
                let deletedTasks = try? context.fetch(request)
                deletedTasks?.forEach({ (task) in
                    context.delete(task)
                })
                
                try? context.save()
            })
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
