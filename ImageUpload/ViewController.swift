//
//  ViewController.swift
//  ImageUpload
//
//  Created by Shivakumar Harijan on 17/06/24.
//

import UIKit
import Alamofire
import SDWebImage

let backendURL = "ApiLink"

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var transferredImage: UIImageView!
    
    @IBOutlet weak var uploadButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tappedOnUploadButton(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cancelAction)
        
        // For iPad
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            let alert = UIAlertController(title: "Source Not Available", message: "This source type is not available on your device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing  = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            uploadDocument(selectedImage)
            mainImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedOntransferButton(_ sender: UIButton) {
        displayImageFromServer()
    }
    
    func displayImageFromServer(){
        let perameters = ["mode":"displayProfilePhoto", "id":"10"]
        AF.request(backendURL, method: .post, parameters: perameters).responseDecodable(of: UploadResponse.self){ response in
            switch response.result {
            case .success(let dataa):
                print(dataa)
                let imageURL = URL(string: dataa.profilePhoto!)
                print(imageURL)
                self.transferredImage.sd_setImage(with: imageURL, placeholderImage: UIImage(systemName: "person"), options: .continueInBackground)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func uploadDocument(_ doc: UIImage) {
        let parameters: [String: Any] = ["mode": "uploadDocuments", "id":"10", "name":"Image"]
        print(parameters)
        let headers: HTTPHeaders = ["Content-type": "multipart/form-data"]
        guard let dataToUpload = doc.jpegData(compressionQuality: 0.75) else {
            print("Failed to convert image to JPEG data")
            return
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(dataToUpload, withName: "upload", fileName: "Profile.jpeg", mimeType: "image/jpeg")
            for (key, value) in parameters {
                if let valueData = (value as? String)?.data(using: .utf8) {
                    multipartFormData.append(valueData, withName: key)
                }
            }
//              multipartFormData.append(dataToUpload, withName: "upload", fileName: "Profile Image", mimeType: "image/jpeg")
            
        }, to: backendURL, method: .post, headers: headers).responseDecodable(of: UploadResponse.self) { response in
            switch response.result {
            case .success(let responseData):
                print(responseData)
            case.failure(let error):
                print(error)
            }
        }
    }
    
    struct UploadResponse: Decodable {
        let err: Int?
        let errMsg: String?
        let name: String?
        let id: String?
        let slot: String?
        let maxNum: String?
        let filePath: String?
        let mediaId: Int?
        let mediaPath: String?
        let mediaWebPath: String?
        let mediaWebsitePath: String?
        let successMsg: String?
        let derivedClass: Int?
        let profilePhoto: String?
    }
}

