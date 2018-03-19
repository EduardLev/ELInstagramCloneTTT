//
//  UploadTakePhotoViewController.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/18/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import Firebase

class UploadTakePhotoViewController: UIViewController {

    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var uploadPhotoButton: UIButton!

    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Button Actions

    @IBAction func takePhotoButtonDidTouchUpInside(_ sender: UIButton) {

    }

    @IBAction func uploadPhotoButtonDidTouchUpInside(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    func postImage() {
        AppDelegate.shared().showActivityIndicator()

        let userID = Auth.auth().currentUser?.uid
        let database = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://elinstagramclonettt.appspot.com")
        let key = database.child("posts").childByAutoId().key
        let imageReference = storage.child("posts").child(userID!).child("\(key).jpg")

        let data = UIImageJPEGRepresentation(self.selectedImage!, 0.5)
        let task = imageReference.putData(data!, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error?.localizedDescription)
                AppDelegate.shared().dismissActivityIndicator()
                return
            }
            imageReference.downloadURL(completion: { (url, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    AppDelegate.shared().dismissActivityIndicator()
                    return
                }
                if let url = url {
                    let feed = ["userID" : userID,
                                "pathToImage" : url.absoluteString,
                                "likes" : 0,
                                "author" : Auth.auth().currentUser?.displayName!,
                                "postID" : key,] as [String : Any]
                    let postFeed = ["\(key)" : feed]
                    database.child("posts").updateChildValues(postFeed)
                    AppDelegate.shared().dismissActivityIndicator()
                }
            })
            }
        task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension UploadTakePhotoViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        print("this is happening")
        if let selectedImage =
            info[UIImagePickerControllerEditedImage] as? UIImage {
            self.selectedImage = selectedImage
            self.postImage()
            dismiss(animated: true, completion: nil)
        }
    }
}

extension UploadTakePhotoViewController: UINavigationControllerDelegate {

}
