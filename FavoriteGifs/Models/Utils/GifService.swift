//
//  GifService.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/30.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GifService {
    static let shared: GifService = GifService()
    
    private var completion: ((Result<([Gif], Pagination), Error>) -> Void)!
    
    func gifs(query: String, offset: Int, completion: @escaping ((Result<([Gif], Pagination), Error>) -> Void))  {
        var components = URLComponents(string: "https://api.giphy.com/v1/gifs/search")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: "ozncenAXiDpWKYfF0pFB6M9ajxV5K3BU")
            , URLQueryItem(name: "q", value: query)
            , URLQueryItem(name: "offset", value: "\(offset)")
        ]
        
        let request = URLRequest(url: components.url!)
        DataTaskManager.shared.delegate = self
        self.completion = completion
        DataTaskManager.shared.resumeDataTask(request: request)
    }
}

extension GifService: DataTaskManagerDelegate {
    func dataTaskManager(_ dataTaskManager: DataTaskManager, didCompeleteWithResult result: Result<Data, Error>) {
        switch result {
        case .success(let data):
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    , let paginationString = jsonObject["pagination"] as? [String:Any] else {
                        completion(.failure(NetworkError.invalidData))
                        return
                }
                
                let paginationStringData = try JSONSerialization.data(withJSONObject: paginationString, options: .prettyPrinted)
                let pagination = try decoder.decode(Pagination.self, from: paginationStringData)
                
                guard let rawGifs = jsonObject["data"] as? [[String: Any]] else {
                        completion(.failure(NetworkError.invalidData))
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
                        , let heightString = fixedWidthDownsampled["height"] as? String else {
                            completion(.failure(NetworkError.invalidData))
                            return
                    }
                    
                    let width = NSString(string: widthString).floatValue
                    let height = NSString(string: heightString).floatValue
                    let aspectRatio: CGFloat = CGFloat(height / width)
                    
                    let gif = Gif(entity: NSEntityDescription.entity(forEntityName: String(describing: Gif.self), in: DataController.shared.persistentContainer.viewContext)!, insertInto: nil)
                    gif.aspectRatio = Float(aspectRatio)
                    gif.id = id
                    gif.url = url
                    
                    gifs.append(gif)
                }
                
                
                completion(.success((gifs, pagination)))
            } catch {
                completion(.failure(error))
                return
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
