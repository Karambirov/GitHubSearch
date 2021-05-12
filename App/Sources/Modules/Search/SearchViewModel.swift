//
//  SearchViewModel.swift
//  GitHubSearch
//
//  Created by Eugene Karambirov on 28/12/2018.
//  Copyright © 2018 Eugene Karambirov. All rights reserved.
//

import UIKit

final class SearchRouter: Router<SearchViewController>, SearchRouter.Routes {
    typealias Routes = DetailsRoute
}

final class SearchViewModel {

    // MARK: - Private
	private let repositoryDataProvider: RepositoryDataProvider

    // MARK: - Properties
    var repositories: [Repository]?
    var dataSource: TableViewDataSource<Repository, RepositoryCell>?
    let router: SearchRouter.Routes

    init(
		repositoryDataProvider: RepositoryDataProvider,
		router: SearchRouter.Routes
	) {
		self.repositoryDataProvider = repositoryDataProvider
        self.router = router
    }

    // MARK: - Methods
    func searchRepositories(with query: String, completion: @escaping () -> Void) {
        repositoryDataProvider.search(with: query) { [weak self] repositories in
            self?.repositoriesDidLoad(repositories)
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func repository(for indexPath: IndexPath) -> Repository? {
        guard let repository = repositories?[indexPath.row] else { return nil }
        return repository
    }

    func deleteLoadedRepositories() {
        self.repositories?.removeAll()
        guard let repositories = repositories else { return }
        dataSource = .make(for: repositories)
    }

    private func repositoriesDidLoad(_ repositories: [Repository]) {
        self.repositories = repositories
        dataSource = .make(for: repositories)
    }

}
