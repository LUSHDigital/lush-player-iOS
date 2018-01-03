//
//  EventCollectionViewCell.swift
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

// Cell to display events
class EventCollectionViewCell: UICollectionViewCell {
    
    // Label to show: the name of the event
    @IBOutlet weak var eventLabel: UILabel!
    
    // CollectionView to contain event programmes
    @IBOutlet weak var eventItemsCollectionView: EventCollectionView!
    
    // Page control to show how many pages of programmes
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    // Button to view all event programmes
    @IBOutlet weak var button: SpacedCharacterButton!
    
    // Which mode to present the programmes in the cell, as pages or single items
    var pageMode: PagingMode = .page
    
    // Closure called when the user presses 'view more' button
    var didTapViewMore: ((SpacedCharacterButton) -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
    
        let nib = UINib(nibName: "LargePictureStandardMediaCell", bundle: nil)
        eventItemsCollectionView.register(nib, forCellWithReuseIdentifier: "StandardMediaCellId")
        
        if let text = button.titleLabel?.text {
            let uppercased = text.uppercased()
            button.setTitle(uppercased, for: .normal)
        }
    }
    
    @IBAction func pressedViewMoreButton(_ sender: SpacedCharacterButton) {
        didTapViewMore?(sender)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        
        
        if case let .individual(number) = pageMode {
            self.pageControl.numberOfPages = number
        } else {
            self.pageControl.numberOfPages = Int(ceil(eventItemsCollectionView.contentSize.width / eventItemsCollectionView.frame.size.width))
        }
        
    }

    // Convience method to adding delegate and datasource of the Cell
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        eventItemsCollectionView.delegate = dataSourceDelegate
        eventItemsCollectionView.dataSource = dataSourceDelegate
        eventItemsCollectionView.tag = row
        eventItemsCollectionView.reloadData()
    }
    
    // Which mode to present the programmes in the cell, as pages or single items
    enum PagingMode {
        case individual(Int)
        case page
    }
}
