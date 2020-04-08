//
//  IndicatorCollectionReusableView.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/04/08.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import UIKit

class IndicatorCollectionReusableView: UICollectionReusableView {
    let footerIndicatorView = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(footerIndicatorView)
        footerIndicatorView.layoutAttachAll(to: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
