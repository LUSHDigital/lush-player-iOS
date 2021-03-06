//
//  SearchResultsViewController.swift
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


// Displays a list of programmes the search returned
class SearchResultsViewController: ContentListingViewController<Programme> {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Override empty search controller
        self.emptyStateViewController = {
                let storyboard = UIStoryboard(name: "Search", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SearchEmptyResultsViewControllerId") as? SearchEmptyResultsViewController
                return vc ?? SearchEmptyResultsViewController()
            }()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewState = .empty
        
        // Setup empty state view controller
        guard let emptyStateViewController = emptyStateViewController as? SearchEmptyResultsViewController else { return }
        
        emptyStateViewController.descriptionLabel.text = "Search for a programme"
        emptyStateViewController.searchAgainButton.setTitle("Search".uppercased(), for: .normal)
        
        // Register Cell
        let nib = UINib(nibName: "SearchCollectionViewCell", bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: "SearchCollectionViewCell")
        collectionView?.keyboardDismissMode = .interactive
        
        // Layout
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                collectionView?.contentInset = UIEdgeInsets(top: 120, left: 0, bottom: 44, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard case let .loaded(searchResults) = viewState else {
            return UICollectionViewCell()
        }
        
        let result = searchResults[indexPath.item]
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as? SearchCollectionViewCell {
            
            cell.titleLabel.text = result.title
            cell.imageView.set(imageURL: result.thumbnailURL, withPlaceholder: nil, completion: nil)
            cell.mediaLabel.text = result.media.displayString()
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height:CGFloat = 100.0
        
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard case let .loaded(searchResults) = viewState else {
            return
        }
        
        let result = searchResults[indexPath.item]
    
        performSegue(withIdentifier: "MediaDetailSegue", sender: result)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "MediaDetailSegue" {
            if let destination = segue.destination as? MediaDetailViewController, let programme = sender as? Programme {
                
                destination.programme = programme
            }
        }
    }
}
