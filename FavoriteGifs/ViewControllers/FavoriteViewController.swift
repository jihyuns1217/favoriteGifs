//
//  FavoriteViewController.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/17.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import UIKit
import CoreData

class FavoriteViewController: UIViewController {
    
    private var collectionView = GifsCollectionView(frame: .zero, collectionViewLayout: DynamicHeightCollectionViewLayout())
    private let pullToRefreshLabel = UILabel(frame: .zero)
    
    private var gifs = [Gif]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getGifs()
        
        view.backgroundColor = .systemBackground
        
        setupCollectionView()
        setupRemoveAllButton()
        setupRefreshControl()
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
        
        pullToRefreshLabel.text = NSLocalizedString("Pull To Refresh", comment: "")
        pullToRefreshLabel.textAlignment = .center
    }
    
    private func setupRemoveAllButton() {
        let button = UIBarButtonItem(title: NSLocalizedString("Remove All", comment: ""), style: .plain, target: self, action: #selector(removeAll))
        navigationItem.setRightBarButton(button, animated: true)
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        
        var frame = collectionView.bounds
        frame.origin.y = -frame.size.height
        let backgroundView = UIView(frame: frame)
        backgroundView.autoresizingMask = .flexibleWidth
        backgroundView.backgroundColor = view.backgroundColor
        
        collectionView.bounces = true
        refreshControl.backgroundColor = view.backgroundColor
        refreshControl.addTarget(self, action: #selector(getGifs), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        collectionView.insertSubview(backgroundView, at: 0)
    }
    
    @objc private func getGifs() {
        let moc = DataController.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Gif.self))
        do {
            gifs = try moc.fetch(fetchRequest) as! [Gif]
            collectionView.reloadData()
            collectionView.refreshControl?.endRefreshing()
        } catch {
            fatalError("Failed to fetch favorite gifs: \(error)")
        }
    }
    
    @objc private func removeAll() {
        DataController.shared.removeAll()
    }
}

// MARK: - UICollectionView
extension FavoriteViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
                footer.addSubview(pullToRefreshLabel)
                pullToRefreshLabel.layoutAttachAll(to: footer)
            }
            pullToRefreshLabel.isHidden = !gifs.isEmpty
            
            return footer
        }
        return UICollectionReusableView()
    }
}

// MARK: - DynamicHeightCollectionViewLayout
extension FavoriteViewController: DynamicHeightCollectionViewLayoutDelegate {
    func collectionViewHeightForFooter(_ collectionView: UICollectionView) -> CGFloat {
        return 50
    }
    
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let height = width * CGFloat(gifs[indexPath.item].aspectRatio)
        
        return height
    }
}
