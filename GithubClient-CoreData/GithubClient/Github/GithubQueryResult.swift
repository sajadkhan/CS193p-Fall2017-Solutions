//
//  QueryResult.swift
//  GithubClient
//
//  Created by Sajad on 7/1/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import Foundation

struct GithubQueryResult {
    public typealias PropertyList = Any
    
    private var result = [String:Any]()
    
    var totalCount: Int? {
        return result[ResultKey.totalCount] as? Int
    }
    
    var incompleteResult: Bool? {
        return result[ResultKey.inCompleteResults] as? Bool
    }
    
    var items: [[String:Any]]? {
        return result[ResultKey.items] as? [[String:Any]]
    }
    
    func resultItemsAsJsonData() -> Data? {
        if let items = items {
            return try? JSONSerialization.data(withJSONObject: items)
        }
        return nil
    }
    
    init?(data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
            let resultDictionary = json as? [String: Any] {
            result = resultDictionary
        } else {
            return nil
        }
    }
    
    struct ResultKey {
        static let totalCount = "total_count"
        static let inCompleteResults = "incomplete_results"
        static let items = "items"
    }
}
