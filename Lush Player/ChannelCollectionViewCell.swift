//
//  ChannelCollectionViewCell.swift
//  Lush Player
//
//  Created by Simon Mitchell on 05/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

class ChannelCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor(red:0.439, green:0.439, blue:0.439, alpha:1) : (isFocused ? UIColor(white: 0.0, alpha: 0.2) : UIColor.clear)
            imageView.alpha = (isSelected || isFocused ) ? 1.0 : 0.6
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
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
