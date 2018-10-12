//
//  ViewController.swift
//  WhatPlant
//
//  Created by Raja Jawahar on 12/10/18.
//  Copyright © 2018 Raja Jawahar. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var browsedImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
    }

    @IBAction func browseCamera(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let userpickedImage = info[UIImagePickerController.InfoKey.originalImage]
        browsedImageView.image = userpickedImage as? UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
}

