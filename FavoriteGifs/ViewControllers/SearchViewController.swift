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
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let activityIndicatorBackgroundView = UIView(frame: .zero)
    private let footerView = UIActivityIndicatorView(style: .medium)
    
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
        collectionView.backgroundColor = .systemBackground
        
        if let collectionViewLayout = collectionView.collectionViewLayout as? DynamicHeightCollectionViewLayout {
            collectionViewLayout.delegate = self
            collectionViewLayout.footerSize = CGSize(width: collectionViewLayout.contentWidth, height: 50)
        }
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(GifCollectionViewCell.self, forCellWithReuseIdentifier: GifCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor)
        ])
        
        collectionView.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Gifs"
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
        
        
        activityIndicatorBackgroundView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: activityIndicatorBackgroundView.topAnchor, constant: 20),
            activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorBackgroundView.centerXAnchor)
        ])
        
    }
}

extension SearchViewController: UISearchResultsUpdating {
    private func getGifs(searchText: String) {
        guard !isLoading else {
            return
        }
        isLoading = true
        DispatchQueue.main.async {
            if !self.isPaging {
                self.activityIndicatorBackgroundView.backgroundColor = self.view.backgroundColor
                self.activityIndicator.startAnimating()
            } else {
                self.footerView.startAnimating()
            }
        }
                
        Gif.gifs(query: searchText, offset: isPaging ? gifs.count : 0) { [weak self] (result) in
            guard let self = self else {
                return
            }
            
            defer {
                self.isLoading = false
                DispatchQueue.main.async {
                    self.activityIndicatorBackgroundView.backgroundColor = .clear
                    self.activityIndicator.stopAnimating()
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

        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            footer.addSubview(footerView)
            footerView.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 50)
            return footer
        }
        return UICollectionReusableView()
    }
}

// MARK: - DynamicHeightCollectionViewLayout
extension SearchViewController: DynamicHeightCollectionViewLayoutDelegate {
     func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let height = width * CGFloat(gifs[indexPath.item].aspectRatio)
        return height
    }
}

public class CollectionViewFooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
