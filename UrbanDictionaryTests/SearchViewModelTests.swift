//
//  UrbanDictionaryTests.swift
//  UrbanDictionaryTests
//
//  Created by Andy Roth on 12/24/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//

import XCTest
import Alamofire
import CoreData
@testable import UrbanDictionary

class MockAPIProvider: APIProvider {
    override func requestSearchResults(using query: String, _ completion: @escaping APIProviderCompletion) -> DataRequest? {
        completion(nil, nil)
        return nil
    }
}

class MockCoreDataCoordinator: CoreDataCoordinator {
    var fetchedResultsControllerQuery: String?
    override func createFetchedResultsController(for query: String, sortType: SearchResultSortType) -> NSFetchedResultsController<NSFetchRequestResult>? {
        fetchedResultsControllerQuery = query
        return nil
    }
    
    override lazy var writeContext: NSManagedObjectContext = {
        return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    }()
}

class SearchViewModelTests: XCTestCase {
    var apiProvider: MockAPIProvider!
    var coreDataCoordinator: MockCoreDataCoordinator!
    var userDefaults: UserDefaults!
    var viewModel: SearchViewModel!
    
    override func setUp() {
        apiProvider = MockAPIProvider()
        coreDataCoordinator = MockCoreDataCoordinator()
        userDefaults = UserDefaults()
        viewModel = SearchViewModel(coreDataCoordinator: { self.coreDataCoordinator }, apiProvider: { self.apiProvider }, userDefaults: { self.userDefaults })
    }
    
    func testSearchCreatedFRCWithQuery() {
        let query = "Test String"
        viewModel.search(for: query)
        XCTAssert(coreDataCoordinator.fetchedResultsControllerQuery == query)
    }
    
    func testChangingSortUpdatesUserDefaults() {
        viewModel.sort(by: .thumbsDown)
        XCTAssert(userDefaults.currentSortType == SearchResultSortType.thumbsDown.rawValue)
        
        viewModel.sort(by: .thumbsUp)
        XCTAssert(userDefaults.currentSortType == SearchResultSortType.thumbsUp.rawValue)
    }
}
