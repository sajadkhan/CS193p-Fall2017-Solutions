//
//  ImageViewController.swift
//  Cassini
//
//  Created by jamfly on 2018/1/7.
//  Copyright © 2018年 jamfly. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    var imageURL: URL? {
        didSet {
            image = nil
            // check if on screen
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    private var imageFetcher = ImageFetcher()
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            spinner?.stopAnimating()
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if imageView.image == nil {
            fetchImage()
        }
    }
    
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 1 / 25
            scrollView.maximumZoomScale = 1.0
            scrollView.delegate = self
            scrollView.addSubview(imageView)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    var imageView = UIImageView()
    
    
    private func fetchImage() {
        if let url = imageURL {
            imageFetcher.fetch(url) { (url, image) in
                DispatchQueue.main.async {
                    if let image = image {
                        self.image = image
                    }
                }
                
            }
        }
        
    }
    
   
    
    
    
    
}





