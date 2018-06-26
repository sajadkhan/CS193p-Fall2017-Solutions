//
//  ImageGalleryViewController.swift
//  ImageGallery
//
//  Created by Sajad on 6/26/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate {

    var imageGallery = ImageGallery()
    lazy var imageFetcher = ImageFetcher()
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.dragDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallery.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath)
        
        if let galleryCell = cell as? ImageGalleryCollectionViewCell {
            galleryCell.image = nil
            let item = imageGallery.items[indexPath.item]
            let imageURL = item.url.imageURL
            
            imageFetcher.fetch(imageURL, handler: { (url, image) in
                DispatchQueue.main.async {
                    galleryCell.image = image
                    }
            })
            
        }
        return cell
    }
    
    func calculateSizeFor(itemAt indexPath: IndexPath) -> CGSize {
        let item = imageGallery.items[indexPath.row]
        let width = CGFloat(Constants.collectionViewCellWidth)
        return CGSize(width: width, height: width * CGFloat(item.aspectRatio))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calculateSizeFor(itemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItem(at: indexPath)
    }

    private func dragItem(at indexPath: IndexPath) -> [UIDragItem] {
        let item = imageGallery.items[indexPath.row]
    
        let dragItem1 = UIDragItem(itemProvider: NSItemProvider(object: item.url as NSItemProviderWriting))
        let dragItem2 = UIDragItem(itemProvider: NSItemProvider(object: String(item.aspectRatio) as NSItemProviderWriting))
    
        return [dragItem1, dragItem2]
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    struct Constants {
        static let collectionViewCellWidth = 200.0
    }

}
