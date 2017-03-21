//
//  HomeCollectionViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 21/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class HomeCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomTabbar()
    }
    
    func setupCustomTabbar() {
        
        if var tabbarFrame = self.tabBarController?.tabBar.frame {
            tabbarFrame.size.height = 60
            tabbarFrame.origin.y = self.view.frame.size.height - 60
            self.tabBarController?.tabBar.frame = tabbarFrame
        }
        
        if let tabbarItems = self.tabBarController?.tabBar.items {
            
            for tabBarItem in tabbarItems {
                tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -6)
            }
        }
    }
}
