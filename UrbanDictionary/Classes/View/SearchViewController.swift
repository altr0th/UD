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
    @IBOutlet var networkActivityIndicator: UIActivityIndicatorView!
    
    // Properties
    private var viewModel: SearchViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupPersistedState()
    }
    
    private func setupViewModel() {
        let coreDataCoordinator = CoreDataCoordinator()
        let apiProvider = APIProvider()
        viewModel = SearchViewModel(coreDataCoordinator: { coreDataCoordinator }, apiProvider: { apiProvider })
        viewModel?.searchResultsDidChange = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel?.networkActivityDidChange = { [weak self] (active: Bool) in
            if active {
                self?.networkActivityIndicator.startAnimating()
            } else {
                self?.networkActivityIndicator.stopAnimating()
            }
        }
    }
    
    private func setupPersistedState() {
        if UserDefaults.standard.currentSearchQuery.count > 0 {
            searchBar.text = UserDefaults.standard.currentSearchQuery
            searchBar.becomeFirstResponder()
        }
    }
    
    @IBAction func didTapSortButton(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Thumbs Up", style: .default, handler: { (action) in
            self.viewModel?.sort(by: .thumbsUp)
        }))
        actionSheet.addAction(UIAlertAction(title: "Thumbs Down", style: .default, handler: { (action) in
            self.viewModel?.sort(by: .thumbsDown)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.search(for: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
        
        cell.viewModel = result
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {

}
