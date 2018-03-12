//
//  SearchViewController.swift
//  GitHubSearch
//
//  Created by Eugene Karambirov on 28/02/2018.
//  Copyright © 2018 Eugene Karambirov. All rights reserved.
//

import UIKit
import Moya

private enum Constants {
    static let nibName = "SearchViewController"
    static let cellIdentifier = "SearchResultCell"
    static let searchBarPlaceholder = "Search Repositories"
    static let navigationTitle = "Search"
}

final class SearchViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    // MARK: - Properties
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    var repositories = [Repository]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - ViewController's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }

}

// MARK: - Setup
extension SearchViewController {
    
    fileprivate func initialSetup() {
        setupTableView()
        setupNavigationBar()
        setupSearchController()
    }
    
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: Constants.cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Constants.cellIdentifier)
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.title = Constants.navigationTitle
        navigationItem.searchController = searchController
    }
    
    fileprivate func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = Constants.searchBarPlaceholder
        searchController.searchBar.delegate = self
    }
    
    static func instantiateFromNib() -> SearchViewController {
        let nib = UINib(nibName: Constants.nibName, bundle: nil)
        let vc = nib.instantiate(withOwner: nil, options: nil).first as! SearchViewController
        return vc
    }
}


// MARK: - UISearchBar Delegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // TODO: - send network request here
        // send after a little delay from typing
        guard let query = searchBar.text else { return }
        
        NetworkService.provider.request(.repoSearch(query: query)) { result in
            switch result {

            case .success(let response):
                let data = response.data
                do {
                    let repositories = try JSONDecoder().decode(SearchResults<Repository>.self, from: data)
                    print(repositories.items)
                    self.repositories = repositories.items
                } catch let error {
                    print("ERROR: \(error)")
                }

            case .failure(let error):
                print("ERROR: \(error.errorDescription), REASON: \(error.failureReason)")
            }
        }
    }
    
}

// MARK: - UISearchResultsUpdating Delegate
extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
//        print(searchBar.text!)
    }
    
}

// MARK: - Table View Delegate and Data Source
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? SearchResultCell {
            cell.repository = repositories[indexPath.row]
            return cell
        }
        
        print("Error occured")
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "Error"
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = DetailViewController.instantiateFromNib()
        detail.repository = repositories[indexPath.row]
        
        navigationController?.pushViewController(detail, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}





























