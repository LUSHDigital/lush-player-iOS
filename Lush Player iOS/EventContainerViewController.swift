//
//  EventContainerViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 12/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class EventContainerViewController: MenuContainerViewController {
    
    var childEventViewController: EventViewController? {
        return childViewControllers.filter({ $0 is EventViewController}).first as? EventViewController
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "EventViewControllerId") as? EventViewController else { return }
        
        
        addChildViewController(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.bindFrameToSuperviewBounds()
        didMove(toParentViewController: viewController)
        
        setupEventView()
    }
    
    
    func setupEventView() {
        
        guard let childEventViewController = childEventViewController else { return }
        
        let radioProgrammes = LushPlayerController.shared.programmes[.radio] ?? []
        let tvProgrammes = LushPlayerController.shared.programmes[.TV] ?? []
        
        let programmes = (radioProgrammes + tvProgrammes)
        var tagDictionary = [String: [Programme]]()
        
        for programme in programmes {
            
            guard let tags = programme.tags else {
                continue
            }
            
            for tag in tags {
                if var programmeStore = tagDictionary[tag] {
                    programmeStore.append(programme)
                    tagDictionary[tag] = programmeStore
                } else {
                    tagDictionary[tag] = [programme]
                }
            }
        }
        
        
        let summit = Event(id: "summit", title: "Summit 2017", programmes: tagDictionary["summit"] ?? [])
        let showcase =  Event(id: "showcase 2016", title: "Creative Showcase 2016", programmes: tagDictionary["showcase 2016"] ?? [])
        let events = [summit, showcase]

        childEventViewController.eventProgrammeController.events = events
        childEventViewController.viewState = .loaded(events)
        
        createMenuItems(events)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        childEventViewController?.viewModeForDeviceTraits(traits: self.traitCollection)
        childEventViewController?.collectionView.collectionViewLayout.invalidateLayout()
        childEventViewController?.collectionView.reloadData()
    }
    
    
    func createMenuItems(_ events: [Event]) {
        
        menuItems = events.map { (event) -> MenuItem in
            return MenuItem(title: event.title, identifier: event.id)
        }
    }
}
