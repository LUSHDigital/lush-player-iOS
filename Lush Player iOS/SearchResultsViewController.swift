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
        
        
        let nib = UINib(nibName: "SearchCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "SearchCollectionViewCell")
        
        collectionView.keyboardDismissMode = .interactive
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
        }
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
}
