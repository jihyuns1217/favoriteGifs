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
    private let topProgressView = UIProgressView(progressViewStyle: .bar)
    private let bottomProgressView = UIProgressView(progressViewStyle: .bar)
    
    private var gifs = [Gif]()
    private var pagination: Pagination?
    
    private var isLoading = false
    private var isPaging = false
    
    private var dataTaskManager = DataTaskManager.shared
    
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
        
        self.view.backgroundColor = .systemBackground
        
        setupCollectionView()
        setupSearchController()
        setupProgressBar()
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
        collectionView.backgroundColor = .systemBackground
        
        if let collectionViewLayout = collectionView.collectionViewLayout as? DynamicHeightCollectionViewLayout {
            collectionViewLayout.delegate = self
        }
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(GifCollectionViewCell.self, forCellWithReuseIdentifier: GifCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Gifs"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupProgressBar() {
        view.addSubview(topProgressView)
        topProgressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topProgressView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: topProgressView.leadingAnchor),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: topProgressView.trailingAnchor)
        ])
        
        view.addSubview(bottomProgressView)
        bottomProgressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomProgressView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: bottomProgressView.leadingAnchor),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: bottomProgressView.trailingAnchor)
        ])
        DataTaskManager.shared.progressBarDelegate = self
    }
}

extension SearchViewController: UISearchResultsUpdating {
    private func getGifs(searchText: String) {
        guard !isLoading else {
            return
        }
        isLoading = true
                
        GifService.shared.gifs(dataTaskManager: dataTaskManager, query: searchText, offset: self.gifs.count) { [weak self] (result) in
            guard let self = self else {
                return
            }
            
            defer {
                self.isLoading = false
                
                DispatchQueue.main.async {
                    if self.isPaging {
                        self.bottomProgressView.progress = 0
                    } else {
                        self.topProgressView.progress = 0
                    }
                }
            }
            
            switch result {
            case .success(let (gifs, pagination)):
                self.pagination = pagination
                if self.isPaging {
                    self.gifs.append(contentsOf: gifs)
                } else {
                    self.gifs = gifs
                    
                    DispatchQueue.main.async {
                        self.collectionView.setContentOffset(.zero, animated: false)
                    }
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
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

// MARK: - UICollectionView
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as GifCollectionViewCell
        cell.imageView.setGif(url: gifs[indexPath.item].url)
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
        let height = width * CGFloat(gifs[indexPath.item].aspectRatio)
        return height
    }
}

// MARK: - ProgressBarDelegate
extension SearchViewController: ProgressBarDelegate {
    func progressRateChanged(progressRate: Float) {
        if isPaging {
            bottomProgressView.progress = progressRate
        } else {
            topProgressView.progress = progressRate
        }
    }
}

