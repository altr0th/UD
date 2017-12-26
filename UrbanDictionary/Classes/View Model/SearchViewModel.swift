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

protocol SearchViewModelDelegate: NSFetchedResultsControllerDelegate {
    
}

class SearchViewModel: NSObject {
    
    // Private
    private var currentSearchRequest: DataRequest?
    private var fetchedResultsController: NSFetchedResultsController<SearchResult>?
    
    // Dependencies
    let coreDataCoordinator: () -> CoreDataCoordinator
    let apiProvider: () -> APIProvider
    let delegate: SearchViewModelDelegate
    
    init(delegate: SearchViewModelDelegate,
         coreDataCoordinator: @escaping () -> CoreDataCoordinator,
         apiProvider: @escaping () -> APIProvider) {
        self.delegate = delegate
        self.coreDataCoordinator = coreDataCoordinator
        self.apiProvider = apiProvider
    }
    
    func search(for query: String) {
        setupFetchedResultsController(for: query)
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
    
    private func setupFetchedResultsController(for query: String) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: SearchResult.fetchRequest(for: query, sortedBy: .thumbsUp),
                                                              managedObjectContext: coreDataCoordinator().readContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
    }
}

extension SearchViewModel: NSFetchedResultsControllerDelegate {
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        delegate.controller?(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate.controllerWillChangeContent?(controller)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate.controllerDidChangeContent?(controller)
    }
}
