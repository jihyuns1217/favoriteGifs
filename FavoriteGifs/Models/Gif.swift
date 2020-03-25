//
//  Gif.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/24.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import Foundation
import UIKit

struct Gif {
    let id: String
    let url: URL
    let aspectRatio: CGFloat
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
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    , let rawGifs = jsonObject["data"] as? [[String: Any]] else {
                        completion(.failure(error ?? NetworkError.invalidData))
                        return
                }
                
                var gifs = [Gif]()
                for rawGif in rawGifs {
                    guard let id = rawGif["id"] as? String
                        , let images = rawGif["images"] as? [String: Any]
                        , let fixedWidthDownsampled = images["fixed_width_downsampled"] as? [String: Any]
                        , let urlString = fixedWidthDownsampled["url"] as? String
                        , let url = URL(string: urlString)
                        , let widthString = fixedWidthDownsampled["width"] as? String
                        , let heightString = fixedWidthDownsampled["height"] as? String
                        , let width = Int(widthString)
                        , let height = Int(heightString) else {
                            completion(.failure(error ?? NetworkError.invalidData))
                            return
                    }
                    
                    
                    let aspectRatio: CGFloat = CGFloat(height / width)
                    let gif = Gif(id: id, url: url, aspectRatio: aspectRatio)
                    gifs.append(gif)
                }
                
                
                completion(.success(gifs))
            } catch {
                completion(.failure(error))
                return
            }
        }
        task.resume()
    }
}
