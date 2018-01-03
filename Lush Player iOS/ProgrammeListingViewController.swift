//
//  ProgrammeListingViewController.swift
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
