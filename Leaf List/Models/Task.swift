//
//  Task.swift
//  Leaf List
//
//  Created by Greg Paton on 7/13/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit
import CoreData

class Task: NSManagedObject {

    var hasCompletedTask: Bool {
        get {
            if self.taskCompleted {
                return true
            } else {
                var retVal = false
                children?.forEach { child in
                    if let task = child as? Task, task.taskCompleted {
                        retVal = true
                        return
                    }
                }
                return retVal
            }
        }
    }
    
    func delete() {
        taskDeleted = true
        dateDeleted = NSDate()
        priority = INT32_MAX
        children?.forEach({ (child) in
            if let task = child as? Task {
                task.delete()
            }
        })
    }
    
    func restore() {
        taskDeleted = false
        dateDeleted = nil
        parent?.restore()
    }
    
    func hasActiveChild() -> Bool {
        var retVal = false
        children?.forEach { child in
            if let task = child as? Task, !task.taskCompleted && !task.taskDeleted {
                retVal = true
                return
            }
        }
        
        return retVal
    }
    
}
