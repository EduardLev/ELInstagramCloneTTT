//
//  UserTableViewCell.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/17/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!

    var userID: String!
}
