//
//  CameraViewController.swift
//  Snapagram
//
//  Created by RJ Pimentel on 3/11/20.
//  Copyright © 2020 iOSDeCal. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    //var images: Images!
    var imagePickerController: UIImagePickerController!
    
    @IBOutlet weak var preImageView: UIImageView!
    @IBOutlet weak var photoChoseB: UIButton!
    @IBOutlet weak var prePost: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.images = Images()
        self.imagePickerController = UIImagePickerController()
        
        photoChoseB.backgroundColor = Constants.snapagramBlue
        photoChoseB.layer.cornerRadius = 20
        photoChoseB.layer.borderWidth = 2
        photoChoseB.layer.borderColor = UIColor.black.cgColor
        photoChoseB.titleLabel?.textAlignment = .center
        
        
        
        prePost.layer.cornerRadius = 20
        
        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .photoLibrary
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func buttonOn(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
        //present(imagePickerController, animated: true)
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePickerController.sourceType = UIImagePickerController.SourceType.camera
            //TODO: allow edit?
            //imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        //imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func prePostButtonOn(_ sender: Any) {
        performSegue(withIdentifier: "Prepost", sender: preImageView.image)
        preImageView.image = nil
        preImageView.layer.borderWidth = 0
        prePost.alpha = 0
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destiny = segue.destination as? PostViewController, let image = sender as? UIImage {
            destiny.imageToPost = image
        }
    }
    
    
}


extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            preImageView.contentMode = .scaleAspectFill
            preImageView.layer.cornerRadius = 10
            preImageView.layer.borderWidth = 2
            preImageView.layer.borderColor = UIColor.black.cgColor
            preImageView.image = image
            prePost.alpha = 1
        }
        dismiss(animated: true, completion: nil)
    }
}
