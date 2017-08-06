//
//  CheckBox.swift
//  Leaf List
//
//  Created by Greg Paton on 7/16/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

@IBDesignable
class CheckBox: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
     */
    
    @IBInspectable var isChecked : Bool {
        get {
            return _isChecked
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var checkedBoxColor: UIColor = UIColor.black
    
    func toggleState() {
        _isChecked = !_isChecked
        
        if _isChecked {
            self.layer.backgroundColor = checkedBoxColor.cgColor
        } else {
            self.layer.backgroundColor = UIColor.clear.cgColor
        }
    }
    
    private var _isChecked = false
    
    override var frame: CGRect {
        didSet {
            self.layer.cornerRadius = self.bounds.width / 2
            self.layer.borderWidth = 2.0
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.backgroundColor = isChecked ? checkedBoxColor.cgColor : UIColor.clear.cgColor
        }
    }
}
