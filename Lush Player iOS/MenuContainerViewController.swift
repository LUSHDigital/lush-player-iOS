//
//  MenuContainerViewController.swift
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

// Base menu container view controller, displays a list of menu options at teh top of the screen with a child listing controller underneath, should be subclassed to provide custom menu options
class MenuContainerViewController: UIViewController {
    
    // Collection view for displaying menu options
    var menuCollectionView: UICollectionView!
    
    // Menu items models to display
    var menuItems = [MenuItem]() {
        didSet {
            menuCollectionView.reloadData()
        }
    }
    
    // Container view for displaying programmes
    var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Container view setup
        containerView = UIView(frame: self.view.bounds)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.isUserInteractionEnabled = true
        view.addSubview(containerView)

        // Menu Collectionview setup
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
        menuCollectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        
        // Layout settings
        if let flowLayout = menuCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            flowLayout.sectionInset = .zero
            flowLayout.scrollDirection = .horizontal
        }
        
        menuCollectionView.backgroundColor = UIColor(red: 51/225, green: 51/225, blue: 51/225, alpha: 1)
        
        // Register Cell
        let nib = UINib(nibName: "MenuCollectionViewCell", bundle: nil)
        menuCollectionView.register(nib, forCellWithReuseIdentifier: "MenuCollectionViewCell")
        
        // Settings
        menuCollectionView.showsHorizontalScrollIndicator = false
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        view.addSubview(menuCollectionView)
        layoutMenu()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setFirstMenuItemAsSelected()
    }
    
    func setFirstMenuItemAsSelected() {
        if !menuItems.isEmpty {
            let firstIndex = IndexPath(item: 0, section: 0)
            menuCollectionView.selectItem(at: firstIndex, animated: false, scrollPosition: .left)
        }
    }
    
    func layoutMenu() {
        
        // Pin the menu to the top, with 50 height
        menuCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: menuCollectionView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: menuCollectionView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: menuCollectionView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: menuCollectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
            ])
        view.setNeedsUpdateConstraints()
    }
}



// MARK: - UICollectionViewDelegate
extension MenuContainerViewController: UICollectionViewDelegate {

    // Stub for if we need any delegate methods
}


// MARK: - UICollectionViewDataSource
extension MenuContainerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let menuItem = menuItems[indexPath.item]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCollectionViewCell", for: indexPath) as? MenuCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.titleLabel.text = menuItem.title
        return cell
    }
    
}

extension MenuContainerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Menu item width sizing
        //
        // Items should have equal width if there are 3 or less, unless any of the options are larger than the total menu width divided by the number of items
        // Otherwise items take up as much space as they require and the menu scrolls
        
        
        let equallyDividedWidth = collectionView.bounds.size.width / CGFloat(menuItems.count)
        
        let sizeFromText = menuItems[indexPath.item].title.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)])
        
        if sizeFromText.width >= equallyDividedWidth {
            return CGSize(width: sizeFromText.width + 45.0, height: 50)
        }
    
        if menuItems.count > 3 {
            return CGSize(width: sizeFromText.width + 45.0, height: 50)
        }
    
        return CGSize(width: equallyDividedWidth, height: 50)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if menuCollectionView == nil { return }
        
        guard let flowLayout = menuCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        flowLayout.invalidateLayout()
    }
}

// Model for displaying a MenuItem
struct MenuItem {
    
    var title: String
    var identifier: String
}
