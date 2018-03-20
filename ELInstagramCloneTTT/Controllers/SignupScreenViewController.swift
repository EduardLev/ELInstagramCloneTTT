//
//  SIgnupScreenViewController.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/17/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class SignupScreenViewController: UIViewController {

    // MARK: - Properties and Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var createUserButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    var userStorage: StorageReference!
    var database: DatabaseReference!

    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()

        // Creates tap gesture to recognize when user clicks on screen
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTapGesture(gesture:)))
        view.addGestureRecognizer(tapGesture)

        let storage = Storage.storage().reference(forURL: "gs://elinstagramclonettt.appspot.com")
        userStorage = storage.child("users") // Storage plus the folder "users"
        database = Database.database().reference()
    }

    func updateUI() {
        // Updates background color of text fields to translucent light gray
        usernameTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        emailTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        passwordTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        confirmPasswordTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

        // Adds small indent to left side of text fields
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        usernameTextField.leftViewMode = .always
        usernameTextField.leftView = spacerView

        let spacerView2 = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        emailTextField.leftViewMode = .always
        emailTextField.leftView = spacerView2

        let spacerView3 = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        passwordTextField.leftViewMode = .always
        passwordTextField.leftView = spacerView3

        let spacerView4 = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        confirmPasswordTextField.leftViewMode = .always
        confirmPasswordTextField.leftView = spacerView4
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObservers()
    }

    // MARK: - Observers and Gestures

    @objc func handleTapGesture(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    func addObservers() {
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow,
                                               object: nil, queue: nil,
                                               using: { notification in
            self.keyboardWillShow(notification: notification)
        })

        NotificationCenter.default.addObserver(forName: .UIKeyboardDidHide,
                                               object: nil,
                                               queue: nil,
                                               using: { notification in
            self.keyboardDidHide(notification: notification)
        })
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else
            { return }
        let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: frame.height, right: 0.0)
        scrollView.contentInset = contentInset
    }

    func keyboardDidHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }

    // MARK: - Button Actions

    @IBAction func createUserButtonDidTouchUpInside(_ sender: UIButton) {
        guard usernameTextField.text != "", emailTextField.text != "",
              passwordTextField.text != "", confirmPasswordTextField.text != ""
            else { return }

        if passwordTextField.text == confirmPasswordTextField.text {
            Auth.auth().createUser(withEmail: emailTextField.text!,
                                   password: passwordTextField.text!,
                                   completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let user = user {
                self.updateUserDisplayName()
                self.putUserToFirebase(user: user)

                let vc = UIStoryboard(name: "Main",
                    bundle:nil).instantiateViewController(withIdentifier:"TabBar")
                self.present(vc, animated: true, completion: nil)
                }
            })
        }
    }

    func updateUserDisplayName() {
        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
            changeRequest.displayName = self.usernameTextField.text!
            changeRequest.commitChanges(completion: nil)
        }
    }

    func putUserToFirebase(user: User) {
        // Gets the Firebase authentication ID Token required to send requests through Alamofire
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error.localizedDescription)
                return;
            }
            let newUser = LocalUser(userID: user.uid,
                                    username: self.usernameTextField.text!)
            if let idToken = idToken,
                let url = URL(string:
                    "\(FirebaseURL.databaseURL.rawValue)/users/\(user.uid).json?auth=\(idToken)") {
                Alamofire.request(url,
                                  method: HTTPMethod.put,
                                  parameters: newUser.dictionary,
                                  encoding: JSONEncoding.default,
                                  headers: nil).response(completionHandler: { (response) in
                                    print(response.response)
                                  })
            }
        }
    }

    // MARK: - Text Field Actions
    @IBAction func confirmPasswordEditingDidEnd(_ sender: UITextField) {
        guard let password = passwordTextField.text else { return }
        guard let confirmPassword = confirmPasswordTextField.text else {
            return }

        if (password != confirmPassword) {
            print("The confirm password you entered does not match existing")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation
     // before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
