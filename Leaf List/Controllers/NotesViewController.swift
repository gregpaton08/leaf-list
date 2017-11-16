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
    
    private var doneBarButton: UIBarButtonItem!
    private var editBarButton: UIBarButtonItem!
    
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
        
        navigationItem.title = "Notes"
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NotesViewController.handleTapGesture(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        notesTextView.addGestureRecognizer(tapGestureRecognizer)
        
        doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(NotesViewController.doneButtonPressed(_:)))
        
        // If the notes view is empty then display the keyboard.
        if notesTextView.text.count == 0 {
            showKeyboard()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        dismissKeyboard()
        
        if !readOnly && task?.notes?.compare(notesTextView.text) != .orderedSame {
            task?.notes = notesTextView.text
            do {
                try AppDelegate.viewContext.save()
            } catch {
                print("oh no...")
            }
        }
    }
    
    @objc func doneButtonPressed(_ sender: UIBarButtonItem) {
        dismissKeyboard()
    }
    
    private func showKeyboard() {
        notesTextView.isEditable = true
        notesTextView.becomeFirstResponder()
        visibleNavigationItem.setRightBarButton(doneBarButton, animated: true)
    }
    
    private func dismissKeyboard() {
        notesTextView.resignFirstResponder()
        notesTextView.isEditable = false
        visibleNavigationItem.setRightBarButton(nil, animated: true)
    }
    
    // MARK: - Gestures
    
    @objc func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if notesTextView.isFirstResponder {
                dismissKeyboard()
            } else {
                showKeyboard()
            }
        }
    }
}
