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
        
        let home = self.viewControllers?[0]
        home?.tabBarItem.image = #imageLiteral(resourceName: "home_icon")
        
        let live = self.viewControllers?[1]
        live?.tabBarItem.image = #imageLiteral(resourceName: "live_icon")
        
        let channels = self.viewControllers?[2]
        channels?.tabBarItem.image = #imageLiteral(resourceName: "channels_icon")
        
        let events = self.viewControllers?[3]
        events?.tabBarItem.image = #imageLiteral(resourceName: "events_icon")
        
        let search = self.viewControllers?[4]
        search?.tabBarItem.image = #imageLiteral(resourceName: "search_icon")

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
