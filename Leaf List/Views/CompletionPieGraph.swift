//
//  CompletionPieGraph.swift
//  Leaf List
//
//  Created by Greg Paton on 8/29/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

@IBDesignable
class CompletionPieGraph: UIView {
    
    var percentComplete: Int {
        get {
            return _percentComplete
        }
        set {
            _percentComplete = newValue
        }
    }
    
    private var _percentComplete = 90
    
    private func getPointFor(radius: CGFloat, andTheta theta: CGFloat, fromOrigin origin: CGPoint) -> CGPoint {
        return CGPoint(x: origin.x + (radius * cos(theta)), y: origin.y + (radius * sin(theta)))
    }
    
    override func draw(_ rect: CGRect) {
        // Draw the checkbox border.
        let path = UIBezierPath()
        let radius: CGFloat = 11.0
        path.addArc(withCenter: self.center, radius: radius, startAngle: 0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
        graphColor.setStroke()
        graphColor.setFill()
        path.lineWidth = 1.0
        path.stroke()
        
        if _percentComplete > 0 {
            let path = UIBezierPath()
            let theta = (-CGFloat.pi / 2) + (CGFloat(_percentComplete) * 2 * CGFloat.pi) / 100.0
            path.addArc(withCenter: self.center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: theta, clockwise: true)
            path.addLine(to: self.center)
            path.addLine(to: CGPoint(x: self.center.x, y: self.center.y - 11.0))
        
            path.fill()
        }
    }
    
    @IBInspectable var graphColor: UIColor = UIColor.defaultButtonBlue {
        didSet {
            setNeedsDisplay()
        }
    }
}
