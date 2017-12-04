//
//  TagListViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 23/05/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

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
