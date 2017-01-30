//
//  ProgrammeCollectionViewCell.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

/// A collection view cell for use as a programme cell on the channels tab
class ChannelProgrammeCollectionViewCell: UICollectionViewCell {
    
    /// The image view of the cell
    @IBOutlet weak var imageView: UIImageView!
        
     /// The title label of the cell, used to display the programme name
    @IBOutlet weak var titleLabel: UILabel!
    
    /// The date label of the cell, used to display the programme's date
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
    }
}
