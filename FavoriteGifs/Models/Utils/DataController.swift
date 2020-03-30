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
    
    var persistentContainer: NSPersistentCloudKitContainer
    
    private init(completionClosure: @escaping () -> ()) {
        persistentContainer = NSPersistentCloudKitContainer(name: "FavoriteGifs")
        persistentContainer.loadPersistentStores(completionHandler: {(description, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            completionClosure()
        })
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
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
    
    func removeAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Gif.self))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            let moc = DataController.shared.persistentContainer.viewContext
            try moc.execute(deleteRequest)
            try moc.save()
        } catch let error as NSError {
            fatalError("Failure to delete context: \(error)")
        }
    }
}
