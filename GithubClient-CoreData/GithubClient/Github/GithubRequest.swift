//
//  Github.swift
//  GithubClient
//
//  Created by Sajad on 7/1/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import Foundation
struct GithubRequest {
    // Supported Search APIs
    enum SearchAPI: String {
        case repo = "/search/repositories"
        case users = "/search/users"
        case commits = "/search/commits"
    }
    
    // Factory method to make url for a particular API
    private func urlForSearchAPI(_ api: SearchAPI, withParams params: [String: String?]) -> URL? {
        let url = URL(string: SearchPath.base)!.appendingPathComponent(api.rawValue)
        return url.withQueries(params)
    }
    
    // Fetch data from network
    func requestData(forURL url: URL, completion: @escaping (QueryResult?, Error?) -> (Void)) {
        let task = URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
            if error != nil {
                completion(nil, error)
            } else if let data = data,
                let result = QueryResult(data: data) {
                completion(result, error)
            }
        }
        task.resume()
    }
    
    
    // Request Search API for repos against a given text. Sort and Order parameters are not mendatory
    func requestSearchRepos(forText text: String,
                            sortUsing sort: String?,
                            order: String?,
                            completion: @escaping (([Repository]?) -> Void)
                            )
    {
        var params = [String:String?]()
        params[GithubKeys.query] = text
        if let sort = sort {
            params[GithubKeys.sort] = sort
        }
        if let order = order {
            params[GithubKeys.order] = order
        }
    
        if let url = urlForSearchAPI(.repo, withParams: params) {
            requestData(forURL: url) { (result, error) -> (Void) in
                if error != nil {
                    completion(nil)
                } else if let result = result,
                    let resultItemsData = result.resultItemsAsJsonData() {
                        let repos = Repository.decodeDataWithArrayType(data: resultItemsData)
                        completion(repos)
                } else {
                    completion(nil)
                }
            }
        }
    }

    

    // Search Paths
    struct SearchPath {
        static let base = "https://api.github.com"
    }
    
    // Keys in Github Request/Response
    struct GithubKeys {
        // Search Repo keys
        static let query = "q"
        static let sort  = "sort"
        static let order = "order"
        
        //Response keys
        static let items = "items"
    }
    
}

extension URL {
    func withQueries(_ queries: [String:String?]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.compactMap { URLQueryItem(name: $0, value: $1)}
        return components?.url
 
    }
}
