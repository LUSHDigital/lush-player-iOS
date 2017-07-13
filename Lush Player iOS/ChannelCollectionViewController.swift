//
//  ChannelCollectionViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 20/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

// View controller displaying a collection of channels that contain programmes
class ChannelCollectionViewController: UICollectionViewController, StateParentViewable {
    
    var viewState: ContentListingViewState<Channel> = .loading {
        didSet {
            self.redraw()
        }
    }

    // Reuse Identifier for the Channel Collection Cell
    private let cellReuseId = String(describing: ChannelCollectionViewCell.self)
    
    var loadingViewController = LoadingViewController()
    
    lazy var connectionErrorViewController: ConnectionErrorViewController = {
        let storyboard = UIStoryboard(name: "ConnectionErrorScreen", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as? ConnectionErrorViewController
        return vc ?? ConnectionErrorViewController()
    }()
    
    lazy var emptyStateViewController: UIViewController = {
        let storyboard = UIStoryboard(name: "EmptyStateScreen", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as? EmptyErrorViewController
        return vc ?? EmptyErrorViewController()
    }()
    
    var errorStateViewController: UIViewController {
        return connectionErrorViewController
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        
       // Register cell classes
        let nib = UINib(nibName: cellReuseId, bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: cellReuseId)
        
        // Set up all spacing for each collection view
        if let channelFlowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            
            channelFlowLayout.minimumLineSpacing = 2
            channelFlowLayout.minimumInteritemSpacing = 1
        }
        
        self.collectionView?.delegate = self
        
        refresh()
    }
    
    func redraw() {
        
        switch viewState {
            
        case .loading():
            
            hideChildControllersIfNeeded()
            loadingViewController.view.frame = view.bounds
            loadingViewController.willMove(toParentViewController: self)
            addChildViewController(loadingViewController)
            self.view.addSubview(loadingViewController.view)
            loadingViewController.didMove(toParentViewController: self)
            
        case .loaded(_):
            
            hideChildControllersIfNeeded()
            collectionView?.reloadData()
            
        case .empty():
            
            hideChildControllersIfNeeded()
            emptyStateViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            emptyStateViewController.view.frame = view.bounds
            addChildViewController(emptyStateViewController)
            self.view.addSubview(emptyStateViewController.view)
            emptyStateViewController.didMove(toParentViewController: self)
            collectionView?.reloadData()
            
        case .error(let _):
            
            hideChildControllersIfNeeded()
            errorStateViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            errorStateViewController.view.frame = view.bounds
            addChildViewController(errorStateViewController)
            self.view.addSubview(errorStateViewController.view)
            errorStateViewController.didMove(toParentViewController: self)
        }
    }
    
    func refresh() {
        
        viewState = .loading
        
        LushPlayerController.shared.fetchChannels { (error, channels) -> (Void) in
            if let error = error {
                self.connectionErrorViewController.retryAction = { [weak self] in
                    self?.refresh()
                }
                self.viewState = ContentListingViewState.error(error)
                return
            }
            
            if let channels = channels {
                
                self.viewState = .loaded(channels)
                return
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowChannelSegue" {
            guard let vc = segue.destination as? ChannelListingContainerViewController else { return }
            
            guard let channel = sender as? Channel else { return }
            vc.childListingViewController?.selectedChannel = channel
            vc.channel = channel
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionViewLayout.invalidateLayout()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        collectionViewLayout.invalidateLayout()
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if case let .loaded(channels) = self.viewState {
            return channels.count
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath)
        
        guard case let .loaded(channels) = viewState else {
            return cell
        }
        
        if let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath) as? ChannelCollectionViewCell {
            
            // Set the cell's image to the channel's image
            let channel = channels[indexPath.item]
            
            if let url = channel.imageUrl {
                
                _cell.imageView.set(imageURL: url, withPlaceholder: ImageCacher.retrieveImage(at: url.lastPathComponent), completion: { (image, error) -> (Void) in
                    if let _image = image {
                        ImageCacher.cache(_image, with: url.lastPathComponent)
                    }
                })

            } else {
                _cell.imageView.image = nil
            }
            return _cell
        }
        
        
        return cell
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard case let .loaded(channels) = viewState else {
            return
        }
        
        let channel = channels[indexPath.item]
        performSegue(withIdentifier: "ShowChannelSegue", sender: channel)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }
}



extension ChannelCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Change the cell collumns on rotation
        var numberOfColumns: CGFloat = 2
        var rowHeight: CGFloat = 3
        
        switch (UIDevice.current.orientation) {
            
            case (.landscapeLeft):
                fallthrough
            case (.landscapeRight):
            numberOfColumns = 3
            rowHeight = 2
            default:
            numberOfColumns = 2
        }
        
        
        let cellWidth = collectionView.bounds.width / numberOfColumns - 1
        let cellHeight = collectionView.bounds.height / rowHeight - 2
        
        let cellSize = CGSize(width: cellWidth, height: cellHeight)
        return cellSize
    }
}
