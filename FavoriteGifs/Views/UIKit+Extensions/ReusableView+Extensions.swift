//
//  ReusableView+Extensions.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/30.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import Foundation
import UIKit

protocol ReusableView {}

extension UICollectionReusableView: ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        if let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T {
            return cell
        } else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
    }
}
