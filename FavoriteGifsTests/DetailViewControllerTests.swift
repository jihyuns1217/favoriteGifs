//
//  DetailViewControllerTests.swift
//  FavoriteGifsTests
//
//  Created by Jihyun Son on 2020/03/29.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import XCTest
import CoreData
@testable import FavoriteGifs

class DetailViewControllerTests: XCTestCase {
    override func setUp() {
        DataController.shared.removeAll()
    }
    
    override func tearDown() {
        DataController.shared.removeAll()
    }
    
    func testToggleIsFavorite_favoriteIsFalse_addToFavoriteGif() {
        // Given
        let gif = Gif(entity: NSEntityDescription.entity(forEntityName: String(describing: Gif.self), in: DataController.shared.persistentContainer.viewContext)!, insertInto: nil)
        gif.aspectRatio = 1
        gif.id = "26ybwyb5dKBiKsZJC"
        gif.url = URL(string: "https://media0.giphy.com/media/26ybwyb5dKBiKsZJC/200_s.gif?cid=cde4eab81072172ddf261bd763ffd165642cac492a851e67&rid=200_s.gif")!
        
        let detailViewController = DetailViewController()
        detailViewController.gif = gif
        _ = UINavigationController(rootViewController: detailViewController)
        detailViewController.loadViewIfNeeded()
        
        // When
        let button = detailViewController.navigationItem.rightBarButtonItem!
        _ = button.target?.perform(button.action)
        
        // Then
        let savedGif = try? DataController.shared.persistentContainer.viewContext.existingObject(with: gif.objectID)
        XCTAssertNotNil(savedGif)
    }
    
    func testToggleIsFavorite_favoriteIsTrue_removeFromFavoriteGif() {
        // Given
        let gif = NSEntityDescription.insertNewObject(forEntityName: String(describing: Gif.self), into: DataController.shared.persistentContainer.viewContext) as! Gif
        gif.aspectRatio = 1
        gif.id = "26ybwyb5dKBiKsZJC"
        gif.url = URL(string: "https://media0.giphy.com/media/26ybwyb5dKBiKsZJC/200_s.gif?cid=cde4eab81072172ddf261bd763ffd165642cac492a851e67&rid=200_s.gif")!
        
        let detailViewController = DetailViewController()
        detailViewController.gif = gif
        _ = UINavigationController(rootViewController: detailViewController)
        detailViewController.loadViewIfNeeded()
        
        // When
        let button = detailViewController.navigationItem.rightBarButtonItem!
        _ = button.target?.perform(button.action)
        
        // Then
        let savedGif = try? DataController.shared.persistentContainer.viewContext.existingObject(with: gif.objectID)
        XCTAssertNil(savedGif)
    }
    
}
