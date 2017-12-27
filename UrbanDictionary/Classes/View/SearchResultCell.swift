//
//  SearchResultCell.swift
//  UrbanDictionary
//
//  Created by Andy Roth on 12/26/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//

import Foundation
import UIKit

class SearchResultCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var thumbUpLabel: UILabel!
    @IBOutlet var thumbDownLabel: UILabel!
    
    var viewModel: SearchResultViewModel? {
        didSet {
            if let viewModel = viewModel {
                titleLabel.text = viewModel.title
                bodyLabel.text = viewModel.body
                thumbUpLabel.text = viewModel.thumbUpCount.description
                thumbDownLabel.text = viewModel.thumbDownCount.description
            }
        }
    }
}
