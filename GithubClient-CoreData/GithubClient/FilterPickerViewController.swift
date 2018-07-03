//
//  FilterPickerViewController.swift
//  GithubClient
//
//  Created by Sajad on 7/3/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit

enum SearchFilter: String {
    case repository = "Repository"
    case user = "User"
    case commits = "Commits"
    
    static let allCases: [SearchFilter] = [.repository, .user, .commits]
}

extension SearchFilter {
    var relatedGithubSearchAPI: GithubRequest.SearchAPI? {
        switch self {
        case .repository:
            return .repo
        case .user:
            return .users
        case .commits:
            return .commits
        }
    }
}

class FilterPickerViewController: UITableViewController {

    // Closure to tell that new filter is seleted
    var didSelectFilter: ( (SearchFilter) -> Void )?
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Model
    private var filters: [SearchFilter] = SearchFilter.allCases


    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        cell.textLabel?.text = filters[indexPath.row].rawValue

        return cell
    }
    
    // MARK: - UITableViewDelgate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if didSelectFilter != nil {
            didSelectFilter!(filters[indexPath.row])
        }
    }



}
