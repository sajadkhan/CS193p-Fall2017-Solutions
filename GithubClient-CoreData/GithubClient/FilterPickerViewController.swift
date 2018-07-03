//
//  FilterPickerViewController.swift
//  GithubClient
//
//  Created by Sajad on 7/3/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit

class FilterPickerViewController: UITableViewController {

    // Model
    enum SearchFilter: String {
        case .repository = "Repository"
        case .user = "User"
        case .commits = "Commits"
        
        static let allCases: [SearchFilter] = [.repository, .user, .commits]
    }
    
    private var filters: [SearchFilter] = SearchFilter.allCases
    
    // Closure to tell that new filter is seleted
    weak var didSelectFilter: ( (SearchFilter) -> Void )?


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
            didSelectFilter(filters[indexPath.row])
        }
    }



}
