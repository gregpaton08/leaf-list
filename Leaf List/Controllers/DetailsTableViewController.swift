//
//  DetailsTableViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 8/7/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit
import CoreData

class DetailsTableViewController: UITableViewController, UITextFieldDelegate, TaskDisplay {

    // MARK: - API
    
    var task: Task? {
        didSet {
//            updateUI()
        }
    }
    
    var displayStyle: TaskDisplayStyle = .group
    var showCompleted: Bool = false
    
    // MARK: - UI
    
//    @IBOutlet weak var taskNameTextField: UITextField!
//    @IBOutlet weak var dateCreatedCell: UITableViewCell!
//    
//    private func updateUI() {
//        if isViewLoaded {
//            taskNameTextField.text = task?.name ?? "ERROR!"
//            dateCreatedCell.textLabel?.text = formatDate(task?.dateCreated)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        updateUI()
        
//        taskNameTextField.delegate = self
        
        tableView.register(UINib.init(nibName: "TextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "textFieldCell")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        taskNameTextField.resignFirstResponder()
        
        do {
            try AppDelegate.viewContext.save()
        } catch {
            print("oh no...")
        }
    }
    
    // MARK: - Table view data
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as? TextFieldTableViewCell {
                cell.textField.text = task?.name
                cell.textField.delegate = self
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskDetailCell", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Notes"
                cell.accessoryType = .disclosureIndicator
            case 1:
                cell.textLabel?.text = formatDate(forTask: task)
            default:
                break
            }
            return cell
        default:
            break
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "taskDetailCell", for: indexPath)
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            performSegue(withIdentifier: "showNotesView", sender: tableView.cellForRow(at: indexPath))
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var taskDisplay = segue.destination as? TaskDisplay {
            taskDisplay.initFromTaskDisplay(self)
        }
    }
    
    // MARK: - Test field delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text?.characters.count ?? 0 > 0 {
            task?.name = textField.text
            parent?.navigationItem.title = task?.name
        } else {
            textField.text = task?.name
        }
        
        return true
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
        return "on " + formatter.string(from: (date as Date?)!)
    }
    
    private func formatDate(forTask task: Task?) -> String {
        switch displayStyle {
        case .trash:
            return "Deleted \(formatDate(task?.dateDeleted))"
        default:
            return "Created \(formatDate(task?.dateCreated))"
        }
    }


}
