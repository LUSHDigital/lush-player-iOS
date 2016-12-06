//
//  SecondViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

class LiveViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        LushPlayerController.shared.fetchLivePlaylist(with: nil, completion: { [weak self] (error, programmes) in
            
            if let error = error, let welf = self {
                UIAlertController.presentError(error, in: welf)
            }
            
            
        })
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

