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
    
    // MARK: - API
    
    var groupName: String? {
        didSet {
            if groupName == nil {
                groupNameLabel.isHidden = true
                groupNameLabelHeightConstraint.constant = 0.0
                groupNameLabel.label.text = nil
            } else {
                groupNameLabel.isHidden = false
                groupNameLabel.label.text = groupName
                
                groupNameLabel.sizeToFit()
                // TODO: find an automatic way to do this (intrinsic size?)
                groupNameLabelHeightConstraint.constant = groupNameLabel.bounds.size.height
            }
        }
    }
    
    var delegate: TaskTableViewCellDelegate?

    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var groupNameLabel: ColorLabel!
    @IBOutlet weak var groupNameLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupNameLabelWidthConstraint: NSLayoutConstraint!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        groupNameLabel.backgroundColor = UIColor.defaultButtonBlue
    }
    
    @IBAction func selectCheckBox(_ sender: CheckBox) {
        checkBox.toggleState()
        delegate?.checkBoxSelectedFor(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        groupNameLabel.layer.borderWidth = 1.0
        groupNameLabel.layer.borderColor = UIColor.defaultButtonBlue.cgColor
        groupNameLabel.layer.cornerRadius = groupNameLabel.frame.height / 2
        groupNameLabel.layer.backgroundColor = UIColor.defaultButtonBlue.cgColor
        groupNameLabel.label.textColor = UIColor.white
        
        groupName = nil
    }
}
