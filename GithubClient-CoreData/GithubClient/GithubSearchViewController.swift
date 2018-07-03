//
//  ViewController.swift
//  GithubClient
//
//  Created by Sajad on 7/1/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit

class GithubSearchViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    @IBAction func refreshContrllerValueChanged(_ sender: UIRefreshControl) {
        if let text = searchBar.text {
            updateSearch(forText: text)
        }
    }
    
    
    func updateSearch(forText text: String) {
        let request = GithubRequest()
        request.requestSearchAPI(for: filter.relatedGithubSearchAPI!,
                                 searchText: text,
                                 sort: nil,
                                 order: nil) { repos in
            if let repos = repos {
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.searchResults = repos
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "\(filter.rawValue)"
    }
    
    // MARK: - Search Filter
    
    private func updateFilter(to filter: SearchFilter) {
        navigationItem.title = "\(filter.rawValue)"
        if self.filter != filter {
            self.filter = filter
            updateSearch(forText: searchBar.text!)
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
            let filtersVC = segue.destination.contents as? FilterPickerViewController {
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
        if let text = searchBar.text,
            !text.isEmpty {
            updateSearch(forText: text)
        }
        
    }
}



