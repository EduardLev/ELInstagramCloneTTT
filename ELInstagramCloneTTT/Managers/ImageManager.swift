//
//  ImageManager.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/19/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit

private let _singletonInstance = ImageManager()
private let kMaxCacheImageSize:Int = 50

class ImageManager: NSObject {
    static var shared: ImageManager { return _singletonInstance }
    var imageCache = [String : UIImage]()

    // checks the local variable for url string to see if the UIImage was already downloaded
    func cachedImageForURL(_ url: String) -> UIImage? {
        return imageCache[url]
    }

    // saves a downloaded UIImage with corresponding URL String
    func cacheImage(_ image: UIImage, forURL url: String) {
        // First check to see how many images are already saved in the cache
        // If there are more images than the max, we have to clear old images
        if imageCache.count > kMaxCacheImageSize {
            imageCache.remove(at: imageCache.startIndex)
        }
        // Adds the new image to the END of the local image Cache array
        imageCache[url] = image
    }

    func downloadImageFromURL(_ urlString: String,
                              completion: ((_ success: Bool,_ image: UIImage?,_ wasCached: Bool) -> Void)?) {

        // First, checks for cachedImage
        if let cachedImage = cachedImageForURL(urlString) {
            completion?(true, cachedImage, true)
        } else {
            guard let url = URL(string: urlString) else {
                completion?(false,nil,false)
                return
            }
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                print("downloadImageFromURL complete \(urlString)")
                if let error = error {
                    print("Error \(urlString) \(error.localizedDescription)")
                } else if let data = data, let image = UIImage(data: data) {
                    self.cacheImage(image, forURL: url.absoluteString)
                    DispatchQueue.main.async { completion?(true, image, false) }
                }
            }
            task.resume()
        }
    }

    func prefetchItem(url urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        let task = URLSession.shared.downloadTask(with: url,
                completionHandler: { (url, response, error) in
                    if error != nil {
                        print("Error \(error!.localizedDescription)")
                    } else {
                        if let url = URL(string: urlString),
                        let data = try? Data(contentsOf: url) {
                        if let image = UIImage(data: data) {
                        self.cacheImage(image, forURL: url.absoluteString)
                    }
                }
            }
            })
            task.resume()
        }
}



