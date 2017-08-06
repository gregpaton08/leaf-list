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
    
    enum TaskType {
        case task
        case group
    }
    
    var taskType: TaskType = .group
    
    private var fetchedResultsController: NSFetchedResultsController<Task>?
    
    private func createFetchRequest() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        switch taskType {
        case .task:
            request.predicate = NSPredicate(format: "children.@count == 0")
        case .group:
            if (parentTask != nil) {
                request.predicate = NSPredicate(format: "parent = %@", parentTask!)
            } else {
                request.predicate = NSPredicate(format: "parent = nil")
            }
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
        if (name.characters.count == 0) {
            return
        }
        
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
    
    private func deleteTask(at indexPath: IndexPath) {
        if let task = fetchedResultsController?.object(at: indexPath) {
            let context = AppDelegate.viewContext
            
            context.delete(task)
            
            do {
                try context.save()
            } catch {
                print("oh no...")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        switch navigationController?.tabBarItem.title {
        case "Tasks"?:
            taskType = .task
        case "Groups"?:
            taskType = .group
        default:
            print("unkown bar title \(tabBarItem.title ?? "Unkown title")")
        }
        
        if let task = parentTask {
            self.title = task.name
        }
        
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Text field delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text == nil || textField.text?.characters.count == 0) {
            textField.resignFirstResponder()
        } else {
            addTask(with: textField.text!)
            textField.text = nil
        }
        
        return true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Section 0: list of tasks.
        // Section 1: single cell for adding a new task.
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if let sections = fetchedResultsController?.sections {
                return sections[section].numberOfObjects
            }
        case 1:
            return 1
        default:
            break
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
            
            // Configure the cell...
            cell.taskNameTextField.delegate = self
            
            if let task = fetchedResultsController?.object(at: indexPath) {
                cell.taskNameTextField.text = task.name
                cell.taskNameTextField.isUserInteractionEnabled = false
            }
            
            return cell
        case 1:
            if let footer = tableView.dequeueReusableCell(withIdentifier: "newTaskCell") as? NewTaskTableViewCell {
                footer.newTaskTextField.delegate = self
                return footer
            }
        default:
            break
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
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
            deleteTask(at: indexPath)
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
