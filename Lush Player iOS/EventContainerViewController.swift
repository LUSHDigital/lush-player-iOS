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
    
    var childProgrammeListingViewController: EventListingViewController =  {
        
        guard let viewController = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "EventListingViewControllerId") as? EventListingViewController else { fatalError() }
        
        return viewController
    }()
    

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
                if var programmeStore = tagDictionary[tag.value] {
                    programmeStore.append(programme)
                    tagDictionary[tag.value] = programmeStore
                } else {
                    tagDictionary[tag.value] = [programme]
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
        
        guard let vc = childEventViewController else { return }
        
        vc.collectionView?.collectionViewLayout.invalidateLayout()
        vc.collectionView?.reloadData()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
         guard let vc = childEventViewController else { return }
        vc.viewModeForDeviceTraits(traits: newCollection)
        vc.collectionView?.collectionViewLayout.invalidateLayout()
        vc.collectionView?.reloadData()
        
    }
    
    func showListingViewWithEvent(_ event: Event) {
        
        let viewController = childProgrammeListingViewController
        addChildViewController(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.bindFrameToSuperviewBounds()
        didMove(toParentViewController: viewController)
        
        viewController.viewState = .loaded(event.programmes)
    }
    
    func hideListingIfNeeded() {
        
        for vc in self.childViewControllers {
            guard vc is EventListingViewController else { continue }
            vc.willMove(toParentViewController: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let menuItem = menuItems[indexPath.item]
        
        if menuItem.identifier == "all" {
            hideListingIfNeeded()
        }
        
        if let eventsVc = childEventViewController, case let .loaded(events) = eventsVc.viewState {
            if let filteredEvent = events.filter({ $0.id == menuItem.identifier }).first {
                showListingViewWithEvent(filteredEvent)
            }
        }
    }
    
    func createMenuItems(_ events: [Event]) {
        
        menuItems = events.map { (event) -> MenuItem in
            return MenuItem(title: event.title, identifier: event.id)
        }
        
        menuItems.insert(MenuItem(title: "All Events", identifier: "all"), at: 0)
    }
}

