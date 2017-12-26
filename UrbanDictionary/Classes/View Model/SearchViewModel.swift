//
//  SearchViewModel.swift
//  UrbanDictionary
//
//  Created by Andy Roth on 12/26/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//

import Foundation
import CoreData
import Alamofire

class SearchViewModel {
    
    // Properties
    let fetchedResultsController: NSFetchedResultsController<SearchResult>
    
    // Private
    private var currentSearchRequest: DataRequest?
    
    // Dependencies
    let coreDataCoordinator: () -> CoreDataCoordinator
    let apiProvider: () -> APIProvider
    
    init(coreDataCoordinator: @escaping () -> CoreDataCoordinator = { return CoreDataCoordinator() },
         apiProvider: @escaping () -> APIProvider = { return APIProvider() }) {
        self.coreDataCoordinator = coreDataCoordinator
        self.apiProvider = apiProvider
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: SearchResult.fetchRequest(),
                                                                   managedObjectContext: coreDataCoordinator().readContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
    }
    
    func search(for query: String) {
        currentSearchRequest?.cancel()
        currentSearchRequest = apiProvider().requestSearchResults(using: query, { [weak self] (response, error) in
            guard let moc = self?.coreDataCoordinator().writeContext else { return }
            if let response = response as? [ AnyHashable : Any ],
               let results = response["list"] as? [[ AnyHashable : Any ]] {
                for result in results {
                    SearchResult.create(from: result, query: query, in: moc)
                }
            }
        })
    }
}
