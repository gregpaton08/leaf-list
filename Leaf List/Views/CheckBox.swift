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
    
    // MARK: - API
    
    enum Mode {
        case checkBox
        case progressMeter
    }
    
    var mode: Mode = .checkBox
    
    var percentComplete: CGFloat {
        get {
            return _percentComplete
        }
        set {
            _percentComplete = newValue
            setNeedsDisplay()
        }
    }
    
    private var _percentComplete: CGFloat = 0.0
    

    override func draw(_ rect: CGRect) {
        // Draw the checkbox border.
        let path = UIBezierPath()
        let radius: CGFloat = 11.0
        path.addArc(withCenter: self.center, radius: radius, startAngle: 0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
        buttonColor.setStroke()
        buttonColor.setFill()
        path.lineWidth = 1.0
        path.stroke()
        
        // Draw the center of the checkbox if checked.
        if isChecked {
            let path = UIBezierPath()
            path.addArc(withCenter: self.center, radius: 9.0, startAngle: 0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
            path.fill()
        } else if mode == .progressMeter {
            if _percentComplete > 0 {
                let path = UIBezierPath()
                let theta = (-CGFloat.pi / 2) + (_percentComplete * 2 * CGFloat.pi) / 100.0
                path.addArc(withCenter: self.center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: theta, clockwise: true)
                path.addLine(to: self.center)
                path.addLine(to: CGPoint(x: self.center.x, y: self.center.y - radius))
                
                path.fill()
            } else {
                let path = UIBezierPath()
                path.move(to: self.center)
                path.addLine(to: CGPoint(x: self.center.x, y: self.center.y - radius))
                path.stroke()
            }
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
