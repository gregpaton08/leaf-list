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
    
    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    var label = UILabel()
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: label.bounds.size.width + (marginSize * 2), height: label.bounds.size.height + (marginSize * 2))
        }
    }
    
    override var backgroundColor: UIColor? {
        get {
            return UIColor.white
        }
        set {
            
        }
    }
    
    private let marginSize: CGFloat = 3.0
    
    override func sizeToFit() {
        label.sizeToFit()
        super.sizeToFit()
        
        bounds.size.height = label.bounds.height + (marginSize * 2)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let viewSize = self.bounds.size
        label.frame = CGRect(x: marginSize, y: marginSize, width: viewSize.width - (marginSize * 2), height: viewSize.height - (marginSize * 2))
        label.textColor = UIColor.white
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.numberOfLines = 0
        self.addSubview(label)
        
        self.backgroundColor = UIColor.defaultButtonBlue
//        self.layer.backgroundColor = UIColor.defaultButtonBlue.cgColor
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.defaultButtonBlue.cgColor
        self.layer.cornerRadius = 3.0
    }

}
