//
//  imagePost.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/22/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import Foundation

struct imagePost: Decodable {
    var order: Double!
    var pathToHQImage: String!
    var pathToLQImage: String!
}
