//
//  ConnectionErrorViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 28/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

// Standard ViewController to show when there is an error with the connect, i.e the wifi drops
class ConnectionErrorViewController: UIViewController {

    // The title label, used to provide the user with some overveiw of the error
    @IBOutlet weak var errorTitle: UILabel!
    
    // Description label, used to give a more detailed explanation of what happened to casue this error
    @IBOutlet weak var errorDescription: UILabel!
    
    // Retry Action, called when the user presses the retry button, this simple closure can be set to re-perform a network request
    var retryAction: (() -> ())?
    
    // Called when user presses the retry button - in turns calls the retryAction closure
    @IBAction func pressedRetry(_ sender: SpacedCharacterButton) {
        
        retryAction?()
    }
    
    // Convience method which sets the error description text from an error object
    func showError(_ error: Error) {
        if let localised = error as? LocalizedError {
            errorDescription.text = localised.localizedDescription
        }
    }
}
