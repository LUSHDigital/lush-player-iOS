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
        
        containerView = UIView(frame: self.view.bounds)
        view.addSubview(containerView)
        containerView.isUserInteractionEnabled = true

        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
        menuCollectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        menuCollectionView.backgroundColor = UIColor(colorLiteralRed: 51/225, green: 51/225, blue: 51/225, alpha: 1)
        
        let nib = UINib(nibName: "MenuCollectionViewCell", bundle: nil)
        
        menuCollectionView.register(nib, forCellWithReuseIdentifier: "MenuCollectionViewCell")
        
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        view.addSubview(menuCollectionView)
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
        
        let size: CGSize = menuItems[indexPath.item].title.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
        return CGSize(width: size.width + 45.0, height: 50)
    }
}


struct MenuItem {
    
    var title: String
    var identifier: String
    
}
