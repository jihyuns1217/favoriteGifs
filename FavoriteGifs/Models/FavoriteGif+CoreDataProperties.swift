//
//  Gif+CoreDataProperties.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/26.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//
//

import Foundation
import CoreData

extension Gif {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gif> {
        return NSFetchRequest<Gif>(entityName: String(describing: self))
    }

    @NSManaged public var aspectRatio: Float
    @NSManaged public var id: String
    @NSManaged public var url: URL

}

