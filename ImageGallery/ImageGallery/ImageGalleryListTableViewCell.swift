//
//  ImageGalleryListTableViewCell.swift
//  ImageGallery
//
//  Created by Sajad on 6/26/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit

protocol ImageGalleryListTableViewCellDelegate: class {
    func imageGallerListCell(_ cell: ImageGalleryListTableViewCell, didChangeNameTo name: String)
}

class ImageGalleryListTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var viewToRecieveDoubleTap: UIView! {
        didSet {
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(enableEditing(byHandlingDoubleTap:)))
            doubleTap.numberOfTapsRequired = 2
            viewToRecieveDoubleTap.addGestureRecognizer(doubleTap)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if !selected {
            if nameTextField.isFirstResponder {
                nameTextField.resignFirstResponder()
            }
        }
    }
    
    @objc func enableEditing(byHandlingDoubleTap: UITapGestureRecognizer) {
        nameTextField.isEnabled = true
        nameTextField.becomeFirstResponder()
    }
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.delegate = self
        }
    }
    weak var delegate: ImageGalleryListTableViewCellDelegate?
    

    private func textChanged(to text: String) {
        self.nameTextField.isEnabled = false
        delegate?.imageGallerListCell(self, didChangeNameTo: text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textChanged(to: textField.text!)
    }
}
