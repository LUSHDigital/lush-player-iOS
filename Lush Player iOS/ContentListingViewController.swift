//
//  ContentListingViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 24/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class ContentListingViewController: UIViewController, StateParentViewable {
    
    
    var viewState: ContentListingViewState = .loading(LoadingViewController()) {
        didSet {
            self.redraw()
        }
    }
    
    lazy var connectionErrorViewController: ConnectionErrorViewController = {
        let storyboard = UIStoryboard(name: "ConnectionErrorScreen", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as? ConnectionErrorViewController
        return vc ?? ConnectionErrorViewController()
    }()
    
    lazy var emptyStateViewController: EmptyErrorViewController = {
        let storyboard = UIStoryboard(name: "EmptyStateScreen", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as? EmptyErrorViewController
        return vc ?? EmptyErrorViewController()
    }()
    
    
    // Collection view for displaying the content items
    var collectionView: UICollectionView!
    
    func redraw() {
        
        switch viewState {
            
        case .loading(let loadingViewController):
            
            hideChildControllersIfNeeded()
            loadingViewController.view.frame = view.bounds
            loadingViewController.willMove(toParentViewController: self)
            addChildViewController(loadingViewController)
            self.view.addSubview(loadingViewController.view)
            loadingViewController.didMove(toParentViewController: self)
            
        case .loaded(_):
            
            hideChildControllersIfNeeded()
            collectionView.reloadData()
        
        case .empty(let emptyStateViewController):
            
            hideChildControllersIfNeeded()
            emptyStateViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            emptyStateViewController.view.frame = view.bounds
            addChildViewController(emptyStateViewController)
            self.view.addSubview(emptyStateViewController.view)
            emptyStateViewController.didMove(toParentViewController: self)
            collectionView.reloadData()
            
        case .error(let errorViewController):
            
            hideChildControllersIfNeeded()
            errorViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            errorViewController.view.frame = view.bounds
            addChildViewController(errorViewController)
            self.view.addSubview(errorViewController.view)
            errorViewController.didMove(toParentViewController: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let collectionViewLayout = ContentListingFlowLayout()
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionViewLayout.minimumLineSpacing = 20
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: collectionViewLayout)
        self.view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "StandardMediaCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "StandardMediaCellId")
        
        setupConstraints()
        
        redraw()
    }
    
    
    func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: collectionView, attribute: .left, relatedBy: .equal, toItem: collectionView.superview, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: collectionView, attribute: .right, relatedBy: .equal, toItem: collectionView.superview, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: collectionView.superview, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            ])
        
        view.setNeedsUpdateConstraints()
    }
    
    func showProgramme(programme: Programme) { }
    
    enum ContentListingViewState {
        
        case loaded([Programme])
        case empty(UIViewController)
        case error(UIViewController)
        case loading(UIViewController)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if case let .loaded(programmes) = viewState {
            
            let programme = programmes[indexPath.item]
            showProgramme(programme: programme)
        }
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }
}


extension ContentListingViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var numberOfColumns: CGFloat = 1
        
        switch (view.traitCollection.verticalSizeClass, view.traitCollection.horizontalSizeClass) {
        case (.regular, .regular):
            numberOfColumns = 3
        case (.regular, .compact):
            numberOfColumns = 1
        case (.compact, .compact):
            numberOfColumns = 2
        case (.compact, .regular):
            numberOfColumns = 2
        default:
            numberOfColumns = 1
        }
        
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let currentTotalWidth = collectionView.bounds.width - layout.sectionInset.left - layout.sectionInset.right
    
        
        let cellWidth = (currentTotalWidth - (numberOfColumns-1) * layout.sectionInset.left) / numberOfColumns
        let cellHeight = CGFloat(Double(cellWidth) * 0.9)

        let cellSize = CGSize(width: cellWidth , height: cellHeight)
        return cellSize
        

    }
}

extension ContentListingViewController: ErrorStateDisplayable {
    
    
    internal var errorStateViewController: UIViewController {
        return connectionErrorViewController
    }
    
}

protocol StateParentViewable {
    func hideChildControllersIfNeeded()
}

extension StateParentViewable where Self:UIViewController {
    
    func hideChildControllersIfNeeded() {
        for vc in self.childViewControllers {
            vc.willMove(toParentViewController: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
    }
}


class ContentListingFlowLayout: UICollectionViewFlowLayout {
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}


protocol LoadingStateDisplayable {
    
    var loadingIndicatorStateViewController: UIViewController { get }
}

protocol EmptyStateDisplayable {
    
    var emptyStateViewController: UIViewController { get }
}

protocol ErrorStateDisplayable {
    
    var errorStateViewController: UIViewController { get }
}
