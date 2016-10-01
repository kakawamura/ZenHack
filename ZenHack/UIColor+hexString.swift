//
//  UIColor+hexString.swift
//  ZenHack
//
//  Created by KazushiKawamura on 10/1/16.
//  Copyright © 2016 KazushiKawamura. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init?(_ hexString: String, _ alpha: CGFloat = 1.0) {
        let r, g, b: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.startIndex.advancedBy(1)
            let hexColor = hexString.substringFromIndex(start)
            
            if hexColor.characters.count == 6 {
                let scanner = NSScanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexLongLong(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: alpha)
                    return
                }
            }
        }
        
        return nil
    }
}