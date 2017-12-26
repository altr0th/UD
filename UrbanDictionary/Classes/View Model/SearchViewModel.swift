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

protocol SearchViewModelDelegate {
    func viewModelDidUpdateSearchResults(_ viewModel: SearchViewModel)
}

class SearchViewModel: NSObject {
    
    // Private
    private var currentSearchRequest: DataRequest?
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    private var delegate: SearchViewModelDelegate
    
    // Dependencies
    let coreDataCoordinator: () -> CoreDataCoordinator
    let apiProvider: () -> APIProvider
    
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
        
        if query.count > 0 {
            currentSearchRequest = apiProvider().requestSearchResults(using: query, { [weak self] (response, error) in
                guard let moc = self?.coreDataCoordinator().writeContext else { return }
                if let response = response as? [ AnyHashable : Any ],
                   let results = response["list"] as? [[ AnyHashable : Any ]] {
                    for result in results {
                        SearchResult.create(from: result, query: query, in: moc)
                    }
                }
            })
        } else {
            delegate.viewModelDidUpdateSearchResults(self)
        }
    }
    
    private func setupFetchedResultsController(for query: String) {
        fetchedResultsController?.delegate = nil
        fetchedResultsController = NSFetchedResultsController(fetchRequest: SearchResult.fetchRequest(for: query, sortedBy: .thumbsUp),
                                                              managedObjectContext: coreDataCoordinator().readContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil) as? NSFetchedResultsController<NSFetchRequestResult>
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
        delegate.viewModelDidUpdateSearchResults(self)
    }
    
    func resultCount() -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func result(at indexPath: IndexPath) -> SearchResultViewModel? {
        if let searchResult = fetchedResultsController?.object(at: indexPath) as? SearchResult {
            let resultModel = SearchResultViewModel()
            resultModel.title = "[\(searchResult.word ?? "")] : \(searchResult.definition ?? "")"
            return resultModel
        }
        return nil
    }
}

extension SearchViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate.viewModelDidUpdateSearchResults(self)
    }
}
