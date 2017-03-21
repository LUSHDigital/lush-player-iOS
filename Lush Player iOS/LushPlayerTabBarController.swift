//
//  LushPlayerTabBarController.swift
//  Lush Player
//
//  Created by Joel Trew on 20/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

class LushPlayerTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupCustomTabbar()
    }
    
    /// Setup custom height tab bar
    func setupCustomTabbar() {
        
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = 60
        tabFrame.origin.y = self.view.frame.size.height - 60
        self.tabBar.frame = tabFrame
        
        if let tabbarItems = self.tabBar.items {
            
            for tabBarItem in tabbarItems {
                tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -6)
            }
        }
    }
}
