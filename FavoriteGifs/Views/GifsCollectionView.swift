//
//  GifsCollectionView.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/31.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import UIKit

class GifsCollectionView: UICollectionView {

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        backgroundColor = .systemBackground
        
        register(GifCollectionViewCell.self, forCellWithReuseIdentifier: GifCollectionViewCell.reuseIdentifier)
        
        
        register(GifFooterCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: GifFooterCollectionReusableView.reuseIdentifier)
        contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
