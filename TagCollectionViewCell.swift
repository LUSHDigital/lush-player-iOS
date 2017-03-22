//
//  TagCollectionViewCell.swift
//  Lush Player
//
//  Created by Joel Trew on 22/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tagLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.borderColor = UIColor.white.cgColor
        
        containerView.layer.borderWidth = 2
    }

}
