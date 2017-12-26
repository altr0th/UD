//
//  SearchResult+CoreDataProperties.swift
//  UrbanDictionary
//
//  Created by Andy Roth on 12/26/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//
//

import Foundation
import CoreData

extension SearchResult {
    
    @NSManaged public var xid: Int32
    @NSManaged public var definition: String?
    @NSManaged public var link: URL?
    @NSManaged public var thumbsUpCount: Int32
    @NSManaged public var thumbsDownCount: Int32
    @NSManaged public var author: String?
    @NSManaged public var example: String?
    @NSManaged public var word: String?
    @NSManaged public var fromQuery: String?
}
