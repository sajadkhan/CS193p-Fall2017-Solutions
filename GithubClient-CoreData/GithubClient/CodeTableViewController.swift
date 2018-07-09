//
//  CodeTableViewController.swift
//  GithubClient
//
//  Created by Sajad on 7/9/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit
import CoreData

class CodeTableViewController: FetchedResultsTableViewController {

    private var fetchedResultsController: NSFetchedResultsController<Code>?
    private let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.dataController?.persistentContainer
    
    private func initializeFetchedResultsController() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Code> =  Code.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
            fetchedResultsController?.delegate = self
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                fatalError("Failed to initialize fetchResultsController")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "codeCell", for: indexPath)
        // get manged object of this index from fetchedResultsController
        if let codeMO = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = codeMO.name ?? ""
            cell.detailTextLabel?.text = codeMO.path ?? ""
        }

        return cell
    }

}

// TableViewDataSoure Methods by using fetchedResultController
extension CodeTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].name
        } else {
            return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
}
