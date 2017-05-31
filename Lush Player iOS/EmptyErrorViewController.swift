//
//  EmptyErrorViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 28/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

// Standard ViewController to represent an empty state, i.e no items returned from the API, this is so the user does not get an empty or blank screen
class EmptyErrorViewController: UIViewController {

    // The Imageview to represent the channel what was attempted to view content from, optionally set
    @IBOutlet weak var channelImageView: UIImageView!
    
    // A label to show some description text
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
