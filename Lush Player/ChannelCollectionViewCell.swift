//
//  ChannelCollectionViewCell.swift
//  Lush Player
//
//  Created by Simon Mitchell on 05/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

/// A collection view cell for displaying a channel
class ChannelCollectionViewCell: UICollectionViewCell {
    
    /// The image view that displays the channel logo
    @IBOutlet weak var imageView: UIImageView!
    
    /// Used to customise cell based on selection state
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor(red:0.439, green:0.439, blue:0.439, alpha:1) : (isFocused ? UIColor(white: 0.0, alpha: 0.2) : UIColor.clear)
            imageView.alpha = (isSelected || isFocused ) ? 1.0 : 0.6
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        // Animate the cell style when it is being focussed
        coordinator.addCoordinatedAnimations({
            
            if self.isFocused && !self.isSelected {
                self.imageView.alpha = 1.0
                self.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
            } else if !self.isSelected {
                self.backgroundColor = UIColor.clear
                self.imageView.alpha = 0.6
            }
            
        }, completion: nil)
    }
}
