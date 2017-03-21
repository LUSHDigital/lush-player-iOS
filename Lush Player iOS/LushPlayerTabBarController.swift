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


    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupCustomTabbar()
    }
    
    func setupCustomTabbar() {
        
        var tabFrame = self.tabBar.frame
        // - 40 is editable , the default value is 49 px, below lowers the tabbar and above increases the tab bar size
        tabFrame.size.height = 60
        tabFrame.origin.y = self.view.frame.size.height - 60
        self.tabBar.frame = tabFrame
        
        if let tabbarItems = self.tabBar.items {
            
            for tabBarItem in tabbarItems {
                tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -6)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
