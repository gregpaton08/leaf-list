//
//  ColorLabel.swift
//  Leaf List
//
//  Created by Greg Paton on 9/12/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

@IBDesignable
class ColorLabel: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var label = UILabel()
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: label.bounds.size.width + (marginSize * 2), height: label.bounds.size.height + (marginSize * 2))
        }
    }
    
    private let marginSize: CGFloat = 3.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let viewSize = self.bounds.size
        label.frame = CGRect(x: marginSize, y: marginSize, width: viewSize.width - (marginSize * 2), height: viewSize.height - (marginSize * 2))
        label.textColor = UIColor.white
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        self.addSubview(label)
        
        self.backgroundColor = UIColor.defaultButtonBlue
//        self.layer.backgroundColor = UIColor.defaultButtonBlue.cgColor
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.defaultButtonBlue.cgColor
        self.layer.cornerRadius = 3.0
    }

}
