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
    
    override func prepareForReuse() {
        imageView.image = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    private func setupView() {
        imageView = UIImageView(frame: .zero)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: imageView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
        ])
    }

}
