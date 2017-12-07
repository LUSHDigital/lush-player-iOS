//
//  ProgrammeCollectionViewCell.swift
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
