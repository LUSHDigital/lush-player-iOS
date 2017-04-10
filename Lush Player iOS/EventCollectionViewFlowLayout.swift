//
//  EventCollectionViewFlowLayout.swift
//  Lush Player
//
//  Created by Joel Trew on 10/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

class EventCollectionViewFlowLayout: UICollectionViewFlowLayout {

    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
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
}
