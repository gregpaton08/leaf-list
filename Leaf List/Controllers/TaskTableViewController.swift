//
//  TaskTableViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 7/16/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit
import CoreData

class TaskTableViewController: FetchedResultsTableViewController, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, TaskTableViewCellDelegate, TaskDisplay {
    
    // MARK: - API
    
    var task: Task? {
        didSet {
            if isViewLoaded {
                updateUI()
            }
        }
    }
    var displayStyle: TaskDisplayStyle = .group
    var showCompleted = false {
        didSet {
            if isViewLoaded {
                updateUI()
            } else {
                updateCompletedButtonColor()
            }
        }
    }
    
    // MARK: - UI
    
    @IBAction func showCompleted(_ sender: UIBarButtonItem) {
        showCompleted = !showCompleted
    }
    
    private func updateCompletedButtonColor() {
        if visibleNavigationItem.rightBarButtonItem == nil {
            let button = UIBarButtonItem(title: "Completed", style: .plain, target: self, action: #selector(TaskTableViewController.showCompleted(_:)))
            visibleNavigationItem.setRightBarButton(button, animated: true)
        }
        
        visibleNavigationItem.rightBarButtonItem?.tintColor = showCompleted ? UIColor.defaultButtonBlue : UIColor.gray
    }
    
    // MARK: - Data model
    
    private var fetchedResultsController: NSFetchedResultsController<Task>?
    
    private func createFetchRequest() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "priority", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let uncompletePredicate = showCompleted ? NSPredicate(value: true) : NSPredicate(format: "taskCompleted == NO")
        let notDeletedPredicate = NSPredicate(format: "taskDeleted == NO")
        switch displayStyle {
        case .task:
            // TODO: need to update this to pull only the highest priority tasks.
            let predicate = NSPredicate(format: "priority == 0 AND children.@count == 0")
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, uncompletePredicate, notDeletedPredicate])
        case .group:
            var predicate: NSPredicate?
            if (task != nil) {
                predicate = NSPredicate(format: "parent = %@", task!)
            } else {
                predicate = NSPredicate(format: "parent = nil")
            }
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, uncompletePredicate, notDeletedPredicate])
        case .trash:
            if task != nil {
                request.predicate = NSPredicate(value: false)
            } else {
                request.predicate = NSPredicate(format: "taskDeleted == YES")
            }
        }
        
        return request
    }
    
    private func updateUI() {
        fetchedResultsController = NSFetchedResultsController<Task>(fetchRequest: createFetchRequest(), managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
        tableView.reloadData()
        
        updateCompletedButtonColor()
    }
    
    private func save(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("oh no...")
        }
    }
    
    private func addTask(with name: String) {
        if (name.characters.count == 0) {
            return
        }
        
        let context = AppDelegate.viewContext
        let newTask = Task(context: context)
        newTask.name = name
        newTask.dateCreated = NSDate()
        newTask.parent = task
        newTask.priority = Int32(getHighestPriority() + 1)
        
        save(context)
    }
    
    private func setTask(at indexPath: IndexPath, asCompleted completed: Bool) {
        if let task = fetchedResultsController?.object(at: indexPath) {
            let context = AppDelegate.viewContext
            
            task.taskCompleted = completed
            task.dateCompleted = NSDate()
            
            save(context)
        }
    }
    
    private func updateName(_ name: String, forTask task: Task) {
        task.name = name
        save(AppDelegate.viewContext)
    }
    
    private func updateNotes(_ notes: String, forTask task: Task) {
        task.notes = notes
        save(AppDelegate.viewContext)
    }
    
    private func swapPriority(forTask: Task, withTask: Task) {
        let priorityFor = forTask.priority
        forTask.priority = withTask.priority
        withTask.priority = priorityFor
//        save(AppDelegate.viewContext)
    }
    
    private func normalizePriorities() {
        var priority = 0
        fetchedResultsController?.fetchedObjects?.forEach({ (currentTask) in
            currentTask.priority = Int32(priority)
            priority += 1
        })
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        if let taskToDelete = fetchedResultsController?.object(at: indexPath) {
            taskToDelete.taskDeleted = true
            save(AppDelegate.viewContext)
            
            // If the group view is displayed then normalize the priorities so that the highest priority task is 0.
            if displayStyle == .group {
                normalizePriorities()
            }
        }
    }
    
    private func getHighestPriority() -> Int {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: false)]
        if (task != nil) {
            request.predicate = NSPredicate(format: "parent = %@", task!)
        } else {
            request.predicate = NSPredicate(format: "parent = nil")
        }
        
        let context = AppDelegate.viewContext
        let highestPriorityTask = try? context.fetch(request)
        return Int(highestPriorityTask?.first?.priority ?? -1)
    }
    
    // MARK: - View
    
    private func configureNavBar() {
        if displayStyle == .trash {
            self.title = "Trash"
        } else if let task = task {
            self.title = task.name
        } else {
            self.title = navigationController?.tabBarItem.title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        
        updateUI()
        
        navigationController?.delegate = self
        
        tableView.register(UINib.init(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "taskCell")
        tableView.register(UINib.init(nibName: "NewTaskTableViewCell", bundle: nil), forCellReuseIdentifier: "newTaskCell")
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPressGesture(_ gestureRecognizer: UIGestureRecognizer) {
        if let longPressGesture = gestureRecognizer as? UILongPressGestureRecognizer {
            
            let locationInView = longPressGesture.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at: locationInView)
            
            struct My {
                static var cellSnapshot : UIView? = nil
            }
            struct Path {
                static var initialIndexPath : IndexPath? = nil
            }
            
            switch longPressGesture.state {
            case .began:
                if indexPath != nil && indexPath?.section == 0 {
                    Path.initialIndexPath = indexPath
                    let cell = tableView.cellForRow(at: indexPath!)!
                    My.cellSnapshot  = snapShotOfCell(inputView: cell)
                    var center = cell.center
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.alpha = 0.0
                    tableView.addSubview(My.cellSnapshot!)
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        center.y = locationInView.y
                        My.cellSnapshot!.center = center
                        My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                        My.cellSnapshot!.alpha = 0.98
                        cell.alpha = 0.0
                    }, completion: { (finished) in
                        if finished {
                            cell.isHidden = true
                        }
                    })
                }
            case .changed:
                // Need to check if cell is nil. Could be nil if initial press was in an unsupported section.
                if let cell = My.cellSnapshot {
                    var center = cell.center
                    center.y = locationInView.y
                    cell.center = center
                    if indexPath != nil && indexPath!.section == 0 && indexPath != Path.initialIndexPath {
                        swapPriority(forTask: (fetchedResultsController?.object(at: Path.initialIndexPath!))!, withTask: (fetchedResultsController?.object(at: indexPath!))!)
                        Path.initialIndexPath = indexPath
                    }
                }
            default:
                if let initialIndexPath = Path.initialIndexPath {
                    let cell = tableView.cellForRow(at: initialIndexPath)!
                    cell.isHidden = false
                    cell.alpha = 0.0
                    UIView.animate(withDuration: 0.25, animations: {
                        My.cellSnapshot!.center = cell.center
                        My.cellSnapshot!.transform = CGAffineTransform.identity
                        My.cellSnapshot!.alpha = 0.0
                        cell.alpha = 1.0
                    }, completion: { (finished) in
                        if finished {
                            Path.initialIndexPath = nil
                            My.cellSnapshot!.removeFromSuperview()
                            My.cellSnapshot = nil
                        }
                    })
                }
            }
        }
    }
    
    func snapShotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize.init(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
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
        // Section order:
        //    * Task list               - list of current sub-tasks
        //    * New Task (if enabled)   - single cell for adding a new task
        
        var numSections = 1
        numSections += displayStyle != .trash ? 1 : 0
        return numSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if let sections = fetchedResultsController?.sections {
                return sections[section].numberOfObjects
            }
        default:
            return 1
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
            
            if let task = fetchedResultsController?.object(at: indexPath) {
                cell.taskNameLabel.text = task.name
                cell.taskNameLabel.text = cell.taskNameLabel.text! + " P\(task.priority)"
                cell.taskNameLabel.isEnabled = !task.taskCompleted
                
                cell.checkBox.isChecked = task.taskCompleted
                cell.checkBox.isHidden = displayStyle == .trash
                
                if task.children?.count ?? 0 > 0 {
                    cell.checkBox.isHidden = true
                }
                
                cell.delegate = self
                
                if displayStyle == .trash && task.children?.count == 0 {
                    cell.selectionStyle = .none
                    cell.accessoryType = .none
                } else {
                    cell.selectionStyle = .default
                    cell.accessoryType = .disclosureIndicator
                }
            }
            
            return cell
        default:
            if let footer = tableView.dequeueReusableCell(withIdentifier: "newTaskCell") as? NewTaskTableViewCell {
                footer.newTaskTextField.delegate = self
                return footer
            }
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

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if displayStyle == .trash {
            let restoreAction = UITableViewRowAction.init(style: .normal, title: "Restore") { (action, indexPath) in
                print("Restore task at index path \(indexPath)")
            }
            return [restoreAction]
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetailView", sender: tableView.cellForRow(at: indexPath))
    }
    
    // MARK: - Navigation view controller delegate
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Pass the state of the 'Completed' button back up the navigation controller stack when views are popped off.
        if let nextVC = viewController as? TaskTableViewController {
            nextVC.showCompleted = showCompleted
        }
    }

    // MARK: - Navigation
    
    private func getTaskForCell(_ sender: Any?) -> Task? {
        if let cell = sender as? TaskTableViewCell {
            if let indexPath = self.tableView.indexPath(for: cell) {
                return fetchedResultsController?.object(at: IndexPath(row: indexPath.row, section: 0))
            }
        }
        
        return nil
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if var taskDisplay = segue.destination as? TaskDisplay {
            if let taskForCell = getTaskForCell(sender) {
                taskDisplay.initFromTaskDisplay(self)
                taskDisplay.task = taskForCell
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


extension UIViewController {
    // If the view controller is embedded in a container view then the navigation item will be one level up. Add this convenience variable to access the navgiation item wherever it may be.
    var visibleNavigationItem: UINavigationItem {
        get {
            if parent is DetailsMasterViewController {
                return parent!.navigationItem
            } else {
                return self.navigationItem
            }
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
