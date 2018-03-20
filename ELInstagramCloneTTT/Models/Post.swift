//
//  Post.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/18/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit

struct Post: Codable {
    var author: String!
    var likes: Int!
    var pathToImage: String!
    var postID: String!
    var userID: String!

    var data: Data {
        return try! JSONEncoder().encode(self)
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }

    init(author: String, likes: Int, pathToImage: String, postID: String, userID: String) {
        self.author = author
        self.likes = likes
        self.pathToImage = pathToImage
        self.postID = postID
        self.userID = userID
    }
}
