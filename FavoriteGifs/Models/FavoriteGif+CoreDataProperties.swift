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


extension FavoriteGif {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteGif> {
        return NSFetchRequest<FavoriteGif>(entityName: "FavoriteGif")
    }

    @NSManaged public var aspectRatio: Float
    @NSManaged public var id: String
    @NSManaged public var url: URL

}
