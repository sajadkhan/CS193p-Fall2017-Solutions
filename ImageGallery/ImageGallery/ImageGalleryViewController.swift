//
//  ImageGalleryViewController.swift
//  ImageGallery
//
//  Created by Sajad on 6/26/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    var imageGallery = ImageGallery()
    lazy var imageFetcher = ImageFetcher()
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
            
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoom(byHandlingPinch:)))
            collectionView.addGestureRecognizer(pinch)
        }
    }
    
    @objc private func zoom(byHandlingPinch recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            scale = max(recognizer.scale, 1.0)
        default:
            break
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
                    galleryCell.image = image == nil ? UIImage(named: "missing") : image
                }
            })
            
        }
        return cell
    }
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    
    private var scale: CGFloat = 1.0 {
        didSet {
            flowLayout?.invalidateLayout()
        }
    }
    private var widthForCells: CGFloat {
        return Constants.collectionViewCellDefaultWidth * scale
    }
    
    private func calculateSizeFor(itemAt indexPath: IndexPath) -> CGSize {
        let item = imageGallery.items[indexPath.row]
        let width = widthForCells
        return CGSize(width: width, height: width * CGFloat(item.aspectRatio))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calculateSizeFor(itemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showImageView", sender: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItem(at: indexPath)
    }

    private func dragItem(at indexPath: IndexPath) -> [UIDragItem] {
        let item = imageGallery.items[indexPath.item]
        let string = "\(item.url.absoluteString)::\(String(item.aspectRatio))"
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: string as NSItemProviderWriting))
        dragItem.localObject = string
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return isSelf ? session.canLoadObjects(ofClass: NSString.self) : (session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self))
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndex = item.sourceIndexPath {
                if let string = item.dragItem.localObject as? String {
                    let components = string.components(separatedBy: "::")
                    let url = URL(string: components[0])
                    let aspectRatio = Float(components[1])
                    let galleryItem = ImageGallery.Item(url: url!, aspectRatio: aspectRatio!)
                    collectionView.performBatchUpdates({
                        imageGallery.items.remove(at: sourceIndex.item)
                        imageGallery.items.insert(galleryItem, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndex])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                let placeHolderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "GalleryCell"))
                
                
                var aspectRatio = Float(1.0)
                
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        aspectRatio = Float(image.size.height/image.size.width)
                    }
                }
                
                
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (url, error) in
                    if let url = url as? URL{
                        DispatchQueue.main.async {
                            let galleryItem = ImageGallery.Item(url: url, aspectRatio: aspectRatio)
                            placeHolderContext.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
                                self.imageGallery.items.insert(galleryItem, at: insertionIndexPath.item)
                            })
                        }
                    } else {
                        placeHolderContext.deletePlaceholder()
                    }
                    
                }
            
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageView",
            let indexPath = sender as? IndexPath,
            let destination = segue.destination as? ImageViewController {
            let item = imageGallery.items[indexPath.item]
            destination.imageURL = item.url
        }
    }
    
    
    struct Constants {
        static let collectionViewCellDefaultWidth: CGFloat = 100.0
    }

}
