//
//  ImageCell.swift
//  ZenHack
//
//  Created by KazushiKawamura on 10/1/16.
//  Copyright © 2016 KazushiKawamura. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    let vc = DrawableViewController()
    var drawable: Bool = false {
        didSet {
            if drawable {
                self.addSubview(vc.view)
                vc.view.snp_makeConstraints { (make) in
                    make.top.right.bottom.left.equalTo(0)
                }
            } else {
                self.imageView.snp_updateConstraints{ (make) in
                    make.top.left.equalTo(8)
                    make.bottom.right.equalTo(-8)
                }
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.cornerRadius = 4.0
        
    }
    
}
