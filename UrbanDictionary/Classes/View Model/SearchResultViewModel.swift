//
//  SearchResultViewModel.swift
//  UrbanDictionary
//
//  Created by Andy Roth on 12/26/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//

import Foundation

class SearchResultViewModel {
    let title: String?
    let body: String?
    let thumbUpCount: Int32
    let thumbDownCount: Int32
    let webURL: URL?
    
    init(searchResult: SearchResult) {
        title = searchResult.word
        body = searchResult.definition
        thumbUpCount = searchResult.thumbsUpCount
        thumbDownCount = searchResult.thumbsDownCount
        webURL = searchResult.link
    }
}
