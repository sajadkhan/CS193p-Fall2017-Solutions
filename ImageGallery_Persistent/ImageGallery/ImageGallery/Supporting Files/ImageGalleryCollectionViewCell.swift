//
//  ImageGalleryCollectionViewCell.swift
//  ImageGallery
//
//  Created by Sajad on 6/26/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage? {
        didSet {
            if image == nil {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
            imageView.image = image
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
}
