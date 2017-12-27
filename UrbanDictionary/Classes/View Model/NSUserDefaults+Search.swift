//
//  NSUserDefaults+Search.swift
//  UrbanDictionary
//
//  Created by Andy Roth on 12/27/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//

import Foundation

extension UserDefaults {
    var currentSearchQuery: String {
        get {
            return self.object(forKey: "currentSearchQuery") as? String ?? ""
        }
        set {
            self.set(newValue, forKey: "currentSearchQuery")
        }
    }
    
    var currentSortType: String {
        get {
            return self.object(forKey: "currentSortType") as? String ?? ""
        }
        set {
            self.set(newValue, forKey: "currentSortType")
        }
    }
}
