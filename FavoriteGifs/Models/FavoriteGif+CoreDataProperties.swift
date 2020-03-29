//
//  FavoriteGif+CoreDataProperties.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/26.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

extension FavoriteGif {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteGif> {
        return NSFetchRequest<FavoriteGif>(entityName: "FavoriteGif")
    }

    @NSManaged public var aspectRatio: Float
    @NSManaged public var id: String
    @NSManaged public var url: URL

}

extension FavoriteGif {
    static func gifs(query: String, offset: Int, completion: @escaping ((Result<([FavoriteGif], Pagination), Error>) -> Void)) {
        var components = URLComponents(string: "https://api.giphy.com/v1/gifs/search")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: "ozncenAXiDpWKYfF0pFB6M9ajxV5K3BU")
            , URLQueryItem(name: "q", value: query)
            , URLQueryItem(name: "offset", value: "\(offset)")
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
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    , let paginationString = jsonObject["pagination"] as? [String:Any]
                    , let paginationStringData = try? JSONSerialization.data(withJSONObject: paginationString, options: .prettyPrinted)
                    , let pagination = try? decoder.decode(Pagination.self, from: paginationStringData)
                    , let rawGifs = jsonObject["data"] as? [[String: Any]] else {
                        completion(.failure(error ?? NetworkError.invalidData))
                        return
                }
                
                var gifs = [FavoriteGif]()
                for rawGif in rawGifs {
                    guard let id = rawGif["id"] as? String
                        , let images = rawGif["images"] as? [String: Any]
                        , let fixedWidthDownsampled = images["fixed_width_downsampled"] as? [String: Any]
                        , let urlString = fixedWidthDownsampled["url"] as? String
                        , let url = URL(string: urlString)
                        , let widthString = fixedWidthDownsampled["width"] as? String
                        , let heightString = fixedWidthDownsampled["height"] as? String else {
                            completion(.failure(error ?? NetworkError.invalidData))
                            return
                    }
                    
                    let width = NSString(string: widthString).floatValue
                    let height = NSString(string: heightString).floatValue
                    let aspectRatio: CGFloat = CGFloat(height / width)
                    
                    let gif = NSEntityDescription.insertNewObject(forEntityName: "FavoriteGif", into: DataController.shared.persistentContainer.viewContext) as! FavoriteGif
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
        }
        task.resume()
    }
}
