//
//  SearchViewController.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/17.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    private let searchController = UISearchController(searchResultsController: SearchResultViewController())
    private let searchContainerView: UIView = UIView(frame: .zero)
    
    private var searchCoalesceTimer: Timer? {
        willSet {
            if searchCoalesceTimer?.isValid == true {
                searchCoalesceTimer?.invalidate()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchController.searchBar.frame = searchContainerView.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Gifs"
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    
    
    
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, searchText.count > 0 else {
            return
        }
        
        searchCoalesceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            guard let searchResultViewController = searchController.searchResultsController as? SearchResultViewController else {
                return
            }
            searchResultViewController.searchText = ""
            searchResultViewController.pagination = nil
            searchResultViewController.isPaging = false
            searchResultViewController.getGifs(searchText: searchText)
        })
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let searchResultViewController = searchController.searchResultsController as? SearchResultViewController else {
            return
        }
        searchResultViewController.searchText = ""
        searchResultViewController.gifs.removeAll()
        searchResultViewController.collectionView.reloadData()
    }
}
