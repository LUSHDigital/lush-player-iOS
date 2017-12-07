//
//  TagListViewController.swift
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
import LushPlayerKit

// ViewController for displaying a list of programmes relating to a single tag
class TagListViewController: ProgrammeListingViewController {

    // Tag to find related programmes for
    var tag: Tag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set view initially as loading
        viewState = .loading
        
        // If we don't have a tag show an empty state
        guard let tag = tag else {
            viewState = .empty
            return
        }
        
        // Request API for related programmes from the tag
        LushPlayerController.shared.fetchProgrammes(for: tag) { [weak self] (error, programmes) -> (Void) in
            
            if let error = error {
                print(error)
                self?.searchForTagsInLocalContent(tag)
                return
            }
            
            if let programmes = programmes {
                
                self?.viewState = .loaded(programmes)
            }
        }
    }
    
    // Called if the API request fails for some reason, searches through locally stored programmes for tag instead
    func searchForTagsInLocalContent(_ selectedTag: Tag) {
        
        let radioProgrammes = LushPlayerController.shared.programmes[.radio] ?? []
        let tvProgrammes = LushPlayerController.shared.programmes[.TV] ?? []
        let programmes = (radioProgrammes + tvProgrammes)
        
        let taggedProgrammes = programmes.filter { (programme) -> Bool in
            guard let tags = programme.tags else {
                return false
            }
            
            return tags.index(where: { $0.value == selectedTag.value }) != nil
        }
        
        self.viewState = .loaded(taggedProgrammes)
    }
}

class ReplaceSegue: UIStoryboardSegue {
    
    override func perform() {

        let sourceViewController = self.source
        let destinationController = self.destination
        let navigationController = sourceViewController.navigationController

        guard var controllerStack = navigationController?.viewControllers else { return super.perform() }
        guard let index = controllerStack.index(of: sourceViewController) else { return super.perform() }
        controllerStack[index] = destinationController
        
        navigationController?.setViewControllers(controllerStack, animated: true)

    }
}
