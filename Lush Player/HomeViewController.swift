//
//  HomeViewController.swift
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

/// The view controller for the `Home` content of the app
class HomeViewController: RefreshableViewController {

    /// The collection view for displaying programmes
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// A local array of all programmes which are available from the API
    var allProgrammes: [Programme]?
    
    var shouldAnimateCellsIn: Bool = true
    var animatedCellsDictionary = [IndexPath: Bool]()
    var shouldAnimateInitialCells: Bool = true
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Register the programme collection view cell with the collection view
        let programmeNib = UINib(nibName: "ProgrammeCollectionViewCell", bundle: Bundle.main)
        collectionView.register(programmeNib, forCellWithReuseIdentifier: "ProgrammeCell")
        
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
        
        // Set up content insets
        collectionView.contentInset = UIEdgeInsets(top: 180, left: 112, bottom: 62, right: 112)
        
        // Set up cell spacing
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 64
            flowLayout.minimumInteritemSpacing = 64
        }
    }

    override func redraw() {
        
        // Sort the programmes by their date in chronological order
        allProgrammes = LushPlayerController.shared.programmes.flatMap { (keyPair) in
            return keyPair.value
        }.sorted(by: { (p1, p2) -> Bool in
            
            guard let p1Date = p1.date, let p2Date = p2.date else {
                return false
            }
            
            return p1Date > p2Date
        })
        
        // Redraw
        collectionView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // A fixed size is okay here, because we're always displaying on a 1080p screen
        return CGSize(width: 520, height: 492)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let allProgrammes = allProgrammes else {
            return
        }
        
        // Show a programme when it is selected
        show(programme: allProgrammes[indexPath.item])
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
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
        
        // Customise the cell
        programmeCell.imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
        programmeCell.formatLabel.text = programme.media.displayString()
        programmeCell.titleLabel.text = programme.title
        programmeCell.dateLabel.text = programme.date?.timeAgo
        
        return programmeCell
    }
}
