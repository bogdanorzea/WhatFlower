//
//  ViewController.swift
//  WhatFlower
//
//  Created by Bogdan Orzea on 2/9/21.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let imagePicker: UIImagePickerController = UIImagePickerController()

    @IBOutlet weak var imageView: UIImageView!

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
                self.navigationItem.title = firstResult.identifier.capitalized
            }
        }

        let handler = VNImageRequestHandler(ciImage: flowerImage)
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform CoreML request: \(error)")
        }
    }
}
