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
        
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        if shouldStopOnMiddleItem {
            
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
            
            
            
        } else {
            
            var offsetAdjustment = Double.infinity
            let horizontalOffset = proposedContentOffset.x
            
            let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
            
            let array = super.layoutAttributesForElements(in: targetRect)
            
            
            for layoutAttributes in array! {
                let itemOffset = layoutAttributes.frame.origin.x
                if Double(abs(itemOffset - horizontalOffset)) < abs(offsetAdjustment) {
                    offsetAdjustment = Double(itemOffset - horizontalOffset);
                }
                
            }
            
            if proposedContentOffset.x <= 0 {
                return CGPoint(x: (Double(proposedContentOffset.x) + offsetAdjustment) - 40, y: Double(proposedContentOffset.y))
                
            }
            return CGPoint(x: (Double(proposedContentOffset.x) + offsetAdjustment) - 20, y: Double(proposedContentOffset.y))
        }
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

