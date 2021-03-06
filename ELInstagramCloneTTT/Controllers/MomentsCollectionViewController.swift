//
//  MomentsCollectionViewController.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/17/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import AFNetworking

private let reuseIdentifier = "momentCell"

class MomentsCollectionViewController: UICollectionViewController {

    var posts: [String : Post]!
    var actualPosts: [Post]!
    var orderedPosts: [Post]!

    // This will hold a local copy of a dictionary where keys are the postID's
    // and the values are imagePost structs, which hold the paths to the images
    var images: [String : imagePost]!
    var actualImages: [imagePost] = []
    var imageURLS: [String] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            let title = NSLocalizedString("Pull To Refresh", comment: "Pull To Refresh")
            refreshControl.attributedTitle = NSAttributedString(string: title)
            refreshControl.addTarget(self,
                                     action: #selector(refreshOptions(sender:)),
                                     for: .valueChanged)
            self.collectionView?.refreshControl = refreshControl
        }

    AppDelegate.shared().showActivityIndicator()
    self.downloadImageURLS()
    }

    @objc private func refreshOptions(sender: UIRefreshControl) {
        self.downloadImageURLS()
        AppDelegate.shared().showActivityIndicator()
        sender.endRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.downloadImageURLS()
    }

    func downloadImageURLS() {
        if let user = Auth.auth().currentUser {
            // Gets the Firebase authentication ID Token required to send requests through Alamofire
            user.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error {
                    print(error.localizedDescription)
                    return;
                }
                guard let idToken = idToken else { return }
                guard let url = URL(string:
                    "\(FirebaseURL.databaseURL.rawValue)/images.json?auth=\(idToken)") else {
                        return
                }
                Alamofire.request(url, method: .get, parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: nil).response(completionHandler: { [unowned self](response) in
                                        if response.response?.statusCode == 200 {
                                            if let data = response.data {
                                                self.images = nil
                                                self.imageURLS = []
                                                self.actualImages = []
                                                self.images = try? JSONDecoder().decode([String :
                                                    imagePost].self, from: data)
                                                guard let images = self.images else {return}
                                                for item in images {
                                                  self.actualImages.append(item.value)
                                                }
                                                self.actualImages.sort(by: { (post1, post2) -> Bool in
                                                    post1.order > post2.order
                                                })
                                                for item in self.actualImages {
                                                    self.imageURLS.append(item.pathToLQImage)
                                                }
                                            }
                                            self.collectionView?.reloadData()
                                            AppDelegate.shared().dismissActivityIndicator()
                                        }
                                      })
            }
        }
    }

    @IBAction func logoutButtonDidClick(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginVC")
        present(vc!, animated: true) {
        }
    }

    func getPosts(indexPath: IndexPath) {
        if let user = Auth.auth().currentUser {
            // Gets the Firebase authentication ID Token required to send requests through Alamofire
            user.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error {
                    print(error.localizedDescription)
                    return;
                }
                guard let idToken = idToken else { return }
                guard let url = URL(string:
                    "\(FirebaseURL.databaseURL.rawValue)/posts.json?auth=\(idToken)") else {
                        return
                }
                Alamofire.request(url, method: .get, parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: nil).response(completionHandler: { (response) in
                                    if response.response?.statusCode == 200 {
                                        if let data = response.data {
                                            self.actualPosts = []
                                            self.posts = [:]
                                            self.posts = try? JSONDecoder().decode([String :
                                                Post].self, from: data)
                                        }
                                        guard let posts = self.posts else {return}
                                            for post in posts {
                                                self.actualPosts.append(post.value)
                                            }
                                        self.actualPosts.sort(by: { (post1, post2) -> Bool in
                                            post1.order > post2.order
                                        })
                                        self.showSelectedPost(indexPath: indexPath)
                                    }
                                  })
            }
        }
    }

    func showSelectedPost(indexPath: IndexPath) {
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier:
            "PostVC") as! PostViewController
        postViewController.post = self.actualPosts[indexPath.row]
        self.navigationController?.pushViewController(postViewController, animated: true)
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // only one section in this app
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        guard let images = images else { return 0 }
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! MomentsCell
        let imageURL = imageURLS[indexPath.row]
        self.updateImageForCell(cell: cell,
                                inCollectionView: collectionView,
                                withImageURL: imageURL,
                                atIndexPath: indexPath)
        return cell
    }

    func updateImageForCell(cell: MomentsCell,
                            inCollectionView collectionView: UICollectionView,
                            withImageURL: String,
                            atIndexPath indexPath: IndexPath) {
        /*if let url = URL(string: withImageURL) {
            cell.imageView.setImageWith(url, placeholderImage: UIImage(named: "placeholder"))
        }*/
         cell.imageView.image = UIImage(named: "placeholder")
         ImageManager.shared.downloadImageFromURL(withImageURL) {
            (success, image, wasCached) -> Void in
            if success && image != nil {
                // checks that the view did not move before setting the image to the cell!
                if wasCached || collectionView.cellForItem(at: indexPath) == cell {
                    cell.imageView.image = image
                }
            }
         }
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        getPosts(indexPath: indexPath)
    }
}

/*extension MomentsCollectionViewController : UICollectionViewDataSourcePrefetching {

    /*func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath)
            let imageURL = imageURLS[indexPath.row]
            ImageManager.shared.prefetchItem(url: imageURL)
        }
    }*/
}*/

extension MomentsCollectionViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Three images per row
        let side = self.view.frame.size.width/3
        return CGSize(width: side, height: side)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        // No spacing between images
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0 // Minimum space between images
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // Space between rows in the collection View
    }
}




