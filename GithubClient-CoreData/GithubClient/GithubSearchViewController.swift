//
//  ViewController.swift
//  GithubClient
//
//  Created by Sajad on 7/1/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit
import CoreData

class GithubSearchViewController: UITableViewController {

    let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.dataController?.persistentContainer
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    @IBAction func refreshContrllerValueChanged(_ sender: UIRefreshControl) {
        refreshSearchResults()
    }
    
    private func refreshSearchResults() {
        if searchBar.hasValidEntry {
            performSearch(forText: searchBar.text!)
        }
    }
    
    private func performSearch(forText text: String) {
        let request = GithubRequest()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        request.requestSearchAPI(for: filter.relatedGithubSearchAPI!,
                                 searchText: text,
                                 sort: nil,
                                 order: nil) { items in
                                    DispatchQueue.main.async {
                                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                        self.tableView.refreshControl?.endRefreshing()
                                        self.searchResults.removeAll()
                                        if let items = items {
                                            self.searchResults = items
                                            self.updateDatabase(with: items)
                                            print("\(items.count) results found")
                                        }
                                        self.tableView.reloadData()
                                    }
        }
    }
    
    // Perfomrs a background save of the recently fetched items from Github using search API.
    private func updateDatabase(with items: [SearchResultItem]) {
        container?.performBackgroundTask { [weak self] context in
            for item in items {
                if let repo = item as? GithubRepository {
                    _ = try? Repository.findOrCreateRepository(matching: repo, in: context)
                }
                if let user = item as? GithubOwner {
                    _ = try? Owner.findOrCreateOwner(matching: user, in: context)
                }
                if let code = item as? GithubCode {
                    _ = try? Code.createCodeObject(matching: code, in: context)
                }
            }
            do {
                try context.save()
            } catch {
                print(error)
            }
            self?.printDatabaseStatistics()
        }
    }
    // Utility method to debug database saves
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                if let repoCount = try? context.count(for: Repository.fetchRequest()) {
                    print("repoCount = \(repoCount)")
                }
                if let usersCount = try? context.count(for: Owner.fetchRequest()) {
                    print("ownerCount = \(usersCount)")
                }
                if let codeCount = try? context.count(for: Code.fetchRequest()) {
                    print("codeCount = \(codeCount)")
                }
            }
        }
    }
    
    private func setNavigationTitle(forFilter filter: SearchFilter) {
        navigationItem.title = "Search \(filter.rawValue)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle(forFilter: filter)
    }
    
    // MARK: - Search Filter
    
    private func updateFilter(to filter: SearchFilter) {
        if self.filter != filter {
            setNavigationTitle(forFilter: filter)
            self.filter = filter
            refreshSearchResults()
        }
    }
    
    
    
    // Model for this controller
    private var searchResults = [SearchResultItem]()

    private var  filter: SearchFilter = .repository
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell")!
        let item = searchResults[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentFilterControllerSegue",
            let filtersVC = segue.destination.contents as? ChooseFilterTableViewController {
            filtersVC.didSelectFilter = { [weak self] filter in
                self?.updateFilter(to: filter)
                self?.presentedViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}


extension UIViewController {
    var contents: UIViewController {
        if let navVC = self as? UINavigationController {
            return navVC.visibleViewController ?? navVC
        } else {
            return self
        }
        
    }
}

extension GithubSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.hasValidEntry {
            performSearch(forText: searchBar.text!)
            searchBar.resignFirstResponder()
        }
        
    }
}

extension UISearchBar {
    var hasValidEntry: Bool {
        return (self.text != nil) && (!(self.text?.isEmpty)!)
    }
}


