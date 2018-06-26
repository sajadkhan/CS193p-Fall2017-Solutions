//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Sajad on 6/26/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import Foundation
class ImageGallery {
    
    struct Item {
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
    
}
