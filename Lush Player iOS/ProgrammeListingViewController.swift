//
//  ProgrammeListingViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 04/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

// Subclass of ContentListingViewController for showing programmes models
class ProgrammeListingViewController: ContentListingViewController<Programme> {
    
    func showProgramme(programme: Programme) {
    
        performSegue(withIdentifier: "MediaDetailSegue", sender: programme)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardMediaCellId", for: indexPath) as? LargePictureStandardMediaCell {
            
            if case let .loaded(programmes) = viewState {
                
                let programme = programmes[indexPath.item]
                
                
                cell.imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
                cell.mediaTitleLabel.text = programme.title
                cell.setChannelLabel(with: programme.channelId)
//                cell.titleLabel.text = programme.title
//                cell.mediaTypeLabel.text = programme.media.displayString()
                cell.dateLabel.text = programme.date?.timeAgo
//                cell.datePublishedLabel.text = programme.date?.timeAgo
                cell.setMediaTypeImage(type: programme.media)
                
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "MediaDetailSegue" {
            if let destination = segue.destination as? MediaDetailViewController, let programme = sender as? Programme {
                
                destination.programme = programme
            }
        }
    }

}
