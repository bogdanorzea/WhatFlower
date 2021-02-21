//
//  ViewController.swift
//  WhatFlower
//
//  Created by Bogdan Orzea on 2/9/21.
//

import UIKit
import CoreML
import Vision

import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let imagePicker: UIImagePickerController = UIImagePickerController()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var extractLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
    }

    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let ciImage = CIImage(image: originalImage) else {
                fatalError("Could not convert image to CIImage.")
            }

            imageView.image = originalImage

            detect(flowerImage: ciImage)
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func detect(flowerImage: CIImage) {
        let config = MLModelConfiguration()
        guard let model = try? VNCoreMLModel(for: FlowerClassifier(configuration: config).model) else {
            fatalError("Loading CoreML model failed")
        }

        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("CoreML failed to process image")
            }

            if let firstResult = results.first {
                let flowerName = firstResult.identifier
                self.navigationItem.title = flowerName.capitalized

                self.fetchWikiInfoFor(flowerName)
            }
        }

        let handler = VNImageRequestHandler(ciImage: flowerImage)
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform CoreML request: \(error)")
        }
    }

    func fetchWikiInfoFor(_ titles: String) {
        let wikipediaURl = "https://en.wikipedia.org/w/api.php"

        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : titles,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize": "500"
        ]

        AF.request(wikipediaURl, method: .get, parameters: parameters)
            .responseJSON { response in
                if response.error == nil, let data = response.data {
                    guard let json = try? JSON(data: data) else {
                        print("Could not parse JSON: \(data)")
                        return
                    }

                    let pageId = json["query"]["pageids"][0].stringValue
                    let page = json["query"]["pages"][pageId]
                    let pageExtract = page["extract"].stringValue
                    let pageImage = page["thumbnail"]["source"].stringValue

                    self.imageView.sd_setImage(with: URL(string: pageImage))
                    self.extractLabel.text = pageExtract

                    debugPrint(json)
                }
            }
    }
}
