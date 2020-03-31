//
//  URLDataTaskManager.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/29.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import Foundation

class DataTaskManager: NSObject {
    static var shared: DataTaskManager = DataTaskManager()
    
    @discardableResult
    func resumeDataTask(request: URLRequest, completion: @escaping ((Result<Data, Error>) -> Void)) -> URLSessionDataTask? {
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
        return task
    }
    
    @discardableResult
    func resumeDataTask(url: URL, completion: @escaping ((Result<Data, Error>) -> Void))  -> URLSessionDataTask? {
        let request = URLRequest(url: url)
        return resumeDataTask(request: request, completion: completion)
    }
}
