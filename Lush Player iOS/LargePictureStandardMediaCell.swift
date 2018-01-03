//
//  LargePictureStandardMediaCell.swift
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
import LushPlayerKit

// Newer large card style cells for the home page
class LargePictureStandardMediaCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var channelLabel: UILabel!

    @IBOutlet weak var mediaTitleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var mediaTypeIconImageView: UIImageView!
    
    var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        shadowView = UIView()
        shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        imageView.insertSubview(shadowView, belowSubview: channelLabel)
        shadowView.bindFrameToSuperviewBounds()
        
        imageView.contentMode = .scaleAspectFill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
            shadowView.frame = imageView.bounds
    }
    
    func setChannelLabel(with channel: String?) {
        
        channelLabel.text = channel ?? ""
        channelLabel.text = channelLabel.text?.uppercased()
        channelLabel.kern(with: 2)
    }
    
    func setMediaTypeImage(type: Programme.Media) {
        
        switch type {
        case .radio:
            mediaTypeIconImageView.image = #imageLiteral(resourceName: "home_radio_icon")
        case .TV:
            mediaTypeIconImageView.image = #imageLiteral(resourceName: "home_video_icon")
        }
    }
    
    override func prepareForReuse() {
        
        imageView.image = nil
        channelLabel.text = nil
        mediaTitleLabel.text = nil
    }
}
