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
    
}
