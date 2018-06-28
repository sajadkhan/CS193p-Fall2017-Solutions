//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Sajad on 6/26/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import Foundation
struct ImageGallery: Codable {
    
    struct Item: Codable {
        let url: URL
        let aspectRatio: Float
    }
    
    var name = ""
    var items = [Item]()
    
    init(with name: String, items: [Item]) {
        self.name = name
        self.items = items
    }
    
    init() {
        self.name = "New Gallery"
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(ImageGallery.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    
}
