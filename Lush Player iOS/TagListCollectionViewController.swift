//
//  TagListCollectionViewController.swift
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

// Collection View for displaying a list of tags related to a programme, used in MediaDetailViewController
class TagListCollectionViewController: UICollectionViewController {
    
    // List of tags to display, reloads the colelctionview on set
    var tags = [Tag]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    // Optional callback function if the user tapped a tag in collection view, with the tag that was pressed
    var didSelectTag: ((Tag) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        let nib = UINib(nibName: "TagCollectionViewCell", bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: "TagCollectionViewCell")
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let tag = tags[indexPath.item]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as? TagCollectionViewCell {
            cell.tagLabel.text = tag.name
            return cell
        }
        // Configure the cell
    
        return UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let tag = tags[indexPath.item]
        didSelectTag?(tag)
    }
}


extension TagListCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size: CGSize = tags[indexPath.row].name.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)])
        return CGSize(width: size.width + 45.0, height: 40)
    }
}
