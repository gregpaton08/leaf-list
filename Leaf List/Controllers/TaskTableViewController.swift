
//
//  TaskTableViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 7/16/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class TaskTableViewController: FetchedResultsTableViewController, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, TaskTableViewCellDelegate, TaskDisplay, UISearchResultsUpdating {
    
    // MARK: - API
    
    var task: Task? {
        didSet {
            if isViewLoaded {
                updateUI()
            }
        }
    }
    var displayStyle: TaskDisplayStyle = .group
    
    var hasSearchBar: Bool {
        get {
            return tableView.tableHeaderView != nil
        }
        set(val) {
            tableView.tableHeaderView = val ? searchController.searchBar : nil
        }
    }
    
    // MARK: - UI
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var newTaskFooter: NewTaskTableViewCell? = {
        return self.tableView.dequeueReusableCell(withIdentifier: "newTaskCell") as? NewTaskTableViewCell
    }()
    
    private var editBarButton: UIBarButtonItem!
    private var doneBarButton: UIBarButtonItem!
    
    // MARK: - Data model
    
    private var fetchedResultsController: NSFetchedResultsController<Task>?
    
    private func createFetchRequest() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        let sortByPriority = NSSortDescriptor(key: {
            switch displayStyle {
            case .task:
                return "groupPriority"
            default:
                return "priority"
            }
        }(), ascending: true)
        
        let sortByDate = NSSortDescriptor(key: {
            switch displayStyle {
            case .trash:
                return "dateDeleted"
            default:
                return "dateCompleted"
            }
        }(), ascending: false)
        
        request.sortDescriptors = [sortByPriority, sortByDate]
        
        let uncompletePredicate = NSPredicate(format: "taskCompleted == NO")
        let notDeletedPredicate = NSPredicate(format: "taskDeleted == NO")
        switch displayStyle {
        case .task where parent is DetailsMasterViewController:
            // If contained in a detail view then do not show any tasks.
            request.predicate = NSPredicate(format: "self == nil")
        case .task:
            let predicate = NSPredicate(format: "priority == 0 AND SUBQUERY(children, $child, $child.taskCompleted == NO AND $child.taskDeleted == NO).@count == 0")
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, uncompletePredicate, notDeletedPredicate])
        case .group:
            var predicate: NSPredicate?
            if (task != nil) {
                predicate = NSPredicate(format: "parent = %@", task!)
            } else {
                predicate = NSPredicate(format: "parent = nil")
            }
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, uncompletePredicate, notDeletedPredicate])
        case .completed:
            request.predicate = NSPredicate(format: "taskCompleted == YES")
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
        fetchedResultsController = NSFetchedResultsController<Task>(fetchRequest: createFetchRequest(), managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: displayStyle == .completed ? "dateCompleted" : nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
        tableView.reloadData()
    }
    
    private func save(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("oh no...")
        }
    }
    
    private func addTask(with name: String) {
        if (name.count == 0) {
            return
        }
        
        let context = AppDelegate.viewContext
        let newTask = Task(context: context)
        newTask.name = name
        newTask.dateCreated = Date()
        newTask.parent = task
        newTask.set(priority: getHighestPriorityInGroup(forTask: newTask) + 1)
        
        save(context)
    }
    
    private func setTask(at indexPath: IndexPath, asCompleted completed: Bool) {
        if let currentTask = fetchedResultsController?.object(at: indexPath) {
            let context = AppDelegate.viewContext
            
            currentTask.set(priority: completed ? Int(INT32_MAX) : (getHighestPriorityInGroup(forTask: currentTask) + 1))
            currentTask.taskCompleted = completed
            currentTask.dateCompleted = completed ? Date() : nil
            
            normalizePrioritiesInGroup(forTask: currentTask)
            
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
        forTask.set(priority: Int(withTask.priority))
        withTask.set(priority: Int(priorityFor))
//        save(AppDelegate.viewContext)
    }
    
    private func normalizePrioritiesInGroup(forTask: Task?) {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true)]
        if forTask?.parent == nil {
            request.predicate = NSPredicate(format: "parent == nil and taskCompleted == NO and taskDeleted == NO")
        } else {
            request.predicate = NSPredicate(format: "parent == %@ and taskCompleted == NO and taskDeleted == NO", forTask!.parent!)
        }
        
        let tasksInGroup = try? AppDelegate.viewContext.fetch(request)
        
        var priority = 0
        tasksInGroup?.forEach({ (groupTask) in
            assert(groupTask.priority != INT32_MAX)
            groupTask.set(priority: priority)
            priority += 1
        })
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        if let taskToDelete = fetchedResultsController?.object(at: indexPath) {
            if taskToDelete.children?.count ?? 0 > 0 {
                let alertController = WarningAlertViewController(title: "Delete all tasks", message: "Delete all the tasks within \(taskToDelete.name ?? "ERROR!")", preferredStyle: .alert)
                alertController.completedAction = {
                    AppDelegate.viewContext.perform({
                        taskToDelete.delete()
                        self.save(AppDelegate.viewContext)
                        self.normalizePrioritiesInGroup(forTask: taskToDelete)
                    })
                }
                self.present(alertController, animated: true, completion: nil)
            } else {
                taskToDelete.delete()
                self.save(AppDelegate.viewContext)
                self.normalizePrioritiesInGroup(forTask: taskToDelete)
            }
        }
    }
    
    private func getHighestPriorityInGroup(forTask groupTask: Task?) -> Int {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: false)]
        let notSelfPredicate = NSPredicate(format: "self != %@", groupTask!)
        let parentTaskPredicate = NSPredicate(format: "parent = %@", groupTask?.parent ?? "nil")
        let uncompletePredicate = NSPredicate(format: "taskCompleted == NO")
        let notDeletedPredicate = NSPredicate(format: "taskDeleted == NO")
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [notSelfPredicate, parentTaskPredicate, uncompletePredicate,notDeletedPredicate])
        
        let context = AppDelegate.viewContext
        let highestPriorityTask = try? context.fetch(request)
        let highestPriority = Int(highestPriorityTask?.first?.priority ?? -1)
        if highestPriority == Int(INT32_MAX) {
            fatalError("Inavlid highest priority found from task name \(highestPriorityTask?.first?.name ?? "nil")")
        }
        return highestPriority
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
        
        setNavBarColor()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        
        updateUI()
        
        navigationController?.delegate = self
        
        tableView.register(UINib.init(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "taskCell")
        tableView.register(UINib.init(nibName: "NewTaskTableViewCell", bundle: nil), forCellReuseIdentifier: "newTaskCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: self)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        hasSearchBar = displayStyle != .task
        
        doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(TaskTableViewController.doneBarButtonPressed(_:)))
        editBarButton = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(TaskTableViewController.editBarButtonPressed(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the search bar by default.
        if hasSearchBar {
            tableView.contentOffset.y = searchController.searchBar.frame.height
        }
        
        visibleNavigationItem.setRightBarButton(editBarButton, animated: false)
    }
    
    @objc func keyboardDidShow() {
        if tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Save any task that is in the middle of being typed.
        if let footer = newTaskFooter {
            if let taskName = footer.newTaskTextField.text, taskName.count > 0 {
                addTask(with: taskName)
                footer.newTaskTextField.text = ""
            }
            footer.newTaskTextField.resignFirstResponder()
        }
    }
    
    @objc func doneBarButtonPressed(_ sender: UIBarButtonItem) {
        self.tableView.setEditing(false, animated: true)
        visibleNavigationItem.setRightBarButton(editBarButton, animated: true)
    }
    
    @objc func editBarButtonPressed(_ sender: UIBarButtonItem) {
        self.tableView.setEditing(true, animated: true)
        visibleNavigationItem.setRightBarButton(doneBarButton, animated: true)
    }
        
    // MARK: - Text field delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text == nil || textField.text?.count == 0) {
            textField.resignFirstResponder()
        } else {
            addTask(with: textField.text!)
            textField.text = nil
            
            if tableView.numberOfRows(inSection: 0) > 0 {
                tableView.scrollToRow(at: IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0), at: .bottom, animated: false)
            }
        }
        
        return true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections {
            return sections[section].numberOfObjects
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        
        if let task = fetchedResultsController?.object(at: indexPath) {
            cell.taskNameLabel.text = task.name
            
            cell.taskNameLabel.lineBreakMode = .byWordWrapping
            cell.taskNameLabel.numberOfLines = 0
            
            // DEBUG: Uncomment this line to display task priority next to task name.
//            cell.taskNameLabel.text = cell.taskNameLabel.text! + " P\(task.priority), \(task.groupPriority)"
            
            cell.taskNameLabel.isEnabled = displayStyle == .trash || !task.taskCompleted
            
            cell.checkBox.isChecked = task.taskCompleted
            if displayStyle == .trash || task.hasActiveChild() {
                cell.checkBox.mode = .progressMeter
                cell.checkBox.percentComplete = 100.0 * CGFloat(task.numCompleteChildren()) / CGFloat(task.numChildren())
            } else {
                cell.checkBox.mode = .checkBox
            }
            
            if displayStyle == .task {
                cell.groupName = task.parent?.name
            }
            
            var parent = task.parent
            print(task.name ?? "task name is nil")
            while parent != nil {
                print("    \(parent!.name ?? "name is nil"))")
                parent = parent?.parent
            }
            
            cell.delegate = self
            
            cell.editingAccessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if displayStyle == .completed {
            return String(section)
        }
        
        return nil
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteTask(at: indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if displayStyle == .trash {
            let restoreAction = UITableViewRowAction.init(style: .normal, title: "Restore") { (action, indexPath) in
                if let currentTask = self.fetchedResultsController?.object(at: indexPath) {
                    currentTask.restore()
                    currentTask.set(priority: self.getHighestPriorityInGroup(forTask: currentTask) + 1)
                }
            }
            restoreAction.backgroundColor = UIColor.defaultButtonBlue
            return [restoreAction]
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetailView", sender: tableView.cellForRow(at: indexPath))
    }
    
    private func shouldDisplayNewTaskFooter() -> Bool {
        if displayStyle == .trash {
            return false
        }
        
        if displayStyle == .task {
            return false
        }
        
        if displayStyle == .completed {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if shouldDisplayNewTaskFooter(), let footer = newTaskFooter {
            //        footer?.layer.borderColor = UIColor.lightGray.cgColor
            //        footer?.layer.borderWidth = 1.0
            footer.newTaskTextField.delegate = self
            
            // Need to return the content view or the footer will disappear when editing the table.
            return footer.contentView
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if shouldDisplayNewTaskFooter() {
            return 44.0
        }
        
        return 0.0
    }
    
    // MARK: - Search results updating
    
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive || searchController.searchBar.text?.count ?? 0 == 0 {
            updateUI()
        } else {
            fetchedResultsController?.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
            fetchedResultsController?.fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchController.searchBar.text ?? "")
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
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


// MARK: - Extensions


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
    
    func setNavBarColor() {
        navigationController?.navigationBar.barTintColor = UIColor.carribeanGreen
        navigationController?.navigationBar.titleTextAttributes?[NSAttributedStringKey.foregroundColor] = UIColor.white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
    }
}


extension UIColor {
    static var defaultButtonBlue: UIColor {
        get {
            return UIColor.init(red: 10.0 / 255, green: 106.0 / 255, blue: 255.0 / 255, alpha: 1.0)
        }
    }
    
    static var carribeanGreen: UIColor {
        get {
            return UIColor.init(red: 0, green: 189.0 / 255, blue: 141.0 / 255, alpha: 1.0)
        }
    }
}


extension UILabel {
    var isTruncated: Bool {
        if let nsText = text as NSString? {
            let size = nsText.size(withAttributes: [NSAttributedStringKey.font: font])
            return size.width > bounds.width
        }
        
        return false
    }
    
    var numLines: Int {
        if let nsText = text as NSString? {
            let size = nsText.boundingRect(with: CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
            return Int(ceil(CGFloat(size.height) / font.lineHeight))
        }
        
        return 0
    }
    
    var isWrapped: Bool {
        return numLines > 1
    }
}
