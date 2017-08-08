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

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        let path = UIBezierPath()
        path.addArc(withCenter: self.center, radius: 11.0, startAngle: 0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
        UIColor.defaultButtonBlue.setStroke()
        path.lineWidth = 1.0
        path.stroke()
        
        if isChecked {
            let path = UIBezierPath()
            path.addArc(withCenter: self.center, radius: 9.0, startAngle: 0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
            UIColor.defaultButtonBlue.setFill()
//            path.lineWidth = 1.0
            path.fill()
        }
    }
 
    @IBInspectable var isChecked : Bool = false {
        didSet {
//            self.layer.backgroundColor = isChecked ? checkedBoxColor.cgColor : UIColor.clear.cgColor
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
//            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var checkedBoxColor: UIColor = UIColor.defaultButtonBlue
    
    func toggleState() {
        isChecked = !isChecked
    }
    
    override var frame: CGRect {
        didSet {
            // TODO: hard code radius to 11 (width = height = 22).
//            self.layer.frame.size.width = 22.0
//            self.layer.frame.size.height = 22.0
            
//            self.layer.frame.origin.x = (self.bounds.height - self.layer.bounds.height) / 2
//            self.layer.frame.origin.y = (self.bounds.width - self.layer.bounds.width) / 2
            
//            self.layer.cornerRadius = 11.0
//            self.layer.borderWidth = 1.0
//            self.layer.borderColor = UIColor.defaultButtonBlue.cgColor
//            self.layer.backgroundColor = isChecked ? checkedBoxColor.cgColor : UIColor.clear.cgColor
            titleLabel?.text = nil
            titleLabel?.isHidden = true
        }
    }
}
