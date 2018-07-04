//
//  Owner.swift
//  GithubClient
//
//  Created by Sajad on 7/1/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import Foundation
struct GithubOwner: Codable {
    let id: Int
    let name: String
    let avatarURL: String
    
    enum CodingKeys: String, CodingKey {
        case name = "login"
        case avatarURL = "avatar_url"
        case id
    }
    
    static func decodeDataWithArrayType(data: Data) -> [GithubOwner]? {
        return try? JSONDecoder().decode([GithubOwner].self, from: data)
    }
}

extension GithubOwner: SearchResultItem {
    var title: String {
        return name
    }
}
