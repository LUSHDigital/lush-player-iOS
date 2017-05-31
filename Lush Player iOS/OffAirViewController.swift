//
//  OffAirViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 30/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

// View controller for displaying when there is no live stream
class OffAirViewController: UIViewController {

    // Shows the channels screen
    @IBAction func pressedExploreChannel(_ sender: SpacedCharacterButton) {
        
        self.tabBarController?.selectedIndex = 2
        
    }
}
