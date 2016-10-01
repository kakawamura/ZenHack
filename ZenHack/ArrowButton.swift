//
//  ArrowButton.swift
//  ZenHack
//
//  Created by KazushiKawamura on 10/1/16.
//  Copyright © 2016 KazushiKawamura. All rights reserved.
//

import UIKit

class ArrowButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // set button
        self.titleLabel?.font = UIFont.fontAwesomeOfSize(18.0)
        self.setTitle(String.fontAwesomeIconWithCode("fa-angle-down"), forState: .Normal)
        
        self.setTitleColor(UIColor("#888888", 1.0), forState: .Normal)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor("#aaaaaa", 1.0)?.CGColor
        self.layer.cornerRadius = 2.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
