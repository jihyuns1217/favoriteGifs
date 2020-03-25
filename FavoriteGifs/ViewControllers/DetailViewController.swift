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
    
    override func viewDidLoad() {
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
        
        URLSession.shared.dataTask(with: gif.url) { (data, response, error) in
            if error != nil {
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data!)
            }
        }.resume()
        
        
        let heartOff = "🤍"
        let heartOn = "❤️"
        
        let button = UIBarButtonItem(title: heartOff, style: .plain, target: self, action: #selector(didSelectHeart))
        navigationItem.setRightBarButton(button, animated: true)
    }
    
    @objc private func didSelectHeart() {
        let favoriteGif = NSEntityDescription.insertNewObject(forEntityName: String(describing: FavoriteGif.self), into: DataController.shared.persistentContainer.viewContext) as! FavoriteGif
        favoriteGif.id = gif.id
        favoriteGif.url = gif.url
        favoriteGif.aspectRatio = Float(gif.aspectRatio)
        DataController.shared.saveContext()
        
    }
    
}
