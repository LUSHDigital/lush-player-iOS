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
        
        let programmeNib = UINib(nibName: "ProgrammeCollectionViewCell", bundle: Bundle.main)
        collectionView.register(programmeNib, forCellWithReuseIdentifier: "ProgrammeCell")
        
        LushPlayerController.shared.fetchProgrammes(for: .TV, with: { [weak self] (error, programmes) in
            
            if let error = error, let welf = self {
                UIAlertController.presentError(error, in: welf)
            }
            
            self?.redraw()
        })
        
        LushPlayerController.shared.fetchProgrammes(for: .radio, with: { [weak self] (error, programmes) in
            
            if let error = error, let welf = self {
                UIAlertController.presentError(error, in: welf)
            }
            
            self?.redraw()
        })
        
        collectionView.contentInset = UIEdgeInsets(top: 180, left: 112, bottom: 62, right: 112)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
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
        
        return CGSize(width: 520, height: 492)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let allProgrammes = allProgrammes else {
            return
        }
        
        show(programme: allProgrammes[indexPath.item])
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
        
        guard let programmeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgrammeCell", for: indexPath) as? ProgrammeCollectionViewCell, let allProgrammes = allProgrammes else {
            
            return collectionView.dequeueReusableCell(withReuseIdentifier: "ProgrammeCell", for: indexPath)
        }
        
        let programme = allProgrammes[indexPath.item]
                
        programmeCell.imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
        programmeCell.formatLabel.text = programme.media.displayString()
        programmeCell.titleLabel.text = programme.title
        programmeCell.dateLabel.text = programme.date?.timeAgo
        
        return programmeCell
    }
}
