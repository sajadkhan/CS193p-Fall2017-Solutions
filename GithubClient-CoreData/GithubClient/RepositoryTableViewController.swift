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

    var fetchedResultsViewController: NSFetchedResultsController<Repository>?
    let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
    }
    
    func initializeFetchedResultsController() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Repository> = Repository.fetchRequest()
            let nameSort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSort]
            fetchedResultsViewController = NSFetchedResultsController(fetchRequest: request,
                                                                      managedObjectContext: context,
                                                                      sectionNameKeyPath: nil,
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
