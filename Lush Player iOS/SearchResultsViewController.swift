//
//  SearchResultsViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 03/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class SearchResultsViewController: ContentListingViewController<SearchResult> {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                collectionView.contentInset = UIEdgeInsets(top: 120, left: 0, bottom: 44, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard case let .loaded(searchResults) = viewState else {
            return UICollectionViewCell()
        }
        
        let result = searchResults[indexPath.item]
        
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardMediaCellId", for: indexPath) as? StandardMediaCell {
            
            cell.titleLabel.text = result.title
            cell.imageView.set(imageURL: result.thumbnailURL, withPlaceholder: nil, completion: nil)
            cell.mediaTypeLabel.text = result.media.displayString()
            return cell
        }
        
        return UICollectionViewCell()
    }
}
