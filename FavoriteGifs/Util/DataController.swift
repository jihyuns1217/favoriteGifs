//
//  DataController.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/26.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import Foundation

import Foundation
import CoreData

class DataController: NSObject {
    static var shared: DataController = DataController.init {
    }
    
    var persistentContainer: NSPersistentContainer
    
    private init(completionClosure: @escaping () -> ()) {
        persistentContainer = NSPersistentContainer(name: "FavoriteGifs")
        persistentContainer.loadPersistentStores(completionHandler: {(description, error) in
            if let error = error {
                fatalError("Failed to load Core Data Stack: \(error)")
            }
            completionClosure()
        })
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = DataController.shared.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
