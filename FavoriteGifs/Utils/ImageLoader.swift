//
//  ImageLoader.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/31.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import Foundation
import UIKit

class ImageLoader {
    static let shared: ImageLoader = ImageLoader()
    
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionDataTask]()
    
    func clearImages() {
        loadedImages.removeAll()
    }
    
    func loadImage(_ url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        
        if let image = loadedImages[url] {
            completion(.success(image))
            return nil
        }
        
        let uuid = UUID()
        
        let task = DataTaskManager.shared.resumeDataTask(url: url) { [weak self] (result) in
            switch result {
            case .success(let data):
                if let source = CGImageSourceCreateWithData(data as CFData, nil), let image = UIImage.animatedImageWithSource(source) {
                    self?.loadedImages[url] = image
                    completion(.success(image))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        runningRequests[uuid] = task
        return uuid
    }
    
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}
