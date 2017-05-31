//
//  TagCollectionViewCell.swift
//  Lush Player
//
//  Created by Joel Trew on 22/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

// Cell for displaying a single tag
class TagCollectionViewCell: UICollectionViewCell {

    // Tag title i.e #Politics
    @IBOutlet weak var tagLabel: UILabel!
    
    // Container view used for styling
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Add white border
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.layer.borderWidth = 2
    }

}
