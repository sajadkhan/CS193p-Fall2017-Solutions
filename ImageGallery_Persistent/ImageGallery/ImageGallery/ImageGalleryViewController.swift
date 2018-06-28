//
//  ImageGalleryViewController.swift
//  ImageGallery
//
//  Created by Sajad on 6/26/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    static let ImageGalleryDidChanged = NSNotification.Name("ImageGalleryDidChanged")
}
class ImageGalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    var imageGallery = ImageGallery() {
        didSet {
            updateUIState()
        }
    }
    
    func updateUIState() {
        let isEmpty = imageGallery.items.count == 0
        emptyGalleryMessageLabel.isHidden = !isEmpty
    }

    lazy var imageFetcher = ImageFetcher()
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
            collectionView.dragInteractionEnabled = true
            
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoom(byHandlingPinch:)))
            collectionView.addGestureRecognizer(pinch)
        }
    }
    
    @IBOutlet weak var emptyGalleryMessageLabel: UILabel!
    
    // MARK: - Zoom and Scaling
    
    private var scale: CGFloat = 1.0 {
        didSet {
            flowLayout?.invalidateLayout()
        }
    }
    
    private var widthForCells: CGFloat {
        return Constants.collectionViewCellDefaultWidth * scale
    }
    
    @objc private func zoom(byHandlingPinch recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            scale = max(recognizer.scale, 1.0)
        default:
            break
        }
    }
    
    // MARK: - Document
    
    var document: ImageGalleryDocument?
    
    private func documentChanged() {
        if document?.imageGallery != nil {
            document?.thumbnail = self.collectionView.snapshot
        }
        document?.imageGallery = imageGallery
        if document?.imageGallery != nil {
            document?.updateChangeCount(.done)
        }
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true) {
            self.document?.close { success in
                // when our document completes closing
                // stop observing its documentState changes
                if let observer = self.documentObserver {
                    NotificationCenter.default.removeObserver(observer)
                }
            }
        }
    }
    
    
    // MARK: - View's Life Cycle

    private var documentObserver: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUIState()
        
        document?.open(completionHandler: { (success) in
            if success {
                self.title = self.document?.localizedName
                if let imageGallery = self.document?.imageGallery {
                    self.imageGallery = imageGallery
                    self.collectionView.reloadData()
                }
                
            }
        })
    
    }
    
    // MARK: - CollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallery.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath)
        
        if let galleryCell = cell as? ImageGalleryCollectionViewCell {
            galleryCell.image = nil
            let item = imageGallery.items[indexPath.item]
            let imageURL = item.url.imageURL
            
            imageFetcher.fetch(withCachePolicy: .returnCacheDataElseLoad,
                               url: imageURL,
                        completion: { (url, image) in
                DispatchQueue.main.async {
                    galleryCell.image = image == nil ? UIImage(named: "missing") : image
                }
            })
            
        }
        return cell
    }
    
    // MARK: - CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showImageView", sender: indexPath)
    }
    
    // MARK: - CollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calculateSizeFor(itemAt: indexPath)
    }
    
    // ColloectionView flow layout
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    private func calculateSizeFor(itemAt indexPath: IndexPath) -> CGSize {
        let item = imageGallery.items[indexPath.row]
        let width = widthForCells
        return CGSize(width: width, height: width * CGFloat(item.aspectRatio))
    }
    
    
    // MARK: - CollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItem(at: indexPath)
    }

    private func dragItem(at indexPath: IndexPath) -> [UIDragItem] {
        let url = imageGallery.items[indexPath.item].url
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: url as NSItemProviderWriting))
        dragItem.localObject = url
        return [dragItem]
    }
    
    // MARK: - CollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let url = item.dragItem.localObject as? URL {
                    let aspectRatio = imageGallery.items[sourceIndexPath.item].aspectRatio
                    let galleryItem = ImageGallery.Item(url: url, aspectRatio: aspectRatio)
                    collectionView.performBatchUpdates({
                        imageGallery.items.remove(at: sourceIndexPath.item)
                        imageGallery.items.insert(galleryItem, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    }, completion: { success in
                        self.documentChanged()
                    })
                    documentChanged()
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                let placeHolderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "GalleryCell"))
                
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (url, error) in
                    if let url = url as? URL{
                        self.imageFetcher.fetch(withCachePolicy: .returnCacheDataElseLoad, url: url, completion: { (url, image) in
                            DispatchQueue.main.async {
                                var aspectRatio = Float(1.0)
                                if let image = image {
                                    aspectRatio = Float(image.size.height/image.size.width)
                                }
                                let galleryItem = ImageGallery.Item(url: url, aspectRatio: aspectRatio)
                                placeHolderContext.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
                                    self.imageGallery.items.insert(galleryItem, at: insertionIndexPath.item)
                                    self.documentChanged()
                                })
                            }
                        })
                        
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
