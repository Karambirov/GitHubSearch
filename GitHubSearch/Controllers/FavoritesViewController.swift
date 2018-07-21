//
//  FavoritesViewController.swift
//  GitHubSearch
//
//  Created by Eugene Karambirov on 16/07/2018.
//  Copyright © 2018 Eugene Karambirov. All rights reserved.
//

import UIKit
import CoreData

final class FavoritesViewController: UITableViewController {

    // MARK: - Properties
    var coreDataService: CoreDataService!
    fileprivate var fetchedResultsController: NSFetchedResultsController<Repository> = NSFetchedResultsController()

    // MARK: - View Controller's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }

}


// MARK: - Table View
extension FavoritesViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RepositoryCell = tableView.dequeueCell(withIdentifier: RepositoryCell.typeName, for: indexPath)
        let repository = fetchedResultsController.object(at: indexPath)
        configure(cell, withRepository: repository)
        return cell
    }

    func configure(_ cell: RepositoryCell, withRepository repository: Repository) {
        cell.repository = repository
    }


}


// MARK: - NSFetchedResultsController
extension FavoritesViewController {

    func favoritesFetchedResultController() -> NSFetchedResultsController<Repository> {

        fetchedResultsController = NSFetchedResultsController(fetchRequest: repositoryFetchRequest(),
                                                              managedObjectContext: coreDataService.mainContext,
                                                              sectionNameKeyPath: nil, cacheName: nil)

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController
        } catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }

    }

    func repositoryFetchRequest() -> NSFetchRequest<Repository> {
        let fetchRequest: NSFetchRequest<Repository> = Repository.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "fullName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }

}


// MARK: - Navigation
extension FavoritesViewController: SegueHandlerType {

    enum SegueIdentifier: String {
        case showDetail
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segueIdentifier(for: segue) {
        case .showDetail:
            if let indexPath = tableView.indexPathForSelectedRow {
                let detail = segue.destination as! DetailViewController
                detail.repository = fetchedResultsController.object(at: indexPath)
            }

        }
    }

}


// MARK: - NSFetchedResultsControllerDelegate
extension FavoritesViewController: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }

}


// MARK: - Private
private extension FavoritesViewController {

    func initialSetup() {
        setupNavigationBar()
        setupTableView()

        fetchedResultsController = favoritesFetchedResultController()
    }

    func setupNavigationBar() {
        clearsSelectionOnViewWillAppear = true
    }


    func setupTableView() {
        let nib = UINib(nibName: RepositoryCell.typeName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: RepositoryCell.typeName)
        tableView.tableFooterView = UIView()
    }

}
