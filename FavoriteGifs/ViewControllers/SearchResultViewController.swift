//
//  SearchResultViewController.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/04/08.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController {
    
    var collectionView = GifsCollectionView(frame: .zero, collectionViewLayout: DynamicHeightCollectionViewLayout())
    
    private let topIndicatorView = UIActivityIndicatorView(style: .medium)
    private let topIndicatorBackgroundView = UIView(frame: .zero)
    
    var gifs = [Gif]()
    var pagination: Pagination?
    
    private var isLoading = false
    var isPaging = false
    var searchText: String = ""
    
    var footerIndicatorView: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        setupCollectionView()
        setUpTopIndicator()
    }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let pagination = pagination else {
            return
        }
        
        if scrollView.contentOffset.y + scrollView.bounds.height + 100 >= scrollView.contentSize.height {
            if pagination.offset + pagination.count < pagination.totalCount {
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
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setUpTopIndicator() {
        topIndicatorBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        topIndicatorBackgroundView.isUserInteractionEnabled = false
        view.addSubview(topIndicatorBackgroundView)
        
        NSLayoutConstraint.activate([
            topIndicatorBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topIndicatorBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            topIndicatorBackgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topIndicatorBackgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        
        topIndicatorBackgroundView.addSubview(topIndicatorView)
        topIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topIndicatorView.topAnchor.constraint(equalTo: topIndicatorBackgroundView.topAnchor, constant: 20),
            topIndicatorView.centerXAnchor.constraint(equalTo: topIndicatorBackgroundView.centerXAnchor)
        ])
        
    }
    
    func getGifs(searchText: String) {
        guard !isLoading else {
            return
        }
        isLoading = true
        DispatchQueue.main.async {
            if !self.isPaging {
                self.topIndicatorBackgroundView.backgroundColor = self.view.backgroundColor
                self.topIndicatorView.startAnimating()
            } else {
                self.footerIndicatorView?.startAnimating()
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
                        
                        self.topIndicatorBackgroundView.backgroundColor = .clear
                        self.topIndicatorView.stopAnimating()
                    } else {
                        self.footerIndicatorView?.stopAnimating()
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

// MARK: - UICollectionView
extension SearchResultViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
        
        present(detailViewController, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GifFooterCollectionReusableView.reuseIdentifier, for: indexPath) as! GifFooterCollectionReusableView
            
            if gifs.isEmpty {
                if !searchText.isEmpty {
                    footerView.titleLabel.isHidden = false
                } else {
                    footerView.titleLabel.isHidden = true
                }
            } else {
                footerIndicatorView = footerView.footerIndicatorView
                footerView.titleLabel.isHidden = true
            }
            
            return footerView
        }
        return UICollectionReusableView()
    }
}

// MARK: - DynamicHeightCollectionViewLayout
extension SearchResultViewController: DynamicHeightCollectionViewLayoutDelegate {
    func collectionViewHeightForFooter(_ collectionView: UICollectionView) -> CGFloat {
        return 50
    }
    
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let height = width * CGFloat(gifs[indexPath.item].aspectRatio)
        return height
    }
}
