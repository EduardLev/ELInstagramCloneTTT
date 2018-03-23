//
//  User.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/17/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit

struct LocalUser: Codable {
    var userID: String!
    var username: String!

    var data: Data {
        return try! JSONEncoder().encode(self)
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }

    init(userID: String, username: String) {
        self.userID = userID
        self.username = username
    }
}
