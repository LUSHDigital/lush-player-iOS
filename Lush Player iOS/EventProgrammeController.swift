//
//  EventItemController.swift
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

protocol EventProgrammeControllerDelegate: class {
    
    func eventItemsDidScroll(collectionView: UICollectionView)
    func didSelectEventProgrammePreview(programme: Programme)
}

class EventProgrammeController: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var events: [Event]?
    var maxNumberOfProgrammes: Int = 6
    
    var viewMode: ViewMode = .compact
    
    weak var delegate: EventProgrammeControllerDelegate?
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfProgrammesToDisplay(item: collectionView.tag)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    
        if let flowLayout = collectionView.collectionViewLayout as? EventCollectionViewFlowLayout {
            flowLayout.eventFlowLayoutDelegate = self
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardMediaCellId", for: indexPath) as? LargePictureStandardMediaCell else {
            fatalError("Incorrect cell")
        }
        
        guard let events = events else {
            fatalError("Recieved cell count but no events array")
        }
        
        let programme = events[collectionView.tag].programmes[indexPath.item]
        
        cell.imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
        cell.mediaTitleLabel.text = programme.title
        cell.setChannelLabel(with: programme.channelId)
        cell.dateLabel.text = programme.date?.timeAgo
        cell.setMediaTypeImage(type: programme.media)
        
        if let flowLayout = collectionView.collectionViewLayout as? EventCollectionViewFlowLayout {
            switch viewMode {
                
            case .compact:
                collectionView.isPagingEnabled = false
                flowLayout.shouldStopOnMiddleItem = true
                
            case .extended:
                collectionView.isPagingEnabled = false
                flowLayout.shouldStopOnMiddleItem = false
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let programme = events?[collectionView.tag].programmes[indexPath.item] {
            delegate?.didSelectEventProgrammePreview(programme: programme)
        }
    }
    

    func numberOfProgrammesToDisplay(item: Int) -> Int {
        guard let events = events else { return 0 }
        
        return events[item].programmes.prefix(maxNumberOfProgrammes).count
    }
    
    enum ViewMode {
        
        case extended
        case compact
    }
}


extension EventProgrammeController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellWidth: CGFloat
        var cellHeight: CGFloat
        switch viewMode {
            
        case .compact:
            cellWidth = 250
            cellHeight = CGFloat(Double(cellWidth) * 1.32)
        case .extended:
            cellWidth = 300
            cellHeight = 330
        }
        
        
        
        let cellSize = CGSize(width: cellWidth , height: cellHeight)
        return cellSize
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch viewMode {
        case .compact:
            return 10
        case .extended:
            return 20
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return UIEdgeInsets.zero
        }
        
        switch viewMode {
            
        case .compact:
            let inset = collectionView.bounds.width - (flowLayout.minimumInteritemSpacing + 250)
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: inset/2)
    
        case .extended:

            return UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let collectionView = scrollView as? UICollectionView else { return }
        
        delegate?.eventItemsDidScroll(collectionView: collectionView)
    }
    
}

extension EventProgrammeController: EventCollectionViewFlowLayoutDelegate {
    
    func layoutWasInvalidated(collectionView: UICollectionView, eventCollectionViewFlowLayout: EventCollectionViewFlowLayout) {
        
        switch viewMode {
            
        case .compact:
            collectionView.isPagingEnabled = false
            eventCollectionViewFlowLayout.shouldStopOnMiddleItem = true
            
        case .extended:
            collectionView.isPagingEnabled = false
            eventCollectionViewFlowLayout.shouldStopOnMiddleItem = false
        }
    }
    
}

