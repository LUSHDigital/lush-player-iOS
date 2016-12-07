//
//  SearchViewController.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import UIKit

class SearchResultsViewController: RefreshableViewController {
    
    var searchTerm: String?
    
    var searchResults: [SearchResult]?
    
    @IBOutlet weak var resultsCollectionView: UICollectionView!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ProgrammeCollectionViewCell", bundle: nil)
        resultsCollectionView.register(nib, forCellWithReuseIdentifier: "ProgrammeCell")
        
        resultsCollectionView.contentInset = UIEdgeInsets(top: 60, left: 92, bottom: 0, right: 92)
        
        guard let flowLayout = resultsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumLineSpacing = 36
    }

    override func refresh() {
        
        guard let searchTerm = searchTerm, !searchTerm.isEmpty else {
            
            searchResults = []
            redraw()
            return
        }
        
        LushPlayerController.shared.performSearch(for: searchTerm, with: { [weak self] (error, results) in
        
            if let error = error, let welf = self {
                UIAlertController.presentError(error, in: welf)
            }
            
            self?.searchResults = results
            self?.redraw()
        })
    }
    
    override func redraw() {
        
        resultsCollectionView.reloadData()
    }
}

extension SearchResultsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        searchTerm = searchController.searchBar.text
        refresh()
    }
}

extension SearchResultsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 400, height: 420)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let results = searchResults else { return }
        
        let result = results[indexPath.item]
        
        var programmeDict: [AnyHashable : Any] = ["id":result.id]
        if let title = result.title {
            programmeDict["title"] = title
        }
        if let thumbnailURL = result.thumbnailURL {
            programmeDict["thumbnail"] = thumbnailURL.absoluteString
        }
        
        var media: Programme.Media = .TV
        if result.media == .radio {
            media = .radio
        }
        
        guard let programme = Programme(dictionary: programmeDict, media: media) else { return }
        show(programme: programme)
    }
}

extension SearchResultsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let results = searchResults else { return 0 }
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let programmeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgrammeCell", for: indexPath) as? ProgrammeCollectionViewCell, let searchResults = searchResults else {
            
            return collectionView.dequeueReusableCell(withReuseIdentifier: "ProgrammeCell", for: indexPath)
        }
        
        let result = searchResults[indexPath.item]
        
        programmeCell.imageView.set(imageURL: result.thumbnailURL, withPlaceholder: nil, completion: nil)
        programmeCell.formatLabel.text = result.media.displayString()
        programmeCell.titleLabel.text = result.title
        programmeCell.dateLabel.text = ""
        
        return programmeCell
    }
}
