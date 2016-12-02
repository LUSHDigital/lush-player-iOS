//
//  HomeViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

class HomeViewController: RefreshableViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var allProgrammes: [Programme]?
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let programmeNib = UINib(nibName: "EpisodeCollectionViewCell", bundle: Bundle.main)
        collectionView.register(programmeNib, forCellWithReuseIdentifier: "EpisodeCell")
        
        LushPlayerController.shared.fetchProgrammes(for: .TV, with: { [weak self] (error, programmes) in
            
            self?.redraw()
        })
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 64)
            flowLayout.minimumLineSpacing = 64
            flowLayout.minimumInteritemSpacing = 64
        }
        
        // Do any additional setup after loading the view.
    }

    override func redraw() {
        
        allProgrammes = LushPlayerController.shared.programmes.flatMap { (keyPair) in
            return keyPair.value
        }.sorted(by: { (p1, p2) -> Bool in
            
            guard let p1Date = p1.date, let p2Date = p2.date else {
                return false
            }
            
            return p1Date > p2Date
        })
        
        collectionView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 800, height: 720)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let _ = allProgrammes else {
            return 0
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let allProgrammes = allProgrammes else {
            return 0
        }
        
        return allProgrammes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let episodeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EpisodeCell", for: indexPath) as? EpisodeCollectionViewCell, let allProgrammes = allProgrammes else {
            
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EpisodeCell", for: indexPath)
        }
        
        let programme = allProgrammes[indexPath.item]
        
        episodeCell.imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
        episodeCell.formatLabel.text = programme.media.rawValue
        episodeCell.titleLabel.text = programme.title
        episodeCell.dateLabel.text = programme.date?.timeAgo
        
        return episodeCell
    }
}
