//
//  NoGifsCollectionReusableView.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/04/08.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import UIKit

class NoGifsCollectionReusableView: UICollectionReusableView {
    let titleLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.text = NSLocalizedString("No Gifs", comment: "")
        titleLabel.textAlignment = .center
        
        addSubview(titleLabel)
        titleLabel.layoutAttachAll(to: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
