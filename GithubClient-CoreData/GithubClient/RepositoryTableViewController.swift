//
//  RepositoryTableViewController.swift
//  GithubClient
//
//  Created by Sajad on 7/7/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit
import CoreData

class RepositoryTableViewController: FetchedResultsTableViewController {

    private var fetchedResultsViewController: NSFetchedResultsController<Repository>?
    private let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.dataController?.persistentContainer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
    }
    
    private func initializeFetchedResultsController() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Repository> = Repository.fetchRequest()
            let ownerSort = NSSortDescriptor(key: "owner.name", ascending: true)
            let nameSort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSort, ownerSort]
            //sectionNameKeyPath is set to owner.name to have list divided into sections by owners
            // The sectionNameKeyPath property must also be an NSSortDescriptor instance.
            //The NSSortDescriptor must be the first descriptor in the array passed to the fetch request.
            fetchedResultsViewController = NSFetchedResultsController(fetchRequest: request,
                                                                      managedObjectContext: context,
                                                                      sectionNameKeyPath: "owner.name",
                                                                      cacheName: nil)
            fetchedResultsViewController?.delegate = self
            do {
                try fetchedResultsViewController?.performFetch()
            } catch {
                fatalError("Failed to initialize fetchedResultController")
            }
        }
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repositoryCell", for: indexPath)
        guard let repositoryMO = fetchedResultsViewController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        cell.textLabel?.text = repositoryMO.name ?? ""
        cell.detailTextLabel?.text = repositoryMO.fullName ?? ""
        
        return cell
    }

}

// UITableViewDataSource+NSFetchedResultControllerDelegate
extension RepositoryTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsViewController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsViewController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsViewController?.sections, sections.count > 0 {
            return sections[section].name
        } else {
            return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsViewController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsViewController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
}
