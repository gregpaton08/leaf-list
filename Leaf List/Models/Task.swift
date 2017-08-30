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
    
    func set(priority newPriority: Int) {
        assert(newPriority <= Int(INT32_MAX))
        priority = Int32(newPriority)
        if parent == nil {
            set(groupPriority: newPriority)
        }
    }
    
    private func set(groupPriority newGroupPriority: Int) {
        groupPriority = Int32(newGroupPriority)
        children?.forEach({ (child) in
            if let task = child as? Task {
                task.set(groupPriority: newGroupPriority)
            }
        })
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
    
    func numChildren() -> Int {
        var numChildren = 0
        children?.forEach { child in
            if let task = child as? Task {
                numChildren += 1 + task.numChildren()
            }
        }
        return numChildren
    }
    
    func numCompleteChildren() -> Int {
        var numCompleteChildren = 0
        children?.forEach { child in
            if let task = child as? Task {
                numCompleteChildren += (task.taskCompleted ? 1 : 0) + task.numChildren()
            }
        }
        return numCompleteChildren    }
    
}
