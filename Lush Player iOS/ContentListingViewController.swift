//
//  ContentListingViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 24/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class ContentListingViewController: UIViewController {
    
    var viewState: ContentListingViewState = .loading {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // Collection view for displaying the content items
    var collectionView: UICollectionView!
    
    func redraw() {
        
        switch viewState {
            
        case .loading:
            loadingIndicatorStateViewController.view.frame = view.bounds
            self.view.addSubview(loadingIndicatorStateViewController.view)
            addChildViewController(loadingIndicatorStateViewController)
            loadingIndicatorStateViewController.didMove(toParentViewController: self)
            
        case .loaded(let programmes):
            
            hideSubviewControllerIfNeeded(viewController: loadingIndicatorStateViewController)
            hideSubviewControllerIfNeeded(viewController: emptyStateViewController)
            hideSubviewControllerIfNeeded(viewController: noInternetStateViewController)
            
        
        case .empty(let emptyStateViewController):
            
            hideSubviewControllerIfNeeded(viewController: loadingIndicatorStateViewController)
            emptyStateViewController.view.frame = view.bounds
            self.view.addSubview(emptyStateViewController.view)
            addChildViewController(emptyStateViewController)
            emptyStateViewController.didMove(toParentViewController: self)
            
        case .noInternet(let noInternetViewController):
            
            hideSubviewControllerIfNeeded(viewController: loadingIndicatorStateViewController)
            noInternetViewController.view.frame = view.bounds
            self.view.addSubview(noInternetViewController.view)
            addChildViewController(noInternetViewController)
            noInternetViewController.didMove(toParentViewController: self)
        }
    }
    
    func hideSubviewControllerIfNeeded(viewController: UIViewController) {
        if viewController.view.isDescendant(of: self.view) {
            viewController.removeFromParentViewController()
            viewController.view.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "StandardMediaCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "StandardMediaCellId")
        
        redraw()
        // Do any additional setup after loading the view.
    }
    
    enum ContentListingViewState {
        
        case loaded([Programme])
        case empty(UIViewController)
        case noInternet(UIViewController)
        case loading
    }
    
}

extension ContentListingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch viewState {
        case .loaded(let programmes):
            return programmes.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardMediaCellId", for: indexPath) as? StandardMediaCell {
            
            if case let .loaded(programmes) = viewState {
                
                let programme = programmes[indexPath.item]
                
                cell.imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
                cell.titleLabel.text = programme.title
                cell.mediaTypeLabel.text = programme.media.displayString()
                cell.datePublishedLabel.text = programme.date?.timeAgo
            
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
}

extension ContentListingViewController: EmptyStateDisplayable, NoInternetStateDisplayable, LoadingStateDisplayable {
    
    internal var loadingIndicatorStateViewController: UIViewController {
        return LoadingViewController()
    }
    
    internal var noInternetStateViewController: UIViewController {
        return UIViewController()
    }
    
    internal var emptyStateViewController: UIViewController {
        return UIViewController()
    }
}

protocol LoadingStateDisplayable {
    
    var loadingIndicatorStateViewController: UIViewController { get }
}

protocol EmptyStateDisplayable {
    
    var emptyStateViewController: UIViewController { get }
}

protocol NoInternetStateDisplayable {
    
    var noInternetStateViewController: UIViewController { get }
}
