//
//  UICollectionView+Nib.swift
//  Lush Player
//
//  Created by Joel Trew on 20/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import Foundation
import UIKit


extension UICollectionView {
    
    func register(with cell: AnyClass) {
        
        // Register cell classes
        let cellString = String(describing: cell.self)
        let nib = UINib(nibName: cellString, bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: cellString)
    }
    
}
