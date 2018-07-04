//
//  Repository.swift
//  GithubClient
//
//  Created by Sajad on 7/1/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import Foundation

struct GithubRepository: Codable {
    
    let id: Int
    let name: String
    let fullName: String
    let owner: GithubOwner
    let isPrivate: Bool
    let description: String?
    let createdAt: String?
    let size: Int?
    let language: String?

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case isPrivate = "private"
        case createdAt = "created_at"
        case id, name, description,size, language, owner
    }
        
    static func decodeDataWithArrayType(data: Data) -> [GithubRepository]? {
        return try? JSONDecoder().decode([GithubRepository].self, from: data)
    }
}

extension GithubRepository: SearchResultItem {
    var title: String {
        return name
    }
    var subtitle: String {
        return fullName
    }
}

extension GithubRepository {
    var createdDate: Date? {
        if let dateString = createdAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.date(from: dateString)
        }
        return nil
    }
}
