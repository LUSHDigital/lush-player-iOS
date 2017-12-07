//
//  StandardMediaCell.swift
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
