//
//  RepositoryService.swift
//  GitHubSearch
//
//  Created by Eugene Karambirov on 23/01/2019.
//  Copyright © 2019 Eugene Karambirov. All rights reserved.
//

import Foundation

final class RepositoryService {

    private var networkService: NetworkService
    private var realmService: RealmService

    init(networkService: NetworkService = .init(), realmService: RealmService = .init()) {
        self.networkService = networkService
        self.realmService = realmService
    }

    func search(with query: String, completion: @escaping ([Repository]) -> Void) {
        networkService.searchRepositories(with: query) { repositories in
            guard let repositories = repositories else { return }
            completion(repositories)
        }
    }

    func fetchFavorites(completion: @escaping ([Repository]) -> Void) {
        let predicate = NSPredicate(format: "isFavorite = true")
        let completionHandle: ([Repository]) -> Void = { repositories in
            completion(repositories.compactMap { $0.copy() as? Repository})
        }
        realmService.fetch(Repository.self, predicate: predicate, completion: completionHandle)
    }

    func toggleFavorite(_ repository: Repository) {
        repository.isFavorite = !repository.isFavorite

        repository.isFavorite
            ? saveRepository(repository)
            : deleteRepository(repository)
    }

    func saveRepository(_ repository: Repository) {
        if let newRepository = repository.copy() as? Repository {
            realmService.save(newRepository)
        }
    }

    func deleteRepository(_ repository: Repository) {
        if let object = realmService.fetch(ofType: Repository.self, forPrimaryKey: repository.fullName) {
            if let owner = object.owner {
                realmService.delete(owner)
            }
            realmService.delete(object)
        }
    }
}
