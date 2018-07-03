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
        request.requestSearchRepos(forText: text, sortUsing: nil, order: nil) { repos in
            if let repos = repos {
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.searchResults = repos
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    var searchResults = [Repository]()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Search Result Cell")!
        let repo = searchResults[indexPath.row]
        cell.textLabel?.text = repo.name
        cell.detailTextLabel?.text = repo.fullName
        return cell
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



