//
//  User.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/17/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit

struct User: Codable {
    var userID: String!
    var username: String!
    var email: String!

    init(userID: String, username: String, email: String) {
        self.userID = userID
        self.username = username
        self.email = email
    }
}
