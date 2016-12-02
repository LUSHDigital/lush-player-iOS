//
//  EpisodesViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

class EpisodesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        let cellNib = UINib(nibName: "EpisodeCollectionViewCell", bundle: Bundle.main)
        
        collectionView.register(cellNib, forCellWithReuseIdentifier: "EpisodeCell")
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        super.viewDidLoad()
        
        collectionView.reloadData()
    }
}

extension EpisodesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = view.bounds.height
        return CGSize(width: height, height: height)
    }
}

extension EpisodesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let episodeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EpisodeCell", for: indexPath)
        
        return episodeCell
    }
}
