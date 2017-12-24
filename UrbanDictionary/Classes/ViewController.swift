//
//  ViewController.swift
//  UrbanDictionary
//
//  Created by Andy Roth on 12/24/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        APIProvider.requestSearchResults(using: "wat") { (response, error) in
            debugPrint("response is \(response)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

