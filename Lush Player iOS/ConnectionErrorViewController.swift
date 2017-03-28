//
//  ConnectionErrorViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 28/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

class ConnectionErrorViewController: UIViewController {

    @IBOutlet weak var errorTitle: UILabel!
    
    @IBOutlet weak var errorDescription: UILabel!
    
    var retryAction: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func pressedRetry(_ sender: SpacedCharacterButton) {
        
        retryAction?()
    }
    
    func showError(_ error: Error) {
        if let localised = error as? LocalizedError {
            errorDescription.text = localised.localizedDescription
        }
    }
}
