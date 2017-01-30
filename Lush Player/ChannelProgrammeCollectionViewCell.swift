//
//  ProgrammeCollectionViewCell.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

class ChannelProgrammeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
        
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
    }
}
