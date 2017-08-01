//
//  TaskTableViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 7/16/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit
import CoreData

class TaskTableViewController: FetchedResultsTableViewController, UITextFieldDelegate {
    
    // Parent task of the current view. Can be nil if current task is a "root".
    var parentTask: Task? { didSet { updateUI() } }
    
    var fetchedResultsController: NSFetchedResultsController<Task>?
    
    private func createFetchRequest() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        if (parentTask != nil) {
            request.predicate = NSPredicate(format: "parent = %@", parentTask!)
        } else {
            request.predicate = NSPredicate(format: "parent = nil")
        }
        
        return request
    }
    
    private func updateUI() {
        fetchedResultsController = NSFetchedResultsController<Task>(fetchRequest: createFetchRequest(), managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
        tableView.reloadData()
    }
    
    private func addTask(with name: String) {
        let context = AppDelegate.viewContext
        let task = Task(context: context)
        task.name = name
        task.dateCreated = NSDate()
        task.parent = parentTask
        
        do {
            try context.save()
        } catch {
            print("oh no...")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        updateUI()
    }

    private var isAddingTask = false
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        addTask(with: "TESTING \(tableView(self.tableView, numberOfRowsInSection: 0))")
//        isAddingTask = true
//        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Text field delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Once the task is created disabled user interaction with the text field so that the cell can be clicked
        textField.isUserInteractionEnabled = false
        
        if (textField.text?.characters.count == 0) {
            // TODO: delete the cell if the name is empty
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(textField.text ?? "Text field was empty")
        textField.resignFirstResponder()
        
        let context = AppDelegate.viewContext
        let task = Task(context: context)
        task.name = textField.text
        task.dateCreated = NSDate()
        task.parent = parentTask
        
        do {
            try context.save()
        } catch {
            print("oh no...")
        }
        
        return true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections {
            return sections[section].numberOfObjects
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell

        // Configure the cell...
        cell.taskNameTextField.delegate = self
        
        // If a task is currently being added and this is the last cell then give keyboard focus to the cell's text field
        if (isAddingTask && indexPath.section == self.tableView.numberOfSections - 1) {
//        if (isAddingTask && indexPath.row == self.tableView(self.tableView, numberOfRowsInSection: 0) - 1) {
            cell.taskNameTextField.isUserInteractionEnabled = true
            cell.taskNameTextField.becomeFirstResponder()
            isAddingTask = false
        } else if let task = fetchedResultsController?.object(at: indexPath) {
            cell.taskNameTextField.text = task.name
            cell.taskNameTextField.isUserInteractionEnabled = false
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if let task = fetchedResultsController?.object(at: indexPath) {
                AppDelegate.viewContext.delete(task)
            }
//            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
//    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return nil
//    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footer = TaskTableViewCell()
        
        footer.textLabel?.text = "FOOTER TESTING"
        footer.backgroundColor = UIColor.white
        
        return footer
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return TaskTableViewCell().frame.height
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let taskTableView = segue.destination as? TaskTableViewController {
            if let cell = sender as? TaskTableViewCell {
                if let indexPath = self.tableView.indexPath(for: cell) {
                    if let task = fetchedResultsController?.object(at: indexPath) {
                        taskTableView.parentTask = task
                    }
                }
            }
        }
    }

}
