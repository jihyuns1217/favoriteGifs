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
    
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: DynamicHeightCollectionViewLayout())
    
    var gifs = [FavoriteGif]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        
        self.view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        
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
        
        let button = UIBarButtonItem(title: "Remove All", style: .plain, target: self, action: #selector(removeAll))
        navigationItem.setRightBarButton(button, animated: true)
        
        let refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(getData), for: .valueChanged)
    }
    
    @objc private func getData() {
        let moc = DataController.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteGif")
        do {
            gifs = try moc.fetch(fetchRequest) as! [FavoriteGif]
            collectionView.reloadData()
            collectionView.refreshControl?.endRefreshing()
        } catch {
            fatalError("Failed to fetch favorite gifs: \(error)")
        }
    }
    
    @objc private func removeAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteGif")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            let moc = DataController.shared.persistentContainer.viewContext
            try moc.execute(deleteRequest)
            try moc.save()
            
            collectionView.reloadData()
        } catch let error as NSError {
            fatalError("Failure to delete context: \(error)")
        }
    }
}

// MARK: - UICollectionView
extension FavoriteViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
        let favoriteGif = gifs[indexPath.item]
        let gif = Gif(id: favoriteGif.id, url: favoriteGif.url, aspectRatio: CGFloat(favoriteGif.aspectRatio))
        detailViewController.gif = gif
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - DynamicHeightCollectionViewLayout
extension FavoriteViewController: DynamicHeightCollectionViewLayoutDelegate {
    
     func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let height = width * CGFloat(gifs[indexPath.item].aspectRatio)
        
        return height
    }
}
