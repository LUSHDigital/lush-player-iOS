//
//  LoadingViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 24/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

// Basic loading view controller to display when performing work that will take a little time, i.e performing a network request
class LoadingViewController: UIViewController {
    
    // Spinning indicator to show something is loading
    var loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
         loadingIndicator.center = self.view.center
    }
}
