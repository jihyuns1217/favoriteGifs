//
//  SearchViewController.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/17.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let searchContainerView: UIView = UIView(frame: CGRect.zero)
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: DynamicHeightCollectionViewLayout())
    
    var gifs = [Gif]()
    
    private var searchCoalesceTimer: Timer? {
        willSet {
            if searchCoalesceTimer?.isValid == true
            {
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
        
        self.view.backgroundColor = .systemBackground
        
        // 1. collectionView 붙이기
        if let collectionViewLayout = collectionView.collectionViewLayout as? DynamicHeightCollectionViewLayout {
            collectionViewLayout.delegate = self
        }
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(GifCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: GifCollectionViewCell.self))
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
        ])
        
        // 2. searchBar 붙이기
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Gifs"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, searchText.count > 0 else {
            return
        }
        
        searchCoalesceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [unowned self] _ in
            Gif.gifs(query: searchText) { (result) in
                switch result {
                case .success(let gifs):
                    self.gifs = gifs
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                case .failure(let error):
                    let alertController = UIAlertController(title: NSLocalizedString("네트워크 오류", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                    self.present(alertController, animated: true)
                }
            }
        })
    }
}

// MARK: - UICollectionView
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GifCollectionViewCell.self), for: indexPath) as! GifCollectionViewCell
        
        URLSession.shared.dataTask(with: gifs[indexPath.item].url) { (data, response, error) in
            if error != nil {
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return
            }
            
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: data!)
            }
        }.resume()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController = DetailViewController()
        detailViewController.gif = gifs[indexPath.item]
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - DynamicHeightCollectionViewLayout
extension SearchViewController: DynamicHeightCollectionViewLayoutDelegate {
    
     func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let height = width * gifs[indexPath.item].aspectRatio
        
        return height
    }
}

