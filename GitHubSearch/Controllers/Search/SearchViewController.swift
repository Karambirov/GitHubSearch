//
//  SearchViewController.swift
//  GitHubSearch
//
//  Created by Eugene Karambirov on 28/02/2018.
//  Copyright © 2018 Eugene Karambirov. All rights reserved.
//

import UIKit

private enum Constants {
    static let nibName = "SearchViewController"
    static let cellIdentifier = "SearchResultCell"
    static let searchBarPlaceholder = "Search Repositories"
    static let navigationTitle = "Search"
}

//struct Repository {
//    let repoFullName: String
//    let ownerName: String
//    let repoDescription: String
//    let ownerEmail: String
//}

final class SearchViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    // MARK: - Properties
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    var searchResult: SearchResult!
    
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
    }
    
    static func instantiateFromNib() -> SearchViewController {
        let nib = UINib(nibName: Constants.nibName, bundle: nil)
        let vc = nib.instantiate(withOwner: nil, options: nil).first as! SearchViewController
        return vc
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        print(searchBar.text!)
        // TODO: - send network request here
        // send after a little delay from typing
        
    }
    
}

// MARK: - Table View Setup
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.items.count
    }

    // TODO: - Fill in with actual data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? SearchResultCell {
            cell.nameLabel?.text = searchResult.items[indexPath.row].fullName
            cell.ownerLabel?.text = searchResult.items[indexPath.row].owner.login
            cell.descriptionLabel?.text = searchResult.items[indexPath.row].description
            return cell
        }
        
        print("Error occured")
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "Test"
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = DetailViewController.instantiateFromNib()
        detail.ownerName = searchResult.items[indexPath.row].owner.login
        detail.ownerEmail = "EMAIL"
        detail.repoFullName = searchResult.items[indexPath.row].fullName
        detail.repoDescription = searchResult.items[indexPath.row].description
        
        navigationController?.pushViewController(detail, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}





























