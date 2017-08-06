//
//  TaskTableViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 7/16/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit
import CoreData

class TaskTableViewController: FetchedResultsTableViewController, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, TaskTableViewCellDelegate {
    
    // MARK: - API
    
    // Parent task of the current view. Can be nil if current task is a top level group.
    var parentTask: Task?
    
    enum TaskType {
        case task
        case group
        case trash
    }
    
    var taskType: TaskType = .group { didSet {
            setupTabBarItem()
        }
    }
    
    var tabBarItemImage: UIImage? { didSet {
            setupTabBarItem()
        }
    }
    
    var showCompletedTasks = false {
        didSet {
            updateCompletedButtonColor()
        }
    }
    
    var showDetails = false
    
    // MARK: - UI

    @IBOutlet weak var completedButton: UIBarButtonItem!
    
    @IBAction func showCompleted(_ sender: UIBarButtonItem) {
        showCompletedTasks = !showCompletedTasks
        updateUI()
    }
    
    private func updateCompletedButtonColor() {
        completedButton.tintColor = showCompletedTasks ? UIColor.defaultButtonBlue : UIColor.gray
    }
    
    // MARK: - Data model
    
    private var fetchedResultsController: NSFetchedResultsController<Task>?
    
    private func createFetchRequest() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "priority", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let uncompletePredicate = showCompletedTasks ? NSPredicate(value: true) : NSPredicate(format: "taskCompleted == NO")
        let notDeletedPredicate = NSPredicate(format: "taskDeleted == NO")
        switch taskType {
        case .task:
            // TODO: need to update this to pull only the highest priority tasks.
            let predicate = NSPredicate(format: "children.@count == 0")
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, uncompletePredicate, notDeletedPredicate])
        case .group:
            var predicate: NSPredicate?
            if (parentTask != nil) {
                predicate = NSPredicate(format: "parent = %@", parentTask!)
            } else {
                predicate = NSPredicate(format: "parent = nil")
            }
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, uncompletePredicate, notDeletedPredicate])
        case .trash:
            request.predicate = NSPredicate(format: "taskDeleted == YES")
        }
        
        return request
    }
    
    private func setupTabBarItem() {
        // TODO: use associated values in TaskType enum to clean this up?
        navigationController?.tabBarItem.title = {
            switch self.taskType {
            case .task:
                return "Tasks"
            case .group:
                return "Groups"
            case .trash:
                return "Trash"
            }
        }()
        
        navigationController?.tabBarItem.image = UIImage.createImageOfSize(CGSize(width: 30, height: 30), fromImage: tabBarItemImage)
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
        let task = Task(context: context)
        task.name = name
        task.dateCreated = NSDate()
        task.parent = parentTask
        task.priority = Int32(getHighestPriority() + 1)
        
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
    
    private func deleteTask(at indexPath: IndexPath) {
        if let task = fetchedResultsController?.object(at: indexPath) {
            let context = AppDelegate.viewContext
            
            task.taskDeleted = true
            
            save(context)
        }
    }
    
    private func getHighestPriority() -> Int {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
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
    
    // MARK: - View
    
    private func configureNavBar() {
        if taskType == .trash {
            self.title = "Trash"
            completedButton.title = nil
            completedButton.tintColor = UIColor.clear
        } else if let task = parentTask {
            self.title = task.name
        } else {
            self.title = navigationController?.tabBarItem.title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        
        showDetails = parentTask != nil
        
        updateUI()
        
        navigationController?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Text field delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.superview?.superview is TaskNameTableViewCell {
            textField.resignFirstResponder()
            if textField.text?.characters.count ?? 0 > 0 {
                updateName(textField.text!, forTask: parentTask!)
                configureNavBar()
            } else {
                textField.text = parentTask?.name
            }
        } else {
            if (textField.text == nil || textField.text?.characters.count == 0) {
                textField.resignFirstResponder()
            } else {
                addTask(with: textField.text!)
                textField.text = nil
            }
        }
        
        return true
    }

    // MARK: - Table view data source
    
    private func getDetailsSection() -> Int {
        return showDetails ? 0 : -1
    }
    
    private func getTaskSection() -> Int {
        return showDetails ? 1 : 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Section order:
        //    * Details (if enabled)    - info, date
        //    * Task list               - list of current sub-tasks
        //    * New Task (if enabled)   - single cell for adding a new task
        
        var numSections = 1
        numSections += showDetails ? 1 : 0
        numSections += taskType != .trash ? 1 : 0
        return numSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case getDetailsSection():
            return 3
        case getTaskSection():
            if let sections = fetchedResultsController?.sections {
                return sections[0].numberOfObjects
            }
        default:
            return 1
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case getDetailsSection():
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "taskNameCell") as! TaskNameTableViewCell
                cell.taskNameTextField.text = parentTask?.name
                cell.taskNameTextField.delegate = self
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "taskNotesCell")!
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "taskDateCell")
                
                // TODO: compare to current date:
                //     * If year is the same, do not display the year
                //     * If day is the same then display 'today' instead of the date (or '10 minutes ago'?)
                let formatter = DateFormatter()
                formatter.locale = Locale.init(identifier: "en_US")
                formatter.setLocalizedDateFormatFromTemplate("MMMMdyyyyHH:mma")
                cell?.textLabel?.text = "Created on " + formatter.string(from: (parentTask?.dateCreated as Date?)!)
                return cell!
            default:
                break
            }
        case getTaskSection():
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
            if let task = fetchedResultsController?.object(at: IndexPath(row: indexPath.row, section: 0)) {
                cell.taskNameLabel.text = task.name
                cell.taskNameLabel.isEnabled = !task.taskCompleted
                
                cell.checkBox.isChecked = task.taskCompleted
                cell.checkBox.isHidden = taskType == .trash
                
                if task.children?.count ?? 0 > 0 {
                    cell.checkBox.isHidden = true
                }
                
                cell.delegate = self
                
                if taskType == .trash && task.children?.count == 0 {
                    cell.selectionStyle = .none
                    cell.accessoryType = .none
                } else {
                    cell.selectionStyle = .default
                    cell.accessoryType = .detailDisclosureButton
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
    
    // MARK: = Table view delegate
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
    
    // MARK: - Navigation view controller delegate
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Pass the state of the 'Completed' button back up the navigation controller stack when views are popped off.
        if let nextVC = viewController as? TaskTableViewController {
            nextVC.showCompletedTasks = showCompletedTasks
        }
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
                        taskTableView.showCompletedTasks = showCompletedTasks
                        taskTableView.taskType = taskType
                    }
                }
            }
        } else if let notesView = segue.destination as? NotesViewController {
            notesView.task = parentTask
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


extension UIImage {
    static func createImageOfSize(_ size: CGSize, fromImage image: UIImage?) -> UIImage? {
        if let imageToResize = image {
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            imageToResize.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        }
        
        return nil
    }
}
