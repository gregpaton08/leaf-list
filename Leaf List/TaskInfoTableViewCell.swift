//
//  TaskInfoTableViewCell.swift
//  Leaf List
//
//  Created by Greg Paton on 8/6/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

class TaskInfoTableViewCell: UITableViewCell {

    var height: CGFloat {
        get {
            return max(44.0, taskInfoTextView.contentSize.height)
        }
    }
    
    @IBOutlet weak var taskInfoTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
