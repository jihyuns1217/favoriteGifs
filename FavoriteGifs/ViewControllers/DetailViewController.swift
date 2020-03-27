//
//  DetailViewController.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/25.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    private var imageView: UIImageView!
    
    var gif: Gif!
    
    private var fetchedGifs = [FavoriteGif]()
    private var isFavorite = false
    
    override func viewDidLoad() {
        setUpView()
        setUpData()
    }
    
    @objc private func didSelectHeart() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        if isFavorite {
            for gif in fetchedGifs {
                DataController.shared.persistentContainer.viewContext.delete(gif)
            }
            fetchedGifs.removeAll()
            
        } else {
            let favoriteGif = NSEntityDescription.insertNewObject(forEntityName: String(describing: FavoriteGif.self), into: DataController.shared.persistentContainer.viewContext) as! FavoriteGif
            favoriteGif.id = gif.id
            favoriteGif.url = gif.url
            favoriteGif.aspectRatio = Float(gif.aspectRatio)
        }
        
        DataController.shared.saveContext()
        
        isFavorite.toggle()
        navigationItem.rightBarButtonItem?.image = heartImage()
        
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func setUpView() {
        self.view.backgroundColor = .systemBackground
        
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: self.imageView.topAnchor),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor),
            self.view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor),
        ])
    }
    
    private func setUpData() {
        self.imageView.setGif(url: gif.url)
        
        
        let moc = DataController.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteGif")
        fetchRequest.predicate = NSPredicate(format: "id == %@", gif.id)
        
        isFavorite = false
        do {
            fetchedGifs = try moc.fetch(fetchRequest) as! [FavoriteGif]
            if !fetchedGifs.isEmpty {
                isFavorite = true
            }
        } catch {
            fatalError("Failed to fetch favorite gifs: \(error)")
        }
        
        let heartButton = UIBarButtonItem(image: heartImage(), style: .plain, target: self, action: #selector(didSelectHeart))
        navigationItem.setRightBarButton(heartButton, animated: true)
    }
    
    private func heartImage() -> UIImage? {
        return isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
    }
    
}
