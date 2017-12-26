//
//  ViewController.swift
//  UrbanDictionary
//
//  Created by Andy Roth on 12/24/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var testModel: SearchViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testModel = SearchViewModel()
        testModel?.fetchedResultsController.delegate = self
        try? testModel?.fetchedResultsController.performFetch()
        testModel?.search(for: "wat")
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        debugPrint("did it")
    }
}
