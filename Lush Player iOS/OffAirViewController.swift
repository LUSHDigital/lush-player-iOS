//
//  OffAirViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 30/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

class OffAirViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func pressedExploreChannel(_ sender: SpacedCharacterButton) {
        
        self.tabBarController?.selectedIndex = 2
        
    }
    
}
