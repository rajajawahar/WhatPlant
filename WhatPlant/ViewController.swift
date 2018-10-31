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
import SwiftyJSON


class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var imageInfo: UILabel!
    
    
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
            let plantname = classification?.identifier.capitalized
            self.navigationItem.title = plantname
            self.requestInfo(plantName: plantname!)
            
        }
        let requestOptions:[VNImageOption : Any] = [:]
        let handler = VNImageRequestHandler(ciImage:seletedImage, options: requestOptions)
        do{
            try handler.perform([request])
        }catch{
            
        }
    }
    
    func requestInfo(plantName: String) {
        let wikipediaURl = "https://en.wikipedia.org/w/api.php"
        let parameters : [String:String] = ["format" : "json", "action" : "query", "prop" : "extracts|pageimages", "exintro" : "", "explaintext" : "", "titles" : plantName, "redirects" : "1", "pithumbsize" : "500", "indexpageids" : ""]
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                
                                print("Success! Got the Plant data")
                let plantJSON : JSON = JSON(response.result.value!)
                
                let pageid = plantJSON["query"]["pageids"][0].stringValue
                let plantDescription = plantJSON["query"]["pages"][pageid]["extract"].stringValue
                self.imageInfo.text = plantDescription
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    
}

