//
//  APIProvider.swift
//  UrbanDictionary
//
//  Created by Andy Roth on 12/24/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//

import Foundation
import Alamofire

typealias APIProviderCompletion = (_: Any?, _: Error?) -> Void

class APIProvider: NSObject {
    @discardableResult
    func requestSearchResults(using query: String, _ completion: @escaping APIProviderCompletion) -> DataRequest? {
        let headers = [ "X-Mashape-Key" : "SpAAxgsIabmshIAz9zIs39bxYVYlp1xDzKajsnff3VFpn66EiS" ]
        let params = [ "term" : query ]
        return Alamofire.request("https://mashape-community-urban-dictionary.p.mashape.com/define", method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            if let error = response.error {
                completion(nil, error)
            } else {
                completion(response.result.value, nil)
            }
        }
    }
}
