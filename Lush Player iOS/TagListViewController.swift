//
//  TagListViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 23/05/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class TagListViewController: ProgrammeListingViewController {

    var tag: Tag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewState = .loading
        
        guard let tag = tag else {
            viewState = .empty
            return
        }
        
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
