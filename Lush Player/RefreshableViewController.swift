//
//  RefreshableViewController.swift
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
import AVKit
import LushPlayerKit

/// A base view controller which adds refreshable capabilities to UIViewController
class RefreshableViewController: UIViewController {
    
    private var refreshObserver: NSObjectProtocol?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        refresh()
        
        // Set up an observer to listen for program refresh notifications
        refreshObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.ProgrammesRefreshed, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            // Call redraw function
            self?.redraw()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// A function responsible for refreshing the content associated with this view controller
    func refresh(completion: (() -> Void)? = nil) {
        
    }

    /// A function responsible for redrawing the content of this view controller when a refresh occurs
    func redraw() {
        
    }
    
    /// Pushes a specific `Programme` object onto the navigation stack
    ///
    /// - Parameter programme: The programme to push
    func show(programme: Programme) {
        performSegue(withIdentifier: "ShowProgramme", sender: programme)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // If the sender is a Programme object
        guard let programme = sender as? Programme else { return }
        // And the destination is the `LiveViewController`
        guard let detailVC = segue.destination as? LiveViewController else { return }
        
        // Set the pushing VC's programme up
        detailVC.programme = programme
    }
}
