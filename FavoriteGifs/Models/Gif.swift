//
//  Gif.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/24.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import Foundation

struct Gif: Codable {
    
}

extension Gif {
    static func gifs(query: String, completion: @escaping ((Result<[Gif], Error>) -> Void)) {
        var components = URLComponents(string: "https://api.giphy.com/v1/gifs/search")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: "ozncenAXiDpWKYfF0pFB6M9ajxV5K3BU")
            , URLQueryItem(name: "q", value: query)
        ]
        
        let request = URLRequest(url: components.url!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode,
                error == nil else {
                    completion(.failure(error ?? NetworkError.extra))
                    return
            }
            
            do {
                let gifs = try JSONDecoder().decode([Gif].self, from: data)
                completion(.success(gifs))
            } catch {
                completion(.failure(error))
                return
            }
        }
        task.resume()
    }
}
