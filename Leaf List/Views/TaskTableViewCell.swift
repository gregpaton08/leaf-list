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
                groupNameLabelHeightConstraint.constant = 40.0//14.5
                
                groupNameLabel.label.numberOfLines = 0
                groupNameLabel.label.sizeToFit()
                groupNameLabel.sizeToFit()
                
                print("label size \(groupNameLabel.label.bounds.size)")
                print("view  size \(groupNameLabel.bounds.size)")
                
                groupNameLabel.bounds.size.height = groupNameLabel.label.bounds.size.height
                groupNameLabelHeightConstraint.constant = groupNameLabel.label.bounds.size.height + 6
//                groupNameLabelWidthConstraint.constant = groupNameLabel.label.bounds.size.width + 6
            }
        }
    }
    
    var delegate: TaskTableViewCellDelegate?

    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var taskNameLabel: UILabel!
//    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupNameLabel: ColorLabel!
    @IBOutlet weak var groupNameLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupNameLabelWidthConstraint: NSLayoutConstraint!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        groupNameLabel.layer.backgroundColor = UIColor.defaultButtonBlue.cgColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        groupNameLabel.layer.backgroundColor = UIColor.defaultButtonBlue.cgColor
        
    }
    
    override func willTransition(to state: UITableViewCellStateMask) {
        
        
    }
    
    override func didTransition(to state: UITableViewCellStateMask) {
        
        
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
