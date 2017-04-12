//
//  MenuContainerViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 24/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

class MenuContainerViewController: UIViewController {
    
    var menuCollectionView: UICollectionView!
    var menuItems = [MenuItem]() {
        didSet {
            menuCollectionView.reloadData()
        }
    }
    
    var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* container view */
        containerView = UIView(frame: self.view.bounds)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.isUserInteractionEnabled = true
        view.addSubview(containerView)


        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
        menuCollectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        if let flowLayout = menuCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            flowLayout.sectionInset = .zero
        }
        menuCollectionView.backgroundColor = UIColor(colorLiteralRed: 51/225, green: 51/225, blue: 51/225, alpha: 1)
        
        let nib = UINib(nibName: "MenuCollectionViewCell", bundle: nil)
        menuCollectionView.register(nib, forCellWithReuseIdentifier: "MenuCollectionViewCell")
        
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        view.addSubview(menuCollectionView)
        layoutMenu()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let firstIndex = IndexPath(item: 0, section: 0)
        menuCollectionView.selectItem(at: firstIndex, animated: false, scrollPosition: .left)
    }
    
    func layoutMenu() {
        
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



extension MenuContainerViewController: UICollectionViewDelegate {

    
}

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
        
        if menuItems.count > 3 {
            let size: CGSize = menuItems[indexPath.item].title.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
            return CGSize(width: size.width + 45.0, height: 50)
        }
        
        let width = collectionView.bounds.size.width / CGFloat(menuItems.count)
        return CGSize(width: width, height: 50)
        
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


struct MenuItem {
    
    var title: String
    var identifier: String
    
}
