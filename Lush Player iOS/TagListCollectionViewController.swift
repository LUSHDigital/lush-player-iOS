//
//  TagListCollectionViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 22/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class TagListCollectionViewController: UICollectionViewController {
    
    var tags = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        let nib = UINib(nibName: "TagCollectionViewCell", bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: "TagCollectionViewCell")
        
        tags = ["something", "hello", "test string", "smol", "#lush"]

        collectionView?.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let tag = tags[indexPath.item]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as? TagCollectionViewCell {
            cell.tagLabel.text = tag
            return cell
        }
        // Configure the cell
    
        return UICollectionViewCell()
    }
}


extension TagListCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size: CGSize = tags[indexPath.row].size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
        return CGSize(width: size.width + 45.0, height: 40)
    }
}
