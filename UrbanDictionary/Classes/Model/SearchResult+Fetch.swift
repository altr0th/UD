//
//  SearchResult+Fetch.swift
//  UrbanDictionary
//
//  Created by Andy Roth on 12/26/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//

import Foundation
import CoreData

extension SearchResult {
    
    enum SearchResultSortType: String {
        case thumbsUp = "thumbsUpCount"
        case thumbsDown = "thumbsDownCount"
    }
    
    class func fetchRequest(sortedBy sortType: SearchResultSortType = .thumbsUp) -> NSFetchRequest<SearchResult> {
        let request = NSFetchRequest<SearchResult>(entityName: "SearchResult")
        request.sortDescriptors = [ NSSortDescriptor(key: sortType.rawValue, ascending: false) ]
        return request
    }
    
    class func fetch(with xid: Int32, in context: NSManagedObjectContext, _ completion: @escaping (SearchResult?)->Void) {
        let request = NSFetchRequest<SearchResult>(entityName: "SearchResult")
        request.predicate = NSPredicate(format: "xid == %d", argumentArray: [ xid ])
        context.perform {
            var result: SearchResult?
            let fetchedResults = try? context.fetch(request)
            if let fetchedResults = fetchedResults, fetchedResults.count > 0 {
                result = fetchedResults.first
            }
            completion(result)
        }
    }
}
