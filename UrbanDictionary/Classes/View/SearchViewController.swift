//
//  ViewController.swift
//  UrbanDictionary
//
//  Created by Andy Roth on 12/24/17.
//  Copyright © 2017 Andy Roth. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
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
        }
    }
    
    @IBAction func didTapSortButton(_ sender: Any) {
        let sortType = viewModel?.currentSortType ?? .thumbsUp
        let thumbsUpText = sortType == .thumbsUp ? "✔︎ Thumbs Up" : "Thumbs Up"
        let thumbsDownText = sortType == .thumbsDown ? "✔︎ Thumbs Down" : "Thumbs Down"
        let actionSheet = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: thumbsUpText, style: .default, handler: { (action) in
            self.viewModel?.sort(by: .thumbsUp)
        }))
        actionSheet.addAction(UIAlertAction(title: thumbsDownText, style: .default, handler: { (action) in
            self.viewModel?.sort(by: .thumbsDown)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
}

extension SearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel,
            let result = viewModel.result(at: indexPath),
            let url = result.webURL else { return }
        let configuration = SFSafariViewController.Configuration()
        configuration.barCollapsingEnabled = false
        let safariController = SFSafariViewController(url: url, configuration: configuration)
        safariController.preferredBarTintColor = navigationController?.navigationBar.barTintColor
        safariController.delegate = self
        navigationController?.pushViewController(safariController, animated: true)
    }
}

extension SearchViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        navigationController?.popToRootViewController(animated: true)
    }
}
