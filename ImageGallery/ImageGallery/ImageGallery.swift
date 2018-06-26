//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Sajad on 6/26/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import Foundation
class ImageGallery {
    var name: String!
    var imageUrls = [URL]()
    
    init(with name: String, imageUrls: [URL]) {
        self.name = name
        self.imageUrls = imageUrls
    }
    
    static let samples = [ImageGallery(with: "Sample", imageUrls: []),
                          ImageGallery(with: "Sample1", imageUrls: []),
                          ImageGallery(with: "Sample2", imageUrls: [])]
}
