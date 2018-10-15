//
//  ViewController.swift
//  WhatPlant
//
//  Created by Raja Jawahar on 12/10/18.
//  Copyright © 2018 Raja Jawahar. All rights reserved.
//

import UIKit
import Vision


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
        if let userpickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            guard let convertedCIImage = CIImage(image: userpickedImage) else {
                fatalError("Cannot convert to CIImage..")
                
                
            }
            detectImage(seletedImage: convertedCIImage)
            browsedImageView.image = userpickedImage
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detectImage(seletedImage : CIImage){
        
        guard let coreMLModel = try? VNCoreMLModel(for: PlantsImageClassifier().model)else {
            print("Unable to import model")
            return
        }
        let request = VNCoreMLRequest(model: coreMLModel) { (request,error) in
            let classification = request.results?.first as? VNClassificationObservation
            self.navigationItem.title = classification?.identifier.capitalized
            
        }
        let requestOptions:[VNImageOption : Any] = [:]
        let handler = VNImageRequestHandler(ciImage:seletedImage, options: requestOptions)
        do{
            try handler.perform([request])
        }catch{
            
        }
    }
    
}

