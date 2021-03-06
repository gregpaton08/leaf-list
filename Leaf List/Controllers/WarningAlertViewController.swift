//
//  WarningAlertViewController.swift
//  Leaf List
//
//  Created by Greg Paton on 8/11/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

class WarningAlertViewController: UIAlertController {
    
    var completedAction: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let noAction = UIAlertAction(title: "No", style: .cancel)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (alert) in
            self.completedAction?()
        }
        addAction(noAction)
        addAction(yesAction)
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
