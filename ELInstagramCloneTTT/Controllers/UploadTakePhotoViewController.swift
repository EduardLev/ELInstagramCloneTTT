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
        imagePicker.allowsEditing = false
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
            // imageReference HQ holds a reference to the image file (named postKey-HQ.jpg)
            // imageReference LQ holds a reference to the image file (named postKey-LQ.jpg)
            // in the Firebase storage path
            let postKey = Database.database().reference().child("posts").childByAutoId().key
            let storage = Storage.storage().reference(forURL: FirebaseURL.storageURL.rawValue)
            let imageReferenceHQ = storage.child("posts").child(user.uid).child("\(postKey)-HQ.jpg")
            let imageReferenceLQ = storage.child("posts").child(user.uid).child("\(postKey)-LQ.jpg")

            let imageData = UIImageJPEGRepresentation(self.selectedImage!, 0.5)
            let options = [
                kCGImagePropertyOrientation: UIImageOrientation.left,
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: 300] as CFDictionary
            let source = CGImageSourceCreateWithData(imageData! as CFData, nil)!
            let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
            var thumbnail = UIImage(cgImage: imageReference)

            /*if thumbnail.imageOrientation != UIImageOrientation.up {
                UIGraphicsBeginImageContextWithOptions(thumbnail.size, false, thumbnail.scale)
                thumbnail.draw(in: CGRect(x: 0, y: 0, width: thumbnail.size.width, height: thumbnail.size.height))
                let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                thumbnail = normalizedImage!
            }*/

            if let image = self.selectedImage,
                let dataLQ = UIImageJPEGRepresentation(thumbnail, 0.5),
                    let dataHQ = UIImageJPEGRepresentation(image, 0.15) {
                        dataRequestToFirebase(imageReferenceHQ: imageReferenceHQ, dataHQ: dataHQ,
                                              imageReferenceLQ: imageReferenceLQ, dataLQ: dataLQ,
                                              postKey: postKey)
            }
        }
    }

    /**
     * Creates a put data request to the image passed in.
     * - parameter imageReferenceHQ: A Firebase SDK reference to the location in storage in which
     *                       to save the data (in this case, an image)
     * - parameter dataHQ: Data holding an image or other that will be uploaded to Firebase
     */
    
    func dataRequestToFirebase(imageReferenceHQ: StorageReference, dataHQ: Data,
                               imageReferenceLQ: StorageReference, dataLQ: Data,
                               postKey: String) {
        let taskHQ = imageReferenceHQ.putData(dataHQ,metadata: nil, completion:
        { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                AppDelegate.shared().dismissActivityIndicator()
                return
            }
            let taskLQ = imageReferenceLQ.putData(dataLQ, metadata: nil, completion:
            { (metadata, error) in
                if let error = error {
                    print(error.localizedDescription)
                    AppDelegate.shared().dismissActivityIndicator()
                    return
                }
                self.createPostToFirebase(imageReferenceLQ: imageReferenceLQ,
                                          imageReferenceHQ: imageReferenceHQ,
                                          postKey: postKey)
            })
            taskLQ.resume()
        })
        taskHQ.resume()
    }

    func createPostToFirebase(imageReferenceLQ: StorageReference,
                              imageReferenceHQ: StorageReference,
                              postKey: String) {
        imageReferenceHQ.downloadURL { (HQURL, error) in
            if let error = error {
                print(error.localizedDescription)
                AppDelegate.shared().dismissActivityIndicator()
                return
            }
            imageReferenceLQ.downloadURL(completion: { (LQURL, error) in
                if let error = error {
                    print(error.localizedDescription)
                    AppDelegate.shared().dismissActivityIndicator()
                    return
                }
                if let user = Auth.auth().currentUser {
                    let newPost = Post(author: user.displayName!,
                                       likes: 0,
                                       pathToHQImage: (HQURL?.absoluteString)!,
                                       pathToLQImage: (LQURL?.absoluteString)!,
                                       postID: postKey,
                                       userID: user.uid)

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
                                              headers: nil)
                            let dict = newPost.dictionary
                            print(dict)
                        }

                        if let idToken = idToken,
                            let url = URL(string:
                                "\(FirebaseURL.databaseURL.rawValue)/images/\(postKey).json?auth=\(idToken)")
                        {
                            Alamofire.request(url,
                                              method: .put,
                                              parameters: ["order" : newPost.order,
                                                           "pathToHQImage" : (HQURL?.absoluteString),
                                                           "pathToLQImage" : (LQURL?.absoluteString),
                                                           ],
                                              encoding: JSONEncoding.default,
                                              headers: nil)
                        }
                    })
                    AppDelegate.shared().dismissActivityIndicator()
                }
            })
        }
    }
}

extension UploadTakePhotoViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage =
            info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.selectedImage = selectedImage
            self.postImageToFirebase()
            dismiss(animated: true, completion: nil)
        }
    }
}

extension UploadTakePhotoViewController: UINavigationControllerDelegate {

}
