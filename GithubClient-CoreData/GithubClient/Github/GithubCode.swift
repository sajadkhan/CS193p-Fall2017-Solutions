//
//  Code.swift
//  GithubClient
//
//  Created by Sajad on 7/3/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import Foundation
struct GithubCode: Codable {
    let name: String
    let repository: GithubRepository
    let path: String
    
    static func decodeDataWithArrayType(data: Data) -> [GithubCode]? {
        return try? JSONDecoder().decode([GithubCode].self, from: data)
    }
}

extension GithubCode: SearchResultItem {
    var title: String {
        return name
    }
    var subtitle: String {
        return path
    }
}

