//
//  CheckBox.swift
//  Leaf List
//
//  Created by Greg Paton on 7/16/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

class CheckBox: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    private var _isChecked = false
    
    override var frame: CGRect {
        didSet {
            self.layer.cornerRadius = self.bounds.width / 2
            self.layer.borderWidth = 2.0
            self.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    var isChecked : Bool {
        get {
            return _isChecked
        }
    }
    
    func toggleState() {
        _isChecked = !_isChecked
        
        if _isChecked {
            self.layer.backgroundColor = UIColor.black.cgColor
        } else {
            self.layer.backgroundColor = UIColor.clear.cgColor
        }
    }
}
