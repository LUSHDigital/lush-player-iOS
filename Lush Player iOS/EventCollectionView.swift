//
//  EventCollectionView.swift
//  Lush Player
//
//  Created by Joel Trew on 10/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit


class EventCollectionView: UICollectionView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (!self.bounds.size.equalTo(self.intrinsicContentSize)) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return self.contentSize
    }
    
    
    override func reloadData() {
        super.reloadData()
        self.collectionViewLayout.invalidateLayout()
    }
}
