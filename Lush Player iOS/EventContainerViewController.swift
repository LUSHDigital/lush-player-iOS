//
//  EventContainerViewController.swift
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
        
        
        self.menuCollectionView.transform = CGAffineTransform(translationX: 0, y: -self.menuCollectionView.bounds.height)
        
        self.childEventViewController?.viewState = .loading
        
        setupEventView { (error, events) in
            
            if let error = error {
                self.childEventViewController?.viewState = .error(error)
                return
            }
            
            if let events = events {
                
                guard !events.isEmpty else {
                    self.childEventViewController?.viewState = .empty
                    return
                }
                
                OperationQueue.main.addOperation {
                    self.childEventViewController?.eventProgrammeController.events = events
                    self.childEventViewController?.viewState = .loaded(events)
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        self.menuCollectionView.transform = .identity
                    })
                    
                    self.createMenuItems(events)
                    self.setFirstMenuItemAsSelected()
                }

            }
        }
    }
    
    func setupEventView(completion: @escaping (Error?, [Event]?) -> Void) {
        
        guard let childEventViewController = childEventViewController else { return }
        
        
        LushPlayerController.shared.fetchEvents { (error, events) -> (Void) in
            
            if let error = error {
                completion(error, nil)
                return
            }
            
            guard let events = events else {
                completion(EventsError.noData, nil)
                return
            }
            
            var parsedEvents = [Event]()
            
            let dispatchGroup = DispatchGroup()
            
            
            for event in events {
                dispatchGroup.enter()
                LushPlayerController.shared.fetchEventDetail(for: event, completion: { (error, programmes) -> (Void) in
                    
                    guard error == nil else {
                        dispatchGroup.leave()
                        return
                    }
                    
                    guard let programmes = programmes else {
                        dispatchGroup.leave()
                        return
                    }
                    
                    let eventWithProgrammes = event.addProgrammes(programmes)
                    parsedEvents.append(eventWithProgrammes)
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main, execute: {
                
                let sortedEvents = parsedEvents.sorted(by: { (a, b) -> Bool in
                    a.endDate > b.endDate
                })
                completion(nil, sortedEvents)
            })
        }
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


enum EventsError: Error {
    case noData
}
