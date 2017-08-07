//
//  DetailsTableViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 8/7/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit
import CoreData

class DetailsTableViewController: UITableViewController {

    // MARK: - API
    
    var task: Task? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - UI
    
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var dateCreatedCell: UITableViewCell!
    
    private func updateUI() {
        if isViewLoaded {
            taskNameTextField.text = task?.name ?? "ERROR!"
            dateCreatedCell.textLabel?.text = formatDate(task?.dateCreated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let notesView = segue.destination as? NotesViewController {
            notesView.task = task
        }
    }
    
    // MARK: - Supporting functions
    
    private func formatDate(_ date: NSDate?) -> String {
        if date == nil {
            return "ERROR!"
        }
        // TODO: compare to current date:
        //     * If year is the same, do not display the year
        //     * If day is the same then display 'today' instead of the date (or '10 minutes ago'?)
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "en_US")
        formatter.setLocalizedDateFormatFromTemplate("MMMMdyyyyHH:mma")
        return "Created on " + formatter.string(from: (date as Date?)!)
    }


}
