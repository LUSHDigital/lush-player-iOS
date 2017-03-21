//
//  HomeCollectionViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 21/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

private let reuseIdentifier = "HomeCellId"

class HomeCollectionViewController: UICollectionViewController {
    
    private var state: ViewState = .loading
    
    var allProgrammes: [Programme]?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let nib = UINib(nibName: "StandardMediaCell", bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    
        
        // Fetch the latest TV programmes
        LushPlayerController.shared.fetchProgrammes(for: .TV, with: { [weak self] (error, programmes) in
            
            if let error = error, let welf = self {
                UIAlertController.presentError(error, in: welf)
            }
            
            self?.redraw()
        })
        
        // Fetch the latest radio programmes
        LushPlayerController.shared.fetchProgrammes(for: .radio, with: { [weak self] (error, programmes) in
            
            if let error = error, let welf = self {
                UIAlertController.presentError(error, in: welf)
            }
            
            self?.redraw()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.isNavigationBarHidden = true
        }
        
    }
    
    func redraw() {
        // Sort the programmes by their date in chronological order
        allProgrammes = LushPlayerController.shared.programmes.flatMap { (keyPair) in
            return keyPair.value
            }.sorted(by: { (p1, p2) -> Bool in
                
                guard let p1Date = p1.date, let p2Date = p2.date else {
                    return false
                }
                
                return p1Date > p2Date
            })
        
        if let allProgrammes = allProgrammes, !allProgrammes.isEmpty {
            state = .loaded(allProgrammes)
            self.collectionView?.reloadData()
        }
        // Redraw
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch state {
        case .loading:
            return 0
        case .empty:
            return 0
        case .loaded:
            return 1
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch state {
        case .loading:
            return 0
        case .empty:
            return 0
        case .loaded(let programmes):
            return programmes.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let programmes =  allProgrammes {
            
            let programme = programmes[indexPath.item]
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? StandardMediaCell {
                
                cell.imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
                cell.mediaTypeLabel.text = programme.media.displayString()
                cell.titleLabel.text = programme.title
                cell.datePublishedLabel.text = programme.date?.timeAgo
                return cell
            }
        }

        return UICollectionViewCell()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let programmes = allProgrammes {
            
            let programme = programmes[indexPath.item]
            showProgramme(programme: programme)
        }
    }
    
    func showProgramme(programme: Programme) {
        self.performSegue(withIdentifier: "MediaDetailSegue", sender: programme)
    }
    
    private enum ViewState {
        
        case loading
        case empty
        case loaded([Programme])
    }
}



extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = collectionView.bounds.width - 40
        let cellHeight = cellWidth * 0.9
        let cellSize = CGSize(width: cellWidth , height: cellHeight)
        return cellSize
    }
}
