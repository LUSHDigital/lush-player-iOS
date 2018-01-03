//
//  LushPlayerTabBarController.swift
//  Lush Player
//
/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

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
		
		// Fix for iOS 11 and iPhone X (we don't need any padding for the X, if you do
		// things mess up....
		//
		if UIDevice.displayType() != .iphoneX {
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
}
