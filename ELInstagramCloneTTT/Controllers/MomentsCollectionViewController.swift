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

struct imagePost: Decodable {
    var pathToImage: String!
}

private let reuseIdentifier = "momentCell"

class MomentsCollectionViewController: UICollectionViewController {

    var posts: [Post]!

    // This will hold a local copy of a dictionary where keys are the postID's
    // and the values are imagePost structs, which hold the paths to the images
    var images: [String : imagePost]!
    var imageURLS: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadImageURLS()
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
                                  headers: nil).response(completionHandler: { (response) in
                                        //print(response.response) - debug
                                        if response.response?.statusCode == 200 {
                                            if let data = response.data {
                                                self.images = try! JSONDecoder().decode([String :
                                                    imagePost].self, from: data)
                                                //print(self.images) - debug
                                                for item in self.images {
                                                    self.imageURLS.append(item.value.pathToImage)
                                                    //print(self.imageURLS) - debug
                                                }
                                                //print(self.imageURLS) - debug
                                            }
                                            self.collectionView?.reloadData()
                                        }
                                      })
            }
        }
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
                                                      for: indexPath)        
        cell.backgroundColor = .black

        updateImageForCell(cell: cell,
                           inCollectionView: collectionView,
                           withImageURL: imageURLS[indexPath.row],
                           atIndexPath: indexPath)
        return cell
    }

    func updateImageForCell(cell: UICollectionViewCell,
                            inCollectionView collectionView: UICollectionView,
                            withImageURL: String,
                            atIndexPath indexPath: IndexPath) {
        // clean image first
        let imageView = cell.viewWithTag(1) as! UIImageView // gets the first view in the hierarchy
        imageView.image = UIImage(named: "placeholder")

        // load image.
        let imageURL = self.imageURLS[indexPath.row]
        //print(imageURL) - debug

        ImageManager.shared.downloadImageFromURL(imageURL) {
            (success, image) -> Void in
            if success && image != nil {
                // checks that the view did not move before setting the image to the cell!
                if collectionView.indexPath(for: cell)?.row == indexPath.row {
                    imageView.image = image
                }
            }
        }
    }

    // MARK: - Lazy Loading of cells

    func loadImagesForOnScreenRows() {
        if imageURLS.count > 0 {
            if let visiblePaths = collectionView?.indexPathsForVisibleItems {
                for indexPath in visiblePaths {
                    let cell = collectionView(self.collectionView!, cellForItemAt: indexPath)
                    let imageURL = imageURLS[indexPath.row]
                    self.updateImageForCell(cell: cell,
                                            inCollectionView: self.collectionView!,
                                            withImageURL: imageURL,
                                            atIndexPath: indexPath)
                }
            }
        }
    }

    // MARK: UICollectionViewDelegate

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnScreenRows()
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                           willDecelerate decelerate: Bool) {
        if !decelerate { loadImagesForOnScreenRows() }
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView,
     shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView,
     shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed
     // for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView,
     shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView,
     canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView,
     performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
}

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

