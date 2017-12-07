//
//  ContentListingViewController.swift
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


// A base viewcontroller for displaying a list of content, uses the viewState enum to control the UI state, this provides states for loading, loaded, empty and error.
class ContentListingViewController<T>: UIViewController,StateParentViewable,
                                        UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    typealias Model = T
    
    // View state property controls the view controllers UI state, on changing the view reloads, the default state is loading
    var viewState: ContentListingViewState<Model> = .loading {
        didSet {
            self.redraw()
        }
    }
    
    var shouldAnimateCellsIn: Bool = true
    var animatedCellsDictionary = [IndexPath: Bool]()
    var shouldAnimateInitialCells: Bool = true
    
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
    
    
    // Collection view for displaying the content items
    var collectionView: UICollectionView?
    
    func redraw() {
        
        switch viewState {
            
        case .loading:
            
            hideChildControllersIfNeeded()
            loadingViewController.view.frame = view.bounds
            loadingViewController.willMove(toParentViewController: self)
            addChildViewController(loadingViewController)
            self.view.addSubview(loadingViewController.view)
            loadingViewController.didMove(toParentViewController: self)
            
        case .loaded(_):
            
            hideChildControllersIfNeeded()
            collectionView?.performBatchUpdates({ 
                self.collectionView?.reloadSections([0])
            }, completion: nil)
        
        case .empty:
            
            hideChildControllersIfNeeded()
            emptyStateViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            emptyStateViewController.view.frame = view.bounds
            addChildViewController(emptyStateViewController)
            self.view.addSubview(emptyStateViewController.view)
            emptyStateViewController.didMove(toParentViewController: self)
            collectionView?.reloadData()
            
        case .error(_):
            
            hideChildControllersIfNeeded()
            errorStateViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            errorStateViewController.view.frame = view.bounds
            addChildViewController(errorStateViewController)
            self.view.addSubview(errorStateViewController.view)
            errorStateViewController.didMove(toParentViewController: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionViewLayout = ContentListingFlowLayout()
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionViewLayout.minimumLineSpacing = 20
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: collectionViewLayout)
        guard let collectionView = collectionView else { return }
        self.view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nib = UINib(nibName: "LargePictureStandardMediaCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "StandardMediaCellId")
        
        setupConstraints()
        
        redraw()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    func setupConstraints() {
        collectionView?.bindFrameToSuperviewBounds()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch viewState {
        case .loaded(let models):
            return models.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "StandardMediaCell", for: indexPath)
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if collectionView == nil {
            return
        }
        
        guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfColumns: CGFloat = numberOfColumnsForSizeClass()
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let currentTotalWidth = collectionView.bounds.width - layout.sectionInset.left - layout.sectionInset.right
        
        
        let cellWidth = (currentTotalWidth - (numberOfColumns-1) * layout.sectionInset.left) / numberOfColumns
        let cellHeight = CGFloat(Double(cellWidth) * 1.3)
        
        let cellSize = CGSize(width: cellWidth , height: cellHeight)
        return cellSize
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if cell.frame.midY >= collectionView.bounds.maxY {
            shouldAnimateInitialCells = false
        }
        
        if shouldAnimateInitialCells {
            
            if animatedCellsDictionary[indexPath] == nil {
                cell.alpha = 0
                
                UIView.animate(withDuration: 0.4, delay: 0.04 * Double(indexPath.item), options: .curveEaseIn, animations: { 
                    cell.alpha = 1
                }, completion: nil)
                
                animatedCellsDictionary[indexPath] = true
                return
            }
        }
        
        
        if shouldAnimateCellsIn {
            
            if animatedCellsDictionary[indexPath] == nil {
                cell.alpha = 0
                
                UIView.animate(withDuration: 0.4, animations: {
                    cell.alpha = 1
                })
                
                animatedCellsDictionary[indexPath] = true
            }
        }
    }
    
    
    func numberOfColumnsForSizeClass() -> CGFloat {
        switch (view.traitCollection.verticalSizeClass, view.traitCollection.horizontalSizeClass) {
        case (.regular, .regular):
            return 3
        case (.regular, .compact):
            return 1
        case (.compact, .compact):
            return 2
        case (.compact, .regular):
            return 2
        default:
            return 1
        }
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


enum ContentListingViewState<Model> {
    
    case loaded([Model])
    case empty
    case error(Error)
    case loading
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
