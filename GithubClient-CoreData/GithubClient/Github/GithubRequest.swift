//
//  Github.swift
//  GithubClient
//
//  Created by Sajad on 7/1/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import Foundation

protocol SearchResultItem {
    var title: String { get }
    var subtitle: String { get }
}

extension SearchResultItem {
    var subtitle: String {
        return ""
    }
}

struct GithubRequest {
    // Supported Search APIs
    enum SearchAPI: String {
        case repo = "/search/repositories"
        case users = "/search/users"
        case code = "/search/code"
    }
    
    // Factory method to make url for a particular API
    private func urlForSearchAPI(_ api: SearchAPI, withParams params: [String: String?]) -> URL? {
        let url = URL(string: SearchPath.base)!.appendingPathComponent(api.rawValue)
        return url.withQueries(params)
    }
    
    // Fetch data from network
    private func requestData(forURL url: URL, completion: @escaping (GithubQueryResult?, Error?) -> (Void)) {
        let task = URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
            if error != nil {
                completion(nil, error)
            } else if let data = data,
                let result = GithubQueryResult(data: data) {
                completion(result, error)
            }
        }
        task.resume()
    }
    
    // Request Search API for repos, users and others, see SearchAPI enum against a given searchText. Sort and Order parameters are not mendatory
    func requestSearchAPI(for api: SearchAPI,
                          searchText text: String,
                          sort: String?,
                          order: String?,
                          completion: @escaping (([SearchResultItem]?) -> Void)) {
        
        var params = [String:String?]()
        params[GithubKeys.query] = text
        if let sort = sort {
            params[GithubKeys.sort] = sort
        }
        if let order = order {
            params[GithubKeys.order] = order
        }
        
        
        if let url = urlForSearchAPI(api, withParams: params) {
            requestData(forURL: url) { (result, error) -> (Void) in
                if error != nil {
                    completion(nil)
                } else if let result = result,
                    let resultItemsData = result.resultItemsAsJsonData() {
                    var resultItems: [SearchResultItem]?
                    switch api {
                    case .repo:
                        resultItems = GithubRepository.decodeDataWithArrayType(data: resultItemsData)
                    case .users:
                        resultItems = GithubOwner.decodeDataWithArrayType(data: resultItemsData)
                    case .code:
                        resultItems = GithubCode.decodeDataWithArrayType(data: resultItemsData)
                    }
                    completion(resultItems)
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
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
