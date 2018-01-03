//
//  SearchViewController.swift
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

// Parent Search view controller for managing the users input, performing search requests to the API and passing the results to a child controller
class SearchViewController: UIViewController {
    
    // Container view for containing the results view
    @IBOutlet weak var searchContainerView: UIView!

    // Search bar UI where the user can type in queries
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Search results view controller for displaying results
    var searchResultsController: SearchResultsViewController? {
       return childViewControllers.filter({ $0 is SearchResultsViewController}).first as? SearchResultsViewController
    }
    
    // Term searched by the user
    var searchTerm: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        
        self.navigationController?.isNavigationBarHidden = true
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
    
    // Setup keyboard observers so we can adjust the view when a keyboard appears
    func registerKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Scroll the view to compensate the keyboard appearing
    @objc func keyboardWillShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            let contentInsets = UIEdgeInsets(top: 120, left: 0, bottom: keyboardSize.height, right: 0)
            searchResultsController?.collectionView?.contentInset = contentInsets
            searchResultsController?.collectionView?.scrollIndicatorInsets = contentInsets
        }
    }
    
    // Scroll the view to compensate the keyboard hiding
    @objc func keyboardWillHide(notification: Notification) {
        
            let contentInsets = UIEdgeInsets(top: 120, left: 0, bottom: 44, right: 0)
            searchResultsController?.collectionView?.contentInset = contentInsets
            searchResultsController?.collectionView?.scrollIndicatorInsets = contentInsets
    }
    
    // Style search bar to match designs
    func setupSearchBar() {
        
        let appearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        appearance.textColor = .white
        appearance.keyboardAppearance = .dark
        
        let image = UIImage.createImage(with: UIColor(red: 51/225, green: 51/225, blue: 51/225, alpha: 1), size: CGSize(width: 200, height: 60))
        searchBar.setSearchFieldBackgroundImage(image, for: .normal)
        searchBar.tintColor = .white
        searchBar.barTintColor = .white
        searchBar.barStyle = .default
        searchBar.searchBarStyle = .minimal
        searchBar.layer.borderColor = UIColor.clear.cgColor
        searchBar.delegate = self
    }
    
    // Queries the LUSH player API for search results, and passes them to the results controller
    @objc func performSearch() {
        
        // Check we have a search term, or exit out now
        guard let term = searchTerm else { return }
        
        // Request the API for search results using the term
        LushPlayerController.shared.performSearch(for: term, with: { [weak self] (error: Error?, searchResults: [Programme]?) -> (Void) in
            
            // Handle and show an error if we get one
            if let error = error {
                DispatchQueue.global().async(execute: {
                    DispatchQueue.main.sync{
                        self?.searchResultsController?.viewState = .error(error)
                    }
                })
            }
            
            // If we have search results
            if let searchResults = searchResults {
                
                DispatchQueue.global().async(execute: {
                    DispatchQueue.main.sync{
                        
                        // Check we have some results, if not show the empty state
                        if searchResults.isEmpty {
                            self?.searchResultsController?.viewState = .empty
                            if let emptyStateViewController = self?.searchResultsController?.emptyStateViewController as? SearchEmptyResultsViewController {
                                emptyStateViewController.descriptionLabel.text = "No search results found"
                                emptyStateViewController.searchAgainButton.setTitle("Search Again".uppercased(), for: .normal)
                            }
                            return
                        }
                        
                        // If we have results pass, set the state as loaded
                        self?.searchResultsController?.viewState = .loaded(searchResults)
                    }
                    
                    // GA event - Searched term
                    GATracker.trackEventWith(category: "Search", action: term, label: nil, value: nil)
                })
            }
        })
    }
}


// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
        // Check there is text and not just white space
        guard !searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.performSearch), object: nil)
            return
        }
        
        self.searchTerm = searchText
        
        // Cancel the previous request if already performing a search
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.performSearch), object: nil)
        searchResultsController?.viewState = .loading
        
        // perform search
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
