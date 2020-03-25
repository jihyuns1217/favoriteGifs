//
//  DetailViewController.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/25.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import UIKit

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
    }

}
