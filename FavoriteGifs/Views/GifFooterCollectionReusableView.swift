//
//  GifFooterCollectionReusableView.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/04/08.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import UIKit

class GifFooterCollectionReusableView: UICollectionReusableView {
    let footerIndicatorView = UIActivityIndicatorView(style: .medium)
    let titleLabel = UILabel(frame: .zero)
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        hideViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.text = NSLocalizedString("No Gifs", comment: "")
        titleLabel.textAlignment = .center
        
        addSubview(titleLabel)
        titleLabel.layoutAttachAll(to: self)
        addSubview(footerIndicatorView)
        footerIndicatorView.layoutAttachAll(to: self)
        
        hideViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func hideViews() {
        titleLabel.isHidden = true
        footerIndicatorView.isHidden = true
    }
}