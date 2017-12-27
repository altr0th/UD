//
//  SearchResult+Insert.swift
//  UrbanDictionary
//
//  Created by Andy Roth on 12/26/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//

import Foundation
import CoreData

extension SearchResult {
    enum Keys: String {
        case xid = "defid"
        case definition
        case link = "permalink"
        case thumbsUpCount = "thumbs_up"
        case thumbsDownCount = "thumbs_down"
        case word
        case author
        case example
    }
    
    class func create(from json: [AnyHashable: Any], query: String, in context: NSManagedObjectContext) {
        guard let xid = json[Keys.xid.rawValue] as? Int32 else { return }
        
        fetch(with: xid, in: context) { (result) in
            context.perform({
                guard let entityDescription = NSEntityDescription.entity(forEntityName: "SearchResult", in: context) else { return }
                let searchResult = result ?? SearchResult(entity: entityDescription, insertInto: context)
                searchResult.update(using: json)
                searchResult.fromQuery = query
                try? context.save()
            })
        }
    }
    
    private func update(using json: [AnyHashable: Any]) {
        guard let id = json[Keys.xid.rawValue] as? Int32 else { return }
        
        xid = id
        definition = json[Keys.definition.rawValue] as? String
        link = URL(string: json[Keys.link.rawValue] as? String ?? "")
        thumbsUpCount = json[Keys.thumbsUpCount.rawValue] as? Int32 ?? 0
        thumbsDownCount = json[Keys.thumbsDownCount.rawValue] as? Int32 ?? 0
        word = json[Keys.word.rawValue] as? String
        author = json[Keys.author.rawValue] as? String
        example = json[Keys.example.rawValue] as? String
    }
}
