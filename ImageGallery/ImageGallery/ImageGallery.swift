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
    
    static let samples = [ImageGallery(with: "Sample", items: [Item(url: URL(string: "https://www.google.com/imgres?imgurl=https%3A%2F%2Fd2gg9evh47fn9z.cloudfront.net%2F800px_COLOURBOX18456667.jpg&imgrefurl=https%3A%2F%2Fwww.colourbox.com%2Fvector%2Fsummer-countryside-landscape-vector-18456667&docid=gIhAKlbJdC3jRM&tbnid=8CMmdxYMbEStHM%3A&vet=10ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwi7ASgBMAE..i&w=800&h=480&client=safari&bih=739&biw=1280&q=countryside%20cartoon&ved=0ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwi7ASgBMAE&iact=mrc&uact=8")!, aspectRatio: 1.0),
                                                               Item(url: URL(string: "https://www.google.com/imgres?imgurl=https%3A%2F%2Fcdn2.vectorstock.com%2Fi%2F1000x1000%2F98%2F11%2Fcountryside-cartoon-landscape-vector-11099811.jpg&imgrefurl=https%3A%2F%2Fwww.vectorstock.com%2Froyalty-free-vector%2Fcountryside-cartoon-landscape-vector-11099811&docid=70XH7JFrfzfH9M&tbnid=11qjO7znft63WM%3A&vet=10ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwi6ASgAMAA..i&w=1000&h=1080&client=safari&bih=739&biw=1280&q=countryside%20cartoon&ved=0ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwi6ASgAMAA&iact=mrc&uact=8")!, aspectRatio: 1.0),
                                                               Item(url: URL(string: "https://www.google.com/imgres?imgurl=https%3A%2F%2Fvectortoons.com%2Fwp-content%2Fuploads%2F2017%2F03%2Fa-dutch-countryside-background.jpg&imgrefurl=https%3A%2F%2Fvectortoons.com%2Fproduct%2Fa-dutch-countryside-background%2F&docid=bijlD6cJvzuSFM&tbnid=eRYEbv0ZTd3MvM%3A&vet=10ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwjBASgHMAc..i&w=1024&h=576&client=safari&bih=739&biw=1280&q=countryside%20cartoon&ved=0ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwjBASgHMAc&iact=mrc&uact=8")!, aspectRatio: 1.0),
                                                               Item(url: URL(string: "https://www.google.com/imgres?imgurl=https%3A%2F%2Fvectortoons.com%2Fwp-content%2Fuploads%2F2017%2F06%2Fa-countryside-cottage-background.jpg&imgrefurl=https%3A%2F%2Fvectortoons.com%2Fproduct%2Fa-countryside-cottage-background%2F&docid=nSwVA4cTEfgfxM&tbnid=oILh2Dz7s-PPQM%3A&vet=10ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwjiASgbMBs..i&w=1024&h=576&client=safari&bih=739&biw=1280&q=countryside%20cartoon&ved=0ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwjiASgbMBs&iact=mrc&uact=8")!, aspectRatio: 1.0),
                                                               Item(url: URL(string: "https://www.google.com/imgres?imgurl=https%3A%2F%2Fpng.pngtree.com%2Felement_origin_min_pic%2F17%2F03%2F19%2F906529e07714136a5faaebbcfc6030dc.jpg&imgrefurl=https%3A%2F%2Fpngtree.com%2Ffreepng%2Fcountry-landscape_2982264.html&docid=y7LFjgvpx9bDAM&tbnid=q_9cURiuV7K5sM%3A&vet=10ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwjfASgYMBg..i&w=650&h=400&client=safari&bih=739&biw=1280&q=countryside%20cartoon&ved=0ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwjfASgYMBg&iact=mrc&uact=8")!, aspectRatio: 1.0),
                                                               Item(url: URL(string: "https://www.google.com/imgres?imgurl=https%3A%2F%2Fthumbs.dreamstime.com%2Fb%2Fcartoon-beautiful-fall-farm-scene-countryside-landscape-haystacks-fields-flat-landscape-organic-food-concept-any-76844149.jpg&imgrefurl=https%3A%2F%2Fwww.dreamstime.com%2Fstock-illustration-cartoon-beautiful-fall-farm-scene-countryside-landscape-haystacks-fields-flat-landscape-organic-food-concept-any-image76844149&docid=FZbFZBYxyjEN8M&tbnid=zJBHXEZDwtIOXM%3A&vet=10ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwjnASggMCA..i&w=800&h=506&client=safari&bih=739&biw=1280&q=countryside%20cartoon&ved=0ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwjnASggMCA&iact=mrc&uact=8")!, aspectRatio: 1.0),
                                                               Item(url: URL(string: "https://www.google.com/imgres?imgurl=https%3A%2F%2Fpre00.deviantart.net%2Fe7c0%2Fth%2Fpre%2Fi%2F2012%2F077%2F8%2F5%2Fcartoon_countryside_by_stopsigndrawer81-d4t6dao.jpg&imgrefurl=https%3A%2F%2Fstopsigndrawer81.deviantart.com%2Fart%2FCartoon-Countryside-290870736&docid=L0G5_WxNde2OHM&tbnid=g6UctWw-W_2p0M%3A&vet=10ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwjzASgsMCw..i&w=1153&h=692&client=safari&bih=739&biw=1280&q=countryside%20cartoon&ved=0ahUKEwiK84-D9fDbAhUQr6QKHdDiCb0QMwjzASgsMCw&iact=mrc&uact=8")!, aspectRatio: 1.0)]),
                          ImageGallery(with: "Sample1", items: []),
                          ImageGallery(with: "Sample2", items: [])]
}
