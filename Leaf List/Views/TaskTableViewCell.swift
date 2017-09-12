//
//  TaskTableViewCell.swift
//  Leaf List
//
//  Created by Greg Paton on 7/16/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

protocol TaskTableViewCellDelegate {
    func checkBoxSelectedFor(_ cell: TaskTableViewCell)
}

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupNameLabelHeightConstraint: NSLayoutConstraint!
    
    var delegate: TaskTableViewCellDelegate?
    
    @IBAction func selectCheckBox(_ sender: CheckBox) {
        checkBox.toggleState()
        delegate?.checkBoxSelectedFor(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        groupNameLabel.isHidden = true
        groupNameLabelHeightConstraint.constant = 0.0
    }
}
