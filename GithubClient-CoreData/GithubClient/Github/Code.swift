//
//  Code.swift
//  GithubClient
//
//  Created by Sajad on 7/3/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import Foundation
struct Code: Codable {
    let name: String
    let repository: Repository
    let path: String
    
    static func decodeDataWithArrayType(data: Data) -> [Code]? {
        return try? JSONDecoder().decode([Code].self, from: data)
    }
}

extension Code: SearchResultItem {
    var title: String {
        return name
    }
    var subtitle: String {
        return path
    }
}

