//
//  ChannelCollectionViewController.swift
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

// View controller displaying a collection of channels that contain programmes
class ChannelCollectionViewController: UICollectionViewController, StateParentViewable {
    
    // State machine to control to handle UI of the app when performing network requests
    var viewState: ContentListingViewState<Channel> = .loading {
        didSet {
            self.redraw()
        }
    }

    // Reuse Identifier for the Channel Collection Cell
    private let cellReuseId = String(describing: ChannelCollectionViewCell.self)
    
    // Loading view controller for when we are performing network requests
    var loadingViewController = LoadingViewController()
    
    // Connection error state view controller for when we encounter an error with the network
    lazy var connectionErrorViewController: ConnectionErrorViewController = {
        let storyboard = UIStoryboard(name: "ConnectionErrorScreen", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as? ConnectionErrorViewController
        return vc ?? ConnectionErrorViewController()
    }()
    
    // Empty state view controller for when we recieve a response but it has no data
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
            
            channelFlowLayout.minimumLineSpacing = 1
            channelFlowLayout.minimumInteritemSpacing = 1
        }
        
        self.collectionView?.delegate = self
        
        // Fetch the channels from the API
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionViewLayout.invalidateLayout()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    /// Displays and Hides view controllers based on the current state of the app and the requests it makes
    func redraw() {
        
        switch viewState {
            
        case .loading:
            // Loading so lets show an indicator
            hideChildControllersIfNeeded()
            loadingViewController.view.frame = view.bounds
            loadingViewController.willMove(toParentViewController: self)
            addChildViewController(loadingViewController)
            self.view.addSubview(loadingViewController.view)
            loadingViewController.didMove(toParentViewController: self)
            
        case .loaded(_):
            // We have data so lets hide any previous loading/error states and reload the collectionView
            hideChildControllersIfNeeded()
            collectionView?.reloadData()
            
        case .empty:
            // Show an empty state
            hideChildControllersIfNeeded()
            emptyStateViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            emptyStateViewController.view.frame = view.bounds
            addChildViewController(emptyStateViewController)
            self.view.addSubview(emptyStateViewController.view)
            emptyStateViewController.didMove(toParentViewController: self)
            collectionView?.reloadData()
            
        case .error(_):
            // Show an error state
            hideChildControllersIfNeeded()
            errorStateViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            errorStateViewController.view.frame = view.bounds
            addChildViewController(errorStateViewController)
            self.view.addSubview(errorStateViewController.view)
            errorStateViewController.didMove(toParentViewController: self)
        }
    }
    
    
    /// Refreshes the model for this view controller, call only when needed for example on first load
    /// Todo: - Consider loading a cached copy in the future to speed up initial load
    func refresh() {
        
        // Set the initial state as loading before/while we fetch channels
        viewState = .loading
        
        LushPlayerController.shared.fetchChannels { (error, channels) -> (Void) in
            
            // If we get an error show our error state and provide a retry again
            if let error = error {
                self.connectionErrorViewController.retryAction = { [weak self] in
                    self?.refresh()
                }
                self.viewState = ContentListingViewState.error(error)
                return
            }
            
            if let channels = channels {
                // Set our state as loaded and provide our fetched channels
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

    // Called on orientation changes, we invalidate the layout so we can support different layouts for different orientations
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
                
                // Use our imageView extension to fetch the image asyncronously, use a cached image if we have it as a placeholder so it appears snappy for users
                _cell.imageView.set(imageURL: url, withPlaceholder: ImageCacher.retrieveImage(at: url.lastPathComponent), completion: { (image, error) -> (Void) in
                    // Lets the cache the image so its quick to load next time
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
        
        // Constants for rows/columns
        let numberOfColumns: CGFloat = 1
        var numberOfRows: CGFloat = 7
        
        if case let .loaded(channels) = viewState {
            let rowsToShow = max(channels.count, 4)
            numberOfRows = CGFloat(rowsToShow)
        }
        
        var minimumLineSpacing: CGFloat = 0.0
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            minimumLineSpacing = flowLayout.minimumLineSpacing
        }

        let cellWidth = collectionView.bounds.width / numberOfColumns
        let cellHeight: CGFloat
        
        switch (UIDevice.current.orientation) {
            
        case (.landscapeLeft), (.landscapeRight):
            // Since we are landscape we want the cells to be roughly the same size as if the device was portrait, so use collectionView width rather than height an
            cellHeight = collectionView.bounds.width / numberOfRows
            
        default:
            // Cell height to fit 7 cells vertically down, must take account of the line spacing and the status bar to fit exactly
            cellHeight = (collectionView.bounds.height / numberOfRows) - (minimumLineSpacing + (UIApplication.shared.statusBarFrame.height / numberOfRows))
        }

        
        let cellSize = CGSize(width: cellWidth, height: cellHeight)
        return cellSize
    }
}
