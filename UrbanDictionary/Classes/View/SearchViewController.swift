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
    
    // Outlets
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    // Properties
    private var viewModel: SearchViewModel?
    
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

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.search(for: searchText)
    }
}

extension SearchViewController: SearchViewModelDelegate {
    func viewModelDidUpdateSearchResults(_ viewModel: SearchViewModel) {
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.resultCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel,
              let result = viewModel.result(at: indexPath),
              let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? SearchResultCell else { return UITableViewCell() }
        
        cell.textLabel?.text = result.title
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {

}
