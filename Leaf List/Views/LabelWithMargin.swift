//
//  LabelWithMargin.swift
//  Leaf List
//
//  Created by Greg Paton on 9/12/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

class LabelWithMargin: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }

}
