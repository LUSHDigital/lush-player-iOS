//
//  EmptyErrorViewController.swift
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
