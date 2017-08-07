//
//  TabBarController.swift
//  Leaf List
//
//  Created by Greg Paton on 8/6/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let taskVC = viewControllers?[0].rootViewController as? TaskTableViewController {
            taskVC.displayStyle = .group
            taskVC.navigationController?.tabBarItem.title = "Groups"
            taskVC.navigationController?.tabBarItem.image = UIImage.createImageOfSize(CGSize(width: 30, height: 30), fromImage: UIImage(named: "branch.png"))
        }
        
        if let taskVC = viewControllers?[1].rootViewController as? TaskTableViewController {
            taskVC.displayStyle = .task
            taskVC.navigationController?.tabBarItem.title = "Tasks"
            taskVC.navigationController?.tabBarItem.image = UIImage.createImageOfSize(CGSize(width: 30, height: 30), fromImage: UIImage(named: "leaf.png"))
        }
    }
}


extension UIViewController {
    var rootViewController: UIViewController {
        get {
            if let navVC = self as? UINavigationController {
                return navVC.viewControllers[0]
            }
            
            return self
        }
    }
}
