//
//  UIImageView+Extensions.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/28.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func setGif(url: URL) {
        DataTaskManager.shared.resumeDataTask(url: url) { (result) in
            switch result {
            case .success(let data):
                guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.image = UIImage.animatedImageWithSource(source)
                }
            case .failure(_):
                return
            }
        }
    }
}
