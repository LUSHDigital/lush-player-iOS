//
//  SearchResultsViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 03/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class SearchResultsViewController: ContentListingViewController<Programme> {


    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.emptyStateViewController = {
                let storyboard = UIStoryboard(name: "Search", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SearchEmptyResultsViewControllerId") as? SearchEmptyResultsViewController
                return vc ?? SearchEmptyResultsViewController()
            }()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewState = .empty
        
        guard let emptyStateViewController = emptyStateViewController as? SearchEmptyResultsViewController else { return }
        
        emptyStateViewController.descriptionLabel.text = "Search for a programme"
        emptyStateViewController.searchAgainButton.setTitle("Search".uppercased(), for: .normal)
        
        let nib = UINib(nibName: "SearchCollectionViewCell", bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: "SearchCollectionViewCell")
        
        collectionView?.keyboardDismissMode = .interactive
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                collectionView?.contentInset = UIEdgeInsets(top: 120, left: 0, bottom: 44, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard case let .loaded(searchResults) = viewState else {
            return UICollectionViewCell()
        }
        
        let result = searchResults[indexPath.item]
        
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as? SearchCollectionViewCell {
            
            cell.titleLabel.text = result.title
            cell.imageView.set(imageURL: result.thumbnailURL, withPlaceholder: nil, completion: nil)
            cell.mediaLabel.text = result.media.displayString()
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height:CGFloat = 100.0
        
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard case let .loaded(searchResults) = viewState else {
            return
        }
        
        let result = searchResults[indexPath.item]
        
        // Set the dummy programme's media type...
        var media: Programme.Media = .TV
        if result.media == .radio {
            media = .radio
        }
        
        let programmes = LushPlayerController.shared.programmes[media]
        if let foundProgramme = programmes?.filter({ $0.id == result.id }).first {
            
            performSegue(withIdentifier: "MediaDetailSegue", sender: foundProgramme)
            return
        }
        
        // Else Create a dummy Programme dictionary representation from the search result
        var programmeDict: [AnyHashable : Any] = ["id":result.id]
        if let title = result.title {
            programmeDict["title"] = title
        }
        if let thumbnailURL = result.thumbnailURL {
            programmeDict["thumbnail"] = thumbnailURL.absoluteString
        }
        

        
        // Show the selected programme created from the selected search result
        guard let programme = Programme(dictionary: programmeDict, media: media) else { return }

        performSegue(withIdentifier: "MediaDetailSegue", sender: programme)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "MediaDetailSegue" {
            if let destination = segue.destination as? MediaDetailViewController, let programme = sender as? Programme {
                
                destination.programme = programme
            }
        }
    }
}


