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
    private let searchContainerView: UIView = UIView(frame: .zero)
    private var collectionView = GifsCollectionView(frame: .zero, collectionViewLayout: DynamicHeightCollectionViewLayout())
    
    private let topIndicatorView = UIActivityIndicatorView(style: .medium)
    private let activityIndicatorBackgroundView = UIView(frame: .zero)
    private let footerIndicatorView = UIActivityIndicatorView(style: .medium)
    
    private let noGifsLabel = UILabel(frame: .zero)
    
    private var gifs = [Gif]()
    private var pagination: Pagination?
    
    private var isLoading = false
    private var isPaging = false
    
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
        
        view.backgroundColor = .systemBackground
        
        setupCollectionView()
        setupSearchController()
        setUpActivityIndicator()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let pagination = pagination else {
            return
        }
        
        if scrollView.contentOffset.y + scrollView.bounds.height + 100 >= scrollView.contentSize.height {
            if pagination.offset + pagination.count < pagination.totalCount {
                guard let searchText = searchController.searchBar.text, searchText.count > 0 else {
                    return
                }
                
                isPaging = true
                getGifs(searchText: searchText)
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupCollectionView() {
        if let collectionViewLayout = collectionView.collectionViewLayout as? DynamicHeightCollectionViewLayout {
            collectionViewLayout.delegate = self
        }
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor)
        ])
        
        noGifsLabel.text = NSLocalizedString("No Gifs", comment: "")
        noGifsLabel.textAlignment = .center
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Gifs"
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setUpActivityIndicator() {
        activityIndicatorBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorBackgroundView.isUserInteractionEnabled = false
        view.addSubview(activityIndicatorBackgroundView)
        
        NSLayoutConstraint.activate([
            activityIndicatorBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            activityIndicatorBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            activityIndicatorBackgroundView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicatorBackgroundView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        
        activityIndicatorBackgroundView.addSubview(topIndicatorView)
        topIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topIndicatorView.topAnchor.constraint(equalTo: activityIndicatorBackgroundView.topAnchor, constant: 20),
            topIndicatorView.centerXAnchor.constraint(equalTo: activityIndicatorBackgroundView.centerXAnchor)
        ])
        
    }
    
    private func getGifs(searchText: String) {
        guard !isLoading else {
            return
        }
        isLoading = true
        DispatchQueue.main.async {
            if !self.isPaging {
                self.activityIndicatorBackgroundView.backgroundColor = self.view.backgroundColor
                self.topIndicatorView.startAnimating()
            } else {
                self.footerIndicatorView.startAnimating()
            }
        }
        
        Gif.gifs(query: searchText, offset: isPaging ? gifs.count : 0) { [weak self] (result) in
            guard let self = self else {
                return
            }
            
            defer {
                DispatchQueue.main.async {
                    if !self.isPaging {
                        self.collectionView.setContentOffset(.zero, animated: false)
                        
                        self.activityIndicatorBackgroundView.backgroundColor = .clear
                        self.topIndicatorView.stopAnimating()
                    } else {
                        self.footerIndicatorView.stopAnimating()
                    }
                    
                    self.isLoading = false
                }
            }
            
            switch result {
            case .success(let (gifs, pagination)):
                self.pagination = pagination
                if self.isPaging {
                    let from = self.gifs.count
                    let to = self.gifs.count + gifs.count
                    let nextIndexPaths: [IndexPath] = (from ..< to).map { IndexPath(row: $0, section: 0) }
                    self.gifs += gifs
                    DispatchQueue.main.async {
                        self.collectionView.insertItems(at: nextIndexPaths)
                    }
                    
                } else {
                    self.gifs = gifs
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
                
            case .failure(let error):
                let alertController = UIAlertController(title: NSLocalizedString("네트워크 오류", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: NSLocalizedString("확인", comment: ""), style: .default, handler : nil)
                alertController.addAction(defaultAction)
                
                DispatchQueue.main.async {
                    self.present(alertController, animated: true)
                }
            }
        }
    }
    
    
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, searchText.count > 0 else {
            return
        }
        
        searchCoalesceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [unowned self] _ in
            self.pagination = nil
            self.isPaging = false
            self.getGifs(searchText: searchText)
        })
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        gifs.removeAll()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionView
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as GifCollectionViewCell
        
        let token = ImageLoader.shared.loadImage(gifs[indexPath.item].url) { result in
            if let image = try? result.get() {
                DispatchQueue.main.async {
                    cell.imageView.image = image
                }
            }
        }
        
        cell.onReuse = {
            if let token = token {
                ImageLoader.shared.cancelLoad(token)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController = DetailViewController()
        detailViewController.gif = gifs[indexPath.item]
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionViewFooterView.reuseIdentifier, for: indexPath)
            
            if gifs.isEmpty {
                footer.addSubview(noGifsLabel)
                noGifsLabel.layoutAttachAll(to: footer)
                
                if let searchText = searchController.searchBar.text
                    , !searchText.isEmpty {
                    noGifsLabel.isHidden = false
                } else {
                    noGifsLabel.isHidden = true
                }
            } else {
                noGifsLabel.isHidden = true
                footer.addSubview(footerIndicatorView)
                footerIndicatorView.layoutAttachAll(to: footer)
            }
            
            return footer
        }
        return UICollectionReusableView()
    }
}

// MARK: - DynamicHeightCollectionViewLayout
extension SearchViewController: DynamicHeightCollectionViewLayoutDelegate {
    func collectionViewHeightForFooter(_ collectionView: UICollectionView) -> CGFloat {
        return 50
    }
    
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let height = width * CGFloat(gifs[indexPath.item].aspectRatio)
        return height
    }
}
