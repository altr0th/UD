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

class SearchViewModel: NSObject {
    
    // MARK: Closures
    
    var searchResultsDidChange: (() -> Void)?
    var networkActivityDidChange: ((Bool) -> Void)?
    
    // MARK: Private Properties
    
    private(set) var currentSearchRequest: DataRequest?
    private(set) var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    private var isNetworkActive: Bool = false {
        didSet {
            networkActivityDidChange?(isNetworkActive)
        }
    }
    private var currentSearchQuery: String {
        didSet {
            userDefaults().currentSearchQuery = currentSearchQuery
        }
    }
    public private(set) var currentSortType: SearchResultSortType {
        didSet {
            userDefaults().currentSortType = currentSortType.rawValue
        }
    }
    
    // MARK: Dependencies
    
    let coreDataCoordinator: () -> CoreDataCoordinator
    let apiProvider: () -> APIProvider
    let userDefaults: () -> UserDefaults
    
    init(coreDataCoordinator: @escaping () -> CoreDataCoordinator,
         apiProvider: @escaping () -> APIProvider,
         userDefaults: @escaping () -> UserDefaults = { UserDefaults.standard }) {
        self.coreDataCoordinator = coreDataCoordinator
        self.apiProvider = apiProvider
        self.userDefaults = userDefaults
        currentSearchQuery = UserDefaults.standard.currentSearchQuery
        currentSortType = SearchResultSortType(rawValue: UserDefaults.standard.currentSortType) ?? SearchResultSortType.thumbsUp
        super.init()
        
        setupFetchedResultsController(for: currentSearchQuery)
    }
}

// MARK: - Public Search Methods

extension SearchViewModel {
    func search(for query: String) {
        currentSearchQuery = query
        setupFetchedResultsController(for: query)
        currentSearchRequest?.cancel()
        
        if query.count > 0 {
            isNetworkActive = true
            currentSearchRequest = apiProvider().requestSearchResults(using: query, { [weak self] (response, error) in
                self?.isNetworkActive = false
                guard let moc = self?.coreDataCoordinator().writeContext else { return }
                if let response = response as? [ AnyHashable : Any ],
                    let results = response["list"] as? [[ AnyHashable : Any ]] {
                    for result in results {
                        SearchResult.create(from: result, query: query, in: moc)
                    }
                }
            })
        } else {
            isNetworkActive = false
        }
    }
    
    func sort(by sortType: SearchResultSortType) {
        currentSortType = sortType
        setupFetchedResultsController(for: currentSearchQuery)
    }
    
    func resultCount() -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func result(at indexPath: IndexPath) -> SearchResultViewModel? {
        if let searchResult = fetchedResultsController?.object(at: indexPath) as? SearchResult {
            let resultModel = SearchResultViewModel(searchResult: searchResult)
            return resultModel
        }
        return nil
    }
}

// MARK: - Fetched Results Controller Setup

extension SearchViewModel {
    private func setupFetchedResultsController(for query: String) {
        fetchedResultsController?.delegate = nil
        fetchedResultsController = coreDataCoordinator().createFetchedResultsController(for: query, sortType: currentSortType)
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
        searchResultsDidChange?()
    }
}

// MARK: - Fetched Results Controller Delegate

extension SearchViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        searchResultsDidChange?()
    }
}
