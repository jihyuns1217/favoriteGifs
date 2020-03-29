//
//  URLDataTaskManager.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/29.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import Foundation

struct URLDataTaskManager {
    static var shared: URLDataTaskManager = URLDataTaskManager()
    
    func resumeDataTask(request: URLRequest, completion: @escaping ((Result<Data, Error>) -> Void)) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode,
                error == nil else {
                    completion(.failure(error ?? NetworkError.extra))
                    return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
}
