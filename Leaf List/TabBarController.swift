//
//  TabBarController.swift
//  Leaf List
//
//  Created by Greg Paton on 8/6/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    private let viewControllerData = [
        0: (title: "Groups", displayStyle: TaskDisplayStyle.group, image: "branch.png"),
        1: (title: "Tasks", displayStyle: TaskDisplayStyle.task, image: "leaf.png")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (index, data) in viewControllerData {
            if let taskView = viewControllers?[index] as? TaskTableViewController {
                taskView.displayStyle = data.displayStyle
                taskView.navigationController?.tabBarItem.title = data.title
                taskView.navigationController?.tabBarItem.image = UIImage.createImageOfSize(CGSize(width: 30, height: 30), fromImage: UIImage(named: data.image))
            }
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
