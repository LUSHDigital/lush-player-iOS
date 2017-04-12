//
//  EventViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 10/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

struct Event {
    
    var id: String
    var title: String
    var programmes: [Programme]
}


class EventViewController: ContentListingViewController<Event> {
    
    let eventProgrammeController = EventProgrammeController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "EventCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "EventCollectionViewCellId")
        
        viewModeForDeviceTraits(traits: self.traitCollection)
        eventProgrammeController.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.parent is MenuContainerViewController {
            collectionView.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 70, right: 0)
        }
    }
    
    
    func viewModeForDeviceTraits(traits: UITraitCollection) {
        if (traits.horizontalSizeClass == .regular) ||  (UIDevice.current.orientation.isLandscape) {
            
            eventProgrammeController.viewMode = .extended
        } else {
            eventProgrammeController.viewMode = .compact
        }
    }
    
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        viewModeForDeviceTraits(traits: newCollection)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCellId", for: indexPath) as? EventCollectionViewCell {
            
            if case let .loaded(events) = viewState {
                
                let event = events[indexPath.item]
                cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: eventProgrammeController, forRow: indexPath.item)
                cell.eventLabel.text = event.title
                switch eventProgrammeController.viewMode {
                case .compact:
                    cell.pageControl.numberOfPages = eventProgrammeController.numberOfProgrammesToDisplay(item: indexPath.item)
                    
                case .extended:
                    cell.pageControl.numberOfPages = Int(ceil(cell.eventItemsCollectionView.contentSize.width / cell.eventItemsCollectionView.frame.size.width))

                }
                
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            return CGSize(width: collectionView.bounds.width, height: 420)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? EventCollectionViewCell else {
            return
        }
        if eventProgrammeController.viewMode == .extended {
            cell.pageControl.numberOfPages = Int(ceil(cell.eventItemsCollectionView.contentSize.width / cell.eventItemsCollectionView.frame.size.width))
        }

    }
}


extension EventViewController: EventProgrammeControllerDelegate {

    func eventItemsDidScroll(collectionView: UICollectionView) {
        setPageControlIndex(for: collectionView)

    }
    
    func setPageControlIndex(for collectionView: UICollectionView) {
        guard let cell = self.collectionView.cellForItem(at: IndexPath(item: collectionView.tag, section: 0)) as? EventCollectionViewCell else { return }
        
        switch eventProgrammeController.viewMode {
            
        case .compact:
            let contentOffset = collectionView.contentOffset
            let centrePoint =  CGPoint(
                x: contentOffset.x + collectionView.frame.midX,
                y: contentOffset.y + collectionView.frame.midY
            )
            
            
            if let index = collectionView.indexPathForItem(at: centrePoint){
                cell.pageControl.currentPage = index.row
            }
            
        case .extended:
            cell.pageControl.currentPage = Int(ceil(collectionView.contentOffset.x / collectionView.frame.size.width))
        }
    }
}
