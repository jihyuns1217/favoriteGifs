//
//  GifTests.swift
//  FavoriteGifsTests
//
//  Created by Jihyun Son on 2020/03/29.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import XCTest
import CoreData
@testable import FavoriteGifs

class GifTests: XCTestCase {
    let dataTaskManager = StubDataTaskManager()

    override func setUp() {
        DataController.shared.removeAll()
        
        DataTaskManager.shared = dataTaskManager
    }

    func testGifs_doNotInsertToContext() throws {
        // Given
        dataTaskManager.data = """
        {
            "data": [
                {
                    "type": "gif",
                    "id": "TtZ4UQH7yedlC",
                    "url": "https://giphy.com/gifs/mad-men-january-jones-betty-draper-TtZ4UQH7yedlC",
                    "slug": "mad-men-january-jones-betty-draper-TtZ4UQH7yedlC",
                    "bitly_gif_url": "https://gph.is/1jjHFDO",
                    "bitly_url": "https://gph.is/1jjHFDO",
                    "embed_url": "https://giphy.com/embed/TtZ4UQH7yedlC",
                    "username": "",
                    "source": "https://fyeahmm.tumblr.com/post/85506827757",
                    "title": "january jones g GIF",
                    "rating": "pg",
                    "content_url": "",
                    "source_tld": "fyeahmm.tumblr.com",
                    "source_post_url": "https://fyeahmm.tumblr.com/post/85506827757",
                    "is_sticker": 0,
                    "import_datetime": "2014-05-12 06:56:15",
                    "trending_datetime": "0000-00-00 00:00:00",
                    "images": {
                        "fixed_width_downsampled": {
                            "height": "92",
                            "size": "41985",
                            "url": "https://media1.giphy.com/media/TtZ4UQH7yedlC/200w_d.gif?cid=cde4eab81072172ddf261bd763ffd165642cac492a851e67&rid=200w_d.gif",
                            "webp": "https://media1.giphy.com/media/TtZ4UQH7yedlC/200w_d.webp?cid=cde4eab81072172ddf261bd763ffd165642cac492a851e67&rid=200w_d.webp",
                            "webp_size": "34106",
                            "width": "200"
                        }
                    },
                    "analytics_response_payload": "e=Z2lmX2lkPVR0WjRVUUg3eWVkbEMmZXZlbnRfdHlwZT1HSUZfU0VBUkNIJmNpZD1jZGU0ZWFiODEwNzIxNzJkZGYyNjFiZDc2M2ZmZDE2NTY0MmNhYzQ5MmE4NTFlNjc",
                    "analytics": {
                        "onload": {
                            "url": "https://giphy-analytics.giphy.com/simple_analytics?response_id=1072172ddf261bd763ffd165642cac492a851e67&event_type=GIF_SEARCH&gif_id=TtZ4UQH7yedlC&action_type=SEEN"
                        },
                        "onclick": {
                            "url": "https://giphy-analytics.giphy.com/simple_analytics?response_id=1072172ddf261bd763ffd165642cac492a851e67&event_type=GIF_SEARCH&gif_id=TtZ4UQH7yedlC&action_type=CLICK"
                        },
                        "onsent": {
                            "url": "https://giphy-analytics.giphy.com/simple_analytics?response_id=1072172ddf261bd763ffd165642cac492a851e67&event_type=GIF_SEARCH&gif_id=TtZ4UQH7yedlC&action_type=SENT"
                        }
                    }
                }
            ],
            "pagination": {
                "total_count": 39741,
                "count": 25,
                "offset": 0
            },
            "meta": {
                "status": 200,
                "msg": "OK",
                "response_id": "1072172ddf261bd763ffd165642cac492a851e67"
            }
        }
        """.data(using: .utf8)
        
        // When
        Gif.gifs(query: "", offset: 0) { (result) in
        }
        
        // Then
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Gif.self))
        let count = try DataController.shared.persistentContainer.viewContext.count(for: fetchRequest)
        XCTAssertEqual(count, 0)
    }

}
