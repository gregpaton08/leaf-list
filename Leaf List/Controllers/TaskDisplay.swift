//
//  TaskDisplay.swift
//  Leaf List
//
//  Created by Greg Paton on 8/7/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import Foundation
import CoreData

enum TaskDisplayStyle {
    case task
    case group
    case completed
    case trash
}

// Protocol for a class that is responsible for displaying a task and details about it.
protocol TaskDisplay {
    
    // The task to be displayed.
    var task: Task? { get set }
    
    // The style used for displaying the task.
    var displayStyle: TaskDisplayStyle { get set }
}


extension TaskDisplay {
    mutating func initFromTaskDisplay(_ taskDisplay: TaskDisplay) {
        task = taskDisplay.task
        displayStyle = taskDisplay.displayStyle
    }
}
