//
//  PostViewController.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/20/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class PostViewController: UIViewController {

    var post:Post!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    var likes:Int = 0
    var likedByUser: Bool = false
    var comments: [[String]] = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        likes = post.likes
        updateLikesLabel()
        updateUI()

        self.commentField.delegate = self
        addObservers()
    }

    func addObservers() {
        // Adds notifications for keyboard show/hide in order to move up the text fields
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow,
                                               object: nil, queue: nil, using: { notification in
                                                self.keyboardWillShow(notification: notification)
        })

        NotificationCenter.default.addObserver(forName: .UIKeyboardDidHide,
                                               object: nil, queue: nil, using: { notification in
                                                self.keyboardDidHide(notification: notification)
        })
    }

    func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let deltaY = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else
        { return }
        self.commentView.translatesAutoresizingMaskIntoConstraints = true
            self.commentView.frame.origin.y -= deltaY.size.height
    }

    func keyboardDidHide(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        self.commentView.frame.origin.y =
            self.view.frame.size.height - self.commentView.frame.size.height
    }

    func updateLikesLabel() {
        likesLabel.text = String(self.likes) + " " + "Likes"
        if let user = Auth.auth().currentUser {
            if post.likedBy.contains(user.uid) {
                self.heartButton.setImage(UIImage(named: "icn_like_active_optimized"),
                                          for: .normal)
                likedByUser = true
            } else {
                self.heartButton.setImage(UIImage(named: "icn_like_inactive_optimized"),
                                          for: .normal)
                likedByUser = false
            }
        }
    }


    @IBAction func sendButtonDidClick(_ sender: UIButton) {
        if let user = Auth.auth().currentUser,
         let text = commentField.text {
            commentField.resignFirstResponder()
            comments.append([user.displayName!,text])
            print(comments)
            self.tableView.reloadData()
        }

        self.updatePostToFirebase()
    }

    func updateUI() {
        // Need to update likes, image, and comments
        updateImage()
    }

    func updateImage() {
        guard let url = URL(string: post.pathToHQImage) else { return }
        let task = Alamofire.request(url).response { (response) in
            print(response)
            if let data = response.data {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                }
            }
        }
        task.resume()
    }

    @IBAction func hitCommentButton(_ sender: UIButton) {
        self.commentField.becomeFirstResponder()
    }

    @IBAction func hitLikesButton(_ sender:UIButton) {
        if let user = Auth.auth().currentUser {
            if !likedByUser {
                post.likedBy.append(user.uid)
                likedByUser = true
                self.likes += 1
            } else {
                post.likedBy.removeLast()
                likedByUser = false
                self.likes -= 1
            }
            updateLikesLabel()
        }

        self.updatePostToFirebase()
    }

    func updatePostToFirebase() {

        // networking code

    }

    func deletePostOnFirebase() {
        if let user = Auth.auth().currentUser {
            // first check if this post was made by another user
            guard user.uid == post.userID else { return }

            user.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let idToken = idToken {
                    let postString = "\(FirebaseURL.databaseURL.rawValue)/posts/\(self.post.postID!).json?auth=\(idToken)"
                    if let url = URL(string: postString) {
                        if let urlRequest = try? URLRequest(url: url, method: .delete) {
                            Alamofire.request(urlRequest)
                        }
                    }
                    let imageString = "\(FirebaseURL.databaseURL.rawValue)/images/\(self.post.postID!).json?auth=\(idToken)"
                    if let url = URL(string: imageString) {
                        if let urlRequest = try? URLRequest(url: url, method: .delete) {
                            Alamofire.request(urlRequest)
                        }
                    }
                    let storage = Storage.storage().reference(forURL: FirebaseURL.storageURL.rawValue)
                    let imageReferenceHQ = storage.child("posts").child(user.uid).child("\(self.post.postID!)-HQ.jpg")
                    let imageReferenceLQ = storage.child("posts").child(user.uid).child("\(self.post.postID!)-LQ.jpg")
                    imageReferenceHQ.delete(completion: { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    })

                    imageReferenceLQ.delete(completion: { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    })

                }
            })
            //let storage = Storage.storage().reference(forURL: FirebaseURL.storageURL.rawValue)
        }
        self.navigationController?.popViewController(animated: true)
    }

    func deletePost() {
        self.deletePostOnFirebase()
        // code here
    }

    @IBAction func moreButton(_ sender: UIButton) {
        let alert = UIAlertController()
        let deleteAction = UIAlertAction(title: "Delete Post",
                                         style: UIAlertActionStyle.default) { (action) in
            self.deletePost()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        alert.view.tintColor = .red
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }

}

extension PostViewController : UITableViewDelegate {

}

extension PostViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // This code counts the total number of values (comments) in the comments dictionary
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        cell.textLabel?.text = comments[indexPath.row][0]
        cell.detailTextLabel?.text = comments[indexPath.row][1]
        return cell
    }
}

extension PostViewController : UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let _ = textField.text {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
}
