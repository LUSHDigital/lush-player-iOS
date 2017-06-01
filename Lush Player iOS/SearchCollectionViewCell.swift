//
//  SearchCollectionViewCell.swift
//  Lush Player
//
//  Created by Joel Trew on 04/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

// Cell to represent a search result
class SearchCollectionViewCell: UICollectionViewCell {
    
    // ImageView for the cell
    @IBOutlet weak var imageView: UIImageView!

    // Label to show: Type of media
    @IBOutlet weak var mediaLabel: UILabel!
    
    // Label to show: Title
    @IBOutlet weak var titleLabel: UILabel!
}
