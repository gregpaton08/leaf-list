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

    override func draw(_ rect: CGRect) {
        // Draw the checkbox border.
        let path = UIBezierPath()
        path.addArc(withCenter: self.center, radius: 11.0, startAngle: 0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
        buttonColor.setStroke()
        path.lineWidth = 1.0
        path.stroke()
        
        // Draw the center of the checkbox if checked.
        if isChecked {
            let path = UIBezierPath()
            path.addArc(withCenter: self.center, radius: 9.0, startAngle: 0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
            buttonColor.setFill()
            path.fill()
        }
    }
 
    @IBInspectable var isChecked : Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var buttonColor: UIColor = UIColor.defaultButtonBlue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func toggleState() {
        isChecked = !isChecked
    }
    
    override var frame: CGRect {
        didSet {
            titleLabel?.text = nil
            titleLabel?.isHidden = true
        }
    }
}
