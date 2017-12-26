//
//  ViewController.swift
//  UrbanDictionary
//
//  Created by Andy Roth on 12/24/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {
    
    var viewModel: SearchViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
    }
    
    private func setupViewModel() {
        let coreDataCoordinator = CoreDataCoordinator()
        let apiProvider = APIProvider()
        viewModel = SearchViewModel(delegate: self, coreDataCoordinator: { coreDataCoordinator }, apiProvider: { apiProvider })
    }
}

extension SearchViewController: SearchViewModelDelegate {
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}
