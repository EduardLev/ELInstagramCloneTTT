//
//  UserViewController.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/17/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        retrieveUsers()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    func retrieveUsers() {
        let database = Database.database().reference()

        self.users.removeAll()
        database.child("users").queryOrderedByKey().observeSingleEvent(of: .value)
        { (snapshot) in
            let users = snapshot.value as! [String : AnyObject]
            for (_, value) in users {
                if let userID = value["uid"] as? String {
                    if userID != Auth.auth().currentUser!.uid {
                        //let userToShow = User()
                        if let username = value["username"] as? String {
                            //userToShow.username = username
                            //userToShow.userID = userID
                            //self.users.append(userToShow)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
        database.removeAllObservers()
    }
}

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell",
                                                 for: indexPath) as! UserTableViewCell

        //cell.userNameLabel.text = users[indexPath.row].username
        //cell.userID = users[indexPath.row].userID
        //cell.userImageView.downloadImage(from: users[indexPath.row].imagePath!)
        checkFollowing(indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userID = Auth.auth().currentUser!.uid
        let database = Database.database().reference()
        let key = database.child("users").childByAutoId().key
        var isFollower = false
        /*
        database.child("users").child(userID).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let following = snapshot.value as? [String : AnyObject] {
                for (key, value) in following {
                    if value as! String == self.users[indexPath.row].userID {
                        isFollower = true
                        database.child("users").child(userID).child("following/\(key)").removeValue()
                        database.child("users").child(self.users[indexPath.row].userID).child("followers/\(key)").removeValue()
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }

            if !isFollower {
                let following = ["following/\(key)" : self.users[indexPath.row].userID]
                let followers = ["followers/\(key)" : userID]
                database.child("users").child(userID).updateChildValues(following)
                database.child("users").child(self.users[indexPath.row].userID).updateChildValues(followers)
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        })
        database.removeAllObservers()*/
    }

    func checkFollowing(indexPath: IndexPath) {
        let userID = Auth.auth().currentUser!.uid
        let database = Database.database().reference()
/*
        database.child("users").child(userID).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let following = snapshot.value as? [String : AnyObject] {
                for (key, value) in following {
                    if value as! String == self.users[indexPath.row].userID {
                        print("this is happening")
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        })
        database.removeAllObservers()*/
    }
}

extension UIImageView {

    func downloadImage(from imageURL: String!) {
        let url = URLRequest(url: URL(string: imageURL)!)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription)
            }

            if let data = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }
        }
        task.resume()
    }



}
