//
//  EventCollectionViewFlowLayout.swift
//  Lush Player
//
//  Created by Joel Trew on 10/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

class EventCollectionViewFlowLayout: UICollectionViewFlowLayout {

    var shouldStopOnMiddleItem: Bool = true
    
    weak var eventFlowLayoutDelegate: EventCollectionViewFlowLayoutDelegate?
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard shouldStopOnMiddleItem else {
            return proposedContentOffset
        }
        
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let collectionBounds = collectionView.bounds
        let halfWidth = collectionBounds.size.width * 0.5
        let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth
        
        guard let attributes = self.layoutAttributesForElements(in: collectionBounds) else { return proposedContentOffset }
        
        
        var candidateAttributes: UICollectionViewLayoutAttributes? = nil
        
        for attribute in attributes {
            
            guard attribute.representedElementCategory == .cell else {
                continue
            }
            
            guard let _candidateAttributes = candidateAttributes else {
                candidateAttributes = attribute
                continue
            }
            
            if fabs(attribute.center.x - proposedContentOffsetCenterX) < fabs(_candidateAttributes.center.x - proposedContentOffsetCenterX) {
                candidateAttributes = attribute
            }
        }
        
        guard let _candidateAttributes = candidateAttributes else {
            return proposedContentOffset
        }
    
        return CGPoint(x: _candidateAttributes.center.x - halfWidth, y: proposedContentOffset.y)
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        
        if let collectionView = collectionView {
            eventFlowLayoutDelegate?.layoutWasInvalidated(collectionView: collectionView, eventCollectionViewFlowLayout: self)
        }
    }
}

protocol EventCollectionViewFlowLayoutDelegate: class {
    
    func layoutWasInvalidated(collectionView: UICollectionView, eventCollectionViewFlowLayout: EventCollectionViewFlowLayout)
}

