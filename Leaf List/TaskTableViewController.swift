//
//  TaskTableViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 7/16/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit
import CoreData

class TaskTableViewController: UITableViewController, UITextFieldDelegate {
    
    // temporary dummy model
    private var numTasks = 0
    
    // Parent task of the current view. Can be nil if current task is a "root".
    var parentTask: Task?
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    private var isAddingTask = false
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        numTasks += 1
        isAddingTask = true
        tableView.reloadData()
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
        // #warning Incomplete implementation, return the number of rows
        return try! AppDelegate.viewContext.count(for: createFetchRequest())
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell

        // Configure the cell...
        cell.taskNameTextField.delegate = self
        
        // If a task is currently being added and this is the last cell then give keyboard focus to the cell's text field
        if (isAddingTask && indexPath.row == numTasks - 1) {
            cell.taskNameTextField.becomeFirstResponder()
            isAddingTask = false
        } else {
            let request: NSFetchRequest<Task> = Task.fetchRequest()
            
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            
            if (parentTask != nil) {
                request.predicate = NSPredicate(format: "parent = %@", parentTask!)
            } else {
                request.predicate = NSPredicate(format: "parent = nil")
            }
            
            let context = AppDelegate.viewContext
            let allTasks = try? context.fetch(request)
            
            print(allTasks)
            
            if (allTasks?.count ?? 0 > indexPath.row) {
                cell.taskNameTextField.text = allTasks?[indexPath.row].name
            }
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

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
