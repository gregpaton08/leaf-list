//
//  NotesViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 8/6/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController, TaskDisplay {
    
    
    // MARK: - API
    
    var task: Task?
    var displayStyle: TaskDisplayStyle = .group
    var showCompleted: Bool = false
    
    // MARK: - View
    
    private var readOnly: Bool {
        get {
            return displayStyle == .trash
        }
    }

    @IBOutlet weak var notesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        notesTextView.text = task?.notes
        notesTextView.isUserInteractionEnabled = !readOnly
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NotesViewController.handleTapGesture(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !readOnly && task?.notes?.compare(notesTextView.text) != .orderedSame {
            task?.notes = notesTextView.text
            do {
                try AppDelegate.viewContext.save()
            } catch {
                print("oh no...")
            }
        }
    }
    
    // MARK: - Gestures
    
    func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        notesTextView.isEditable = true
        notesTextView.becomeFirstResponder()
    }
}
