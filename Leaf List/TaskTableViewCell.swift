//
//  TaskTableViewCell.swift
//  Leaf List
//
//  Created by Greg Paton on 7/16/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var taskNameLabel: UILabel!
    
    @IBAction func selectCheckBox(_ sender: CheckBox) {
        checkBox.toggleState()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
