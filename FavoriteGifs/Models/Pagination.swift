//
//  Pagination.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/27.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import Foundation

struct Pagination: Codable {
    let totalCount: Int
    let count: Int
    let offset: Int
}
