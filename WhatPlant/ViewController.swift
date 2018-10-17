//
//  ViewController.swift
//  WhatPlant
//
//  Created by Raja Jawahar on 12/10/18.
//  Copyright © 2018 Raja Jawahar. All rights reserved.
//

import UIKit
import Vision
import Alamofire


class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"

    
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
    
    func requestInfo(flowerName: String) {
        let parameters : [String:String] = ["format" : "json", "action" : "query", "prop" : "extracts|pageimages", "exintro" : "", "explaintext" : "", "titles" : flowerName, "redirects" : "1", "pithumbsize" : "500", "indexpageids" : ""]
        
        
        // https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts|pageimages&exintro=&explaintext=&titles=barberton%20daisy&redirects=1&pithumbsize=500&indexpageids
        
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                //                print(response.request)
                //
                //                print("Success! Got the flower data")
                let flowerJSON : JSON = JSON(response.result.value!)
                
                let pageid = flowerJSON["query"]["pageids"][0].stringValue
                
                let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
                let flowerImageURL = flowerJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                
                //                print("pageid \(pageid)")
                //                print("flower Descript \(flowerDescription)")
                //                print(flowerJSON)
                //
                self.infoLabel.text = flowerDescription
                
                
                
                
                self.imageView.sd_setImage(with: URL(string: flowerImageURL), completed: { (image, error,  cache, url) in
                    
                    if let currentImage = self.imageView.image {
                        
                        guard let dominantColor = ColorThief.getColor(from: currentImage) else {
                            fatalError("Can't get dominant color")
                        }
                        
                        
                        DispatchQueue.main.async {
                            self.navigationController?.navigationBar.isTranslucent = true
                            self.navigationController?.navigationBar.barTintColor = dominantColor.makeUIColor()
                            
                            
                        }
                    } else {
                        self.imageView.image = self.pickedImage
                        self.infoLabel.text = "Could not get information on flower from Wikipedia."
                    }
                    
                })
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.infoLabel.text = "Connection Issues"
                
                
                
            }
        }
    }
    
    
}

