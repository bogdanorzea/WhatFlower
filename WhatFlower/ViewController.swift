//
//  ViewController.swift
//  WhatFlower
//
//  Created by Bogdan Orzea on 2/9/21.
//

import UIKit

class ViewController: UIViewController {
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
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = originalImage
        }

        picker.dismiss(animated: true, completion: nil)
    }
}
