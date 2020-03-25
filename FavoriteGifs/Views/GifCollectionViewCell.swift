//
//  GifCollectionViewCell.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/24.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import UIKit

class GifCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    func setupView() {
        imageView = UIImageView(frame: .zero)
        self.contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.imageView.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor),
        ])
    }

}
