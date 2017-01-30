//
//  ProgrammeCollectionViewCell.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

/// A collection view cell for displaying a programme
class ProgrammeCollectionViewCell: UICollectionViewCell {
    
    /// The image view of the call
    @IBOutlet weak var imageView: UIImageView!
    
    /// The format label of the cell (Should read TV or Radio)
    @IBOutlet weak var formatLabel: UILabel!
    
    /// The title label of the cell, used to display the programme name
    @IBOutlet weak var titleLabel: UILabel!
    
    /// The date label of the cell, used to display the programme's date
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
    }
}
