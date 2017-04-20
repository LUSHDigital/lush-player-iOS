//
//  EventListingViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 13/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class EventListingViewController: ProgrammeListingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        if self.parent is MenuContainerViewController {
            collectionView?.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 70, right: 0)
        }
    }
}
