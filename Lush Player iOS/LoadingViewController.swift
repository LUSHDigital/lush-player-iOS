//
//  LoadingViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 24/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
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
