//
//  TaskTableViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 7/16/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit
import CoreData

class TaskTableViewController: FetchedResultsTableViewController, UITextFieldDelegate, TaskTableViewCellDelegate {
    
    // Parent task of the current view. Can be nil if current task is a "root".
    var parentTask: Task? { didSet { updateUI() } }
    
    enum TaskType {
        case task
        case group
        case completed
    }
    
    var taskType: TaskType = .group { didSet {
            setupTabBarItem()
        }
    }
    
    var tabBarItemImage: UIImage? { didSet {
            setupTabBarItem()
        }
    }

    @IBOutlet weak var completedButton: UIBarButtonItem!
    
    @IBAction func showCompleted(_ sender: UIBarButtonItem) {
        showCompletedTasks = !showCompletedTasks
        updateUI()
    }
    
    var showCompletedTasks = false {
        didSet {
            updateCompletedButtonColor()
        }
    }
    
    private func updateCompletedButtonColor() {
        completedButton.tintColor = showCompletedTasks ? UIColor.defaultButtonBlue : UIColor.gray
    }
    
    private var fetchedResultsController: NSFetchedResultsController<Task>?
    
    private func createFetchRequest() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "priority", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let uncompletePredicate = showCompletedTasks ? NSPredicate(value: true) : NSPredicate(format: "taskCompleted == NO")
        switch taskType {
        case .task:
            // TODO: need to update this to pull only the highest priority tasks.
            let predicate = NSPredicate(format: "children.@count == 0")
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, uncompletePredicate])
        case .group:
            var predicate: NSPredicate?
            if (parentTask != nil) {
                predicate = NSPredicate(format: "parent = %@", parentTask!)
            } else {
                predicate = NSPredicate(format: "parent = nil")
            }
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, uncompletePredicate])
        case .completed:
//            request.predicate = NSPredicate(format: "hasCompletedTask == YES")
            request.predicate = NSPredicate(block: { (object, bindings) -> Bool in
                if let task = object as? Task {
                    return task.hasCompletedTask
                }
                return false
            })
            break
        }
        
        
        
        return request
    }
    
    private func resizeImage(_ image: UIImage?, toSize size: CGSize) -> UIImage? {
        if let imageToResize = image {
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            imageToResize.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        }
        
        return nil
    }
    
    private func setupTabBarItem() {
        switch taskType {
        case .task:
            navigationController?.tabBarItem.title = "Tasks"
        case .group:
            navigationController?.tabBarItem.title = "Groups"
        case .completed:
            navigationController?.tabBarItem.title = "Complete"
        }
        
        navigationController?.tabBarItem.image = resizeImage(tabBarItemImage, toSize: CGSize(width: 30, height: 30))
    }
    
    private func updateUI() {
        fetchedResultsController = NSFetchedResultsController<Task>(fetchRequest: createFetchRequest(), managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
        tableView.reloadData()
        
        updateCompletedButtonColor()
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
        task.priority = Int32(getHighestPriority() + 1)
        
        do {
            try context.save()
        } catch {
            print("oh no...")
        }
    }
    
    private func setTask(at indexPath: IndexPath, asCompleted completed: Bool) {
        if let task = fetchedResultsController?.object(at: indexPath) {
            let context = AppDelegate.viewContext
            
            task.taskCompleted = completed
            task.dateCompleted = NSDate()
            
            do {
                try context.save()
            } catch {
                print("oh no...")
            }
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
    
    private func getHighestPriority() -> Int {
        let request = NSFetchRequest<Task>()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: false)]
        if (parentTask != nil) {
            request.predicate = NSPredicate(format: "parent = %@", parentTask!)
        } else {
            request.predicate = NSPredicate(format: "parent = nil")
        }
        
        let context = AppDelegate.viewContext
        let highestPriorityTask = try? context.fetch(request)
        return Int(highestPriorityTask?.first?.priority ?? -1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if let task = parentTask {
            self.title = task.name
        } else {
            self.title = navigationController?.tabBarItem.title
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
    
    private func getTaskSection() -> Int {
        return 0
    }

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
            if let task = fetchedResultsController?.object(at: indexPath) {
                cell.taskNameLabel.text = task.name
                cell.taskNameLabel.isEnabled = !task.taskCompleted
                cell.checkBox.isChecked = task.taskCompleted
                
                if task.children?.count ?? 0 > 0 {
                    cell.checkBox.isHidden = true
                }
                
                cell.delegate = self
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
                        taskTableView.showCompletedTasks = showCompletedTasks
                    }
                }
            }
        }
    }
    
    // MARK: - Task table view cell delegate
    
    func checkBoxSelectedFor(_ cell: TaskTableViewCell) {
        if let indexPath = self.tableView.indexPath(for: cell) {
            setTask(at: indexPath, asCompleted: cell.checkBox.isChecked)
        }
    }
}


extension UIColor {
    static var defaultButtonBlue: UIColor {
        get {
            return UIColor.init(colorLiteralRed: 10.0 / 255, green: 106.0 / 255, blue: 255.0 / 255, alpha: 1.0)
        }
    }
}
