//
//  ConnectionErrorViewController.swift
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GATracker.trackPage(named: "Offline")
    }
    
    // Convience method which sets the error description text from an error object
    func showError(_ error: Error) {
        if let localised = error as? LocalizedError {
            errorDescription.text = localised.localizedDescription
        }
    }
}
