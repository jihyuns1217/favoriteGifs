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
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return
            }
            
            DispatchQueue.main.async {
                guard let source = CGImageSourceCreateWithData(data! as CFData, nil) else {
                    print("image doesn't exist")
                    return
                }
                self.image = UIImage.animatedImageWithSource(source)
            }
        }.resume()
    }
}
