//
//  UploadTakePhotoViewController.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/18/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class UploadTakePhotoViewController: UIViewController {

    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var uploadPhotoButton: UIButton!

    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Button Actions

    @IBAction func takePhotoButtonDidTouchUpInside(_ sender: UIButton) {
        showImagePickerController(action: "takePhoto")
    }

    @IBAction func uploadPhotoButtonDidTouchUpInside(_ sender: UIButton) {
        showImagePickerController(action: "photoLibrary")
    }

    func showImagePickerController(action: String) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self

        if (action == "takePhoto") {
            if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
        } else if (action == "photoLibrary") {
            if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }

    func postImageToFirebase() {
        AppDelegate.shared().showActivityIndicator()
        if let user = Auth.auth().currentUser {
            // postKey holds a reference to the post location in the database
            // storage holds a reference to the firebase storage path
            // imageReference holds a reference to the image file (named postKey.jpg)
            // in the Firebase storage path
            let postKey = Database.database().reference().child("posts").childByAutoId().key
            let storage = Storage.storage().reference(forURL: FirebaseURL.storageURL.rawValue)
            let imageReference = storage.child("posts").child(user.uid).child("\(postKey).jpg")

            if let image = self.selectedImage,
                let data = UIImageJPEGRepresentation(image, 0.5) {
                let task = imageReference.putData(data,
                                                  metadata: nil,
                                                  completion: { (metadata, error) in
                    if let error = error {
                        print (error.localizedDescription)
                        AppDelegate.shared().dismissActivityIndicator()
                        return
                    }
                    self.downloadImageFromStorage(imageReference: imageReference,
                                                  user: user,
                                                  postKey: postKey)
                })
                task.resume()
            }
        }
    }

    func downloadImageFromStorage(imageReference: StorageReference,
                                  user: User,
                                  postKey: String) {

        imageReference.downloadURL { (url, error) in
            if let error = error {
                print(error.localizedDescription)
                AppDelegate.shared().dismissActivityIndicator()
                return
            }
            if let url = url {
                let newPost = Post(author: user.displayName!,
                                   likes: 0,
                                   pathToImage: url.absoluteString,
                                   postID: postKey,
                                   userID: user.uid)
                //let newFile = [postKey : newPost.dictionary]

                user.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    if let idToken = idToken,
                         let url = URL(string:
                        "\(FirebaseURL.databaseURL.rawValue)/posts/\(postKey).json?auth=\(idToken)")
                    {
                        Alamofire.request(url,
                                          method: .put,
                                          parameters: newPost.dictionary,
                                          encoding: JSONEncoding.default,
                                          headers: nil).response(completionHandler: { (response) in
                                          })
                    }

                    if let idToken = idToken,
                        let url = URL(string:
                        "\(FirebaseURL.databaseURL.rawValue)/images/\(postKey).json?auth=\(idToken)")
                    {
                        Alamofire.request(url,
                                          method: .put,
                                          parameters: ["pathToImage": newPost.pathToImage],
                                          encoding: JSONEncoding.default,
                                          headers: nil).response(completionHandler: { (response) in
                                          })
                    }
                })
                AppDelegate.shared().dismissActivityIndicator()
            }
        }
    }
}

extension UploadTakePhotoViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage =
            info[UIImagePickerControllerEditedImage] as? UIImage {
            self.selectedImage = selectedImage
            self.postImageToFirebase()
            dismiss(animated: true, completion: nil)
        }
    }
}

extension UploadTakePhotoViewController: UINavigationControllerDelegate {

}
