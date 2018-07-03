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
        request.requestSearchAPI(for: .users, searchText: text, sort: nil, order: nil) { repos in
            if let repos = repos {
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.searchResults = repos
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Search Filter
    
    private func updateFilter(to filter: SearchFilter) {
        navigationItem.title = "Search \(filter.rawValue)"
        self.filter = filter
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
            let filtersVC = segue.destination as? FilterPickerViewController {
            filtersVC.didSelectFilter { filter in 
                dismiss(animated: true, completion: false)
            }
        }
    }
    
 
}

extension GithubSearchViewController {
    private func githubAPIForFilter(_ filter: SearchFilter) -> GithubRequest.SearchAPI? {
        switch filter {
        case .repository:
            return .repo
        case .user:
            return .users
        case .commits:
            return commits
        default:
            nil
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



