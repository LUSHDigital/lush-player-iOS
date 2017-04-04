//
//  ProgrammeListingViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 04/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class ProgrammeListingViewController: ContentListingViewController<Programme> {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func showProgramme(programme: Programme) {}
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardMediaCellId", for: indexPath) as? StandardMediaCell {
            
            if case let .loaded(programmes) = viewState {
                
                let programme = programmes[indexPath.item]
                
                cell.imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
                cell.titleLabel.text = programme.title
                cell.mediaTypeLabel.text = programme.media.displayString()
                cell.datePublishedLabel.text = programme.date?.timeAgo
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if case let .loaded(programmes) = viewState {
            
            let programme = programmes[indexPath.item]
            showProgramme(programme: programme)
        }
    }

}
