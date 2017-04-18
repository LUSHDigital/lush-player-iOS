//
//  SearchViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 03/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

class SearchViewController: UIViewController {
    
    
    @IBOutlet weak var searchContainerView: UIView!
    
    var searchQueue: OperationQueue = OperationQueue()
    
    var searchTerm: String?

    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResultsController: SearchResultsViewController? {
       return childViewControllers.filter({ $0 is SearchResultsViewController}).first as? SearchResultsViewController
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        
        self.navigationController?.isNavigationBarHidden = true
        searchQueue.maxConcurrentOperationCount = 1
        searchQueue.qualityOfService = .userInitiated
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerKeyboardNotifications()
        UIView.animate(withDuration: 0.3) { 
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            let contentInsets = UIEdgeInsets(top: 120, left: 0, bottom: keyboardSize.height, right: 0)
            searchResultsController?.collectionView.contentInset = contentInsets
            searchResultsController?.collectionView.scrollIndicatorInsets = contentInsets
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        
            let contentInsets = UIEdgeInsets(top: 120, left: 0, bottom: 44, right: 0)
            searchResultsController?.collectionView.contentInset = contentInsets
            searchResultsController?.collectionView.scrollIndicatorInsets = contentInsets
    }
    
    
    func setupSearchBar() {
        
        let appearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        appearance.textColor = .white
        appearance.keyboardAppearance = .dark
        
        let image = UIImage.createImage(with: UIColor(colorLiteralRed: 51/225, green: 51/225, blue: 51/225, alpha: 1), size: CGSize(width: 200, height: 60))
        
        searchBar.setSearchFieldBackgroundImage(image, for: .normal)
        searchBar.tintColor = .white
        
        searchBar.barTintColor = .white
        searchBar.barStyle = .default
        searchBar.searchBarStyle = .minimal
        searchBar.layer.borderColor = UIColor.clear.cgColor
        searchBar.delegate = self
    }
    
    
    func performSearch() {
        
        guard let term = searchTerm else { return }
        
        LushPlayerController.shared.performSearch(for: term, with: { [weak self] (error: Error?, searchResults: [SearchResult]?) -> (Void) in
            print("finished")
            if let error = error {
                DispatchQueue.global().async(execute: {
                    DispatchQueue.main.sync{
                        self?.searchResultsController?.viewState = .error(error)
                    }
                })
            }
            
            if let searchResults = searchResults {
                
                DispatchQueue.global().async(execute: {
                    DispatchQueue.main.sync{
                        
                        if searchResults.isEmpty {
                            self?.searchResultsController?.viewState = .empty
                            if let emptyStateViewController = self?.searchResultsController?.emptyStateViewController as? SearchEmptyResultsViewController {
                                emptyStateViewController.descriptionLabel.text = "No search results found"
                                emptyStateViewController.searchAgainButton.setTitle("Search Again".uppercased(), for: .normal)
                            }
                            return
                        }
                        
                        self?.searchResultsController?.viewState = .loaded(searchResults)
                    }
                })
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
        guard !searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.performSearch), object: nil)
            return
        }
        
        self.searchTerm = searchText
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.performSearch), object: nil)
        searchResultsController?.viewState = .loading
        self.perform(#selector(self.performSearch), with: nil, afterDelay: 0.4)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
}


extension SearchViewController: UISearchControllerDelegate {
    
}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchTerm = searchController.searchBar.text else { return }
        self.searchTerm = searchTerm
        
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.performSearch), object: nil)
        searchResultsController?.viewState = .loading
        self.perform(#selector(self.performSearch), with: nil, afterDelay: 0.4)

    
    }
}
