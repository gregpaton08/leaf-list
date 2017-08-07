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
            taskVC.navigationController?.tabBarItem.image = UIImage.createImageOfSize(CGSize(width: 30, height: 30), fromImage: UIImage(named: "branch.png"))
        }
        
        if let taskVC = viewControllers?[1].rootViewController as? TaskTableViewController {
            taskVC.displayStyle = .task
            taskVC.tabBarItemImage = UIImage(named: "leaf.png")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
