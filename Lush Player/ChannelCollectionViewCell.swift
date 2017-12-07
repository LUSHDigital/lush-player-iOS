//
//  ChannelCollectionViewCell.swift
//  Lush Player
//
/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

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
