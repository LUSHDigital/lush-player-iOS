//
//  StandardMediaCell.swift
//  Lush Player
//
//  Created by Joel Trew on 21/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

/// Cell for representing a genric piece of media in a list that the user can consume.
class StandardMediaCell: UICollectionViewCell {
    
    /// ImageView to show a preview of the media
    @IBOutlet weak var imageView: UIImageView!
    
    /// Label to display the type of media, i.e TV or Radio
    @IBOutlet weak var mediaTypeLabel: UILabel!
    
    /// Label to display the title of the media
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Label to display how many days ago the vidoe was published
    @IBOutlet weak var datePublishedLabel: UILabel!
    
    /// View to show when a piece of content is new
    @IBOutlet weak var newContentIndicatorView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        newContentIndicatorView.isHidden = true
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newContentIndicatorView.isHidden = true
        datePublishedLabel.text = nil
        titleLabel.text = nil
        mediaTypeLabel.text = nil
        mediaTypeLabel.text = nil
        imageView.image = nil
    }

}
