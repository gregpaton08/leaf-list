//
//  TestTableViewCell.swift
//  Leaf List
//
//  Created by Greg Paton on 8/7/17.
//  Copyright © 2017 GSP. All rights reserved.
//

import UIKit

@IBDesignable
class TestTableViewCell: UITableViewCell {
    
    var subContentView: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        subContentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        subContentView.frame = bounds
        
        // Make the view stretch with containing view
        subContentView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        contentView.addSubview(subContentView)
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
}
