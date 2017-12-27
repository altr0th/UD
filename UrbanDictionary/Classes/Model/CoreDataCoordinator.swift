//
//  CoreDataManager.swift
//  UrbanDictionary
//
//  Created by Andy Roth on 12/26/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//

import Foundation
import CoreData

class CoreDataCoordinator {
    
    // MARK: - Store Container
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UrbanDictionary")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        })
        return container
    }()
    
    lazy var writeContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        return context
    }()
    
    // MARK: - Fetched Results Controller
    
    func createFetchedResultsController(for query: String, sortType: SearchResultSortType) -> NSFetchedResultsController<NSFetchRequestResult>? {
        let controller = NSFetchedResultsController(fetchRequest: SearchResult.fetchRequest(for: query, sortedBy: sortType),
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil) as? NSFetchedResultsController<NSFetchRequestResult>
        return controller
    }
}
