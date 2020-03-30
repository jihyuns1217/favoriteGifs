//
//  StubDataTaskManager.swift
//  FavoriteGifsTests
//
//  Created by Jihyun Son on 2020/03/29.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import Foundation
@testable import FavoriteGifs

class StubDataTaskManager: DataTaskManager {
    var data: Data!
    
    override func resumeDataTask(request: URLRequest) {
        delegate?.dataTaskCompleted(result: .success(data))
    }
}
