//
//  FavoritesViewModel.swift
//  GitHubSearch
//
//  Created by Eugene Karambirov on 31/01/2019.
//  Copyright © 2019 Eugene Karambirov. All rights reserved.
//

import Foundation
import RealmSwift

final class FavoritesRouter: Router<FavoritesViewController>, FavoritesRouter.Routes {
    typealias Routes = DetailsRoute
}

final class FavoritesViewModel {

    // MARK: - Private
	private let repositoryDataProvider: RepositoryDataProvider

    // MARK: - Properties
    var favoriteRepositories: [Repository]?
    var dataSource: TableViewDataSource<Repository, RepositoryCell>?
    let router: FavoritesRouter.Routes

    init(
		repositoryDataProvider: RepositoryDataProvider,
		router: FavoritesRouter.Routes
	) {
		self.repositoryDataProvider = repositoryDataProvider
        self.router = router
    }

    // MARK: - Methods
    func fetchFavoriteRepositories(_ completion: @escaping () -> Void) {
        repositoryDataProvider.fetchFavorites { [weak self] repositories in
            self?.repositoriesDidLoad(repositories)
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func repository(for indexPath: IndexPath) -> Repository? {
        guard let repository = favoriteRepositories?[indexPath.row] else { return nil }
        return repository
    }

    private func repositoriesDidLoad(_ repositories: [Repository]) {
        self.favoriteRepositories = repositories
        dataSource = .make(for: favoriteRepositories!)
    }
}
