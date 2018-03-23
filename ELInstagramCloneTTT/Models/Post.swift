//
//  Post.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/18/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import Firebase

struct Post: Codable {
    var author: String!
    var likes: Int!
    var likedBy: [String] = [""]
    var pathToHQImage: String
    var pathToLQImage: String
    var postID: String!
    var userID: String!
    var order: Double!
    var comments: [[String]] = [[""]]
    
    var data: Data {
        return try! JSONEncoder().encode(self)
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }

    init(author: String,
         likes: Int,
         pathToHQImage: String,
         pathToLQImage: String,
         postID: String,
         userID: String) {
        self.author = author
        self.likes = likes
        self.pathToHQImage = pathToHQImage
        self.pathToLQImage = pathToLQImage
        self.postID = postID
        self.userID = userID
        self.order = Date.init().timeIntervalSince1970
    }
}
