//
//  ViewController.swift
//  ELInstagramCloneTTT
//
//  Created by Eduard Lev on 3/17/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import Firebase

struct Constants {
    static let viewDelta:CGFloat = 80 // Sets the height with which to move up the screen
}

class LoginScreenViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var loginStackViewYAnchor: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()

        // Creates tap gesture to recognize when user clicks on screen
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTapGesture(gesture:)))
        view.addGestureRecognizer(tapGesture)

        // Hides the keychain modifier on the keyboard, available only after iOS 10
        if #available(iOS 10.0, *) {
            usernameTextField.textContentType = UITextContentType("")
            passwordTextField.textContentType = UITextContentType("")
        }
    }

    // Updates the look of text fields
    func updateUI() {
        usernameTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        passwordTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

        let spacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        usernameTextField.leftViewMode = .always
        usernameTextField.leftView = spacerView

        let spacerView2 = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        passwordTextField.leftViewMode = .always
        passwordTextField.leftView = spacerView2
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
        // Adds notifications for keyboard show/hide in order to move up the text fields
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow,
                                               object: nil, queue: nil, using: { notification in
            self.keyboardWillShow(notification: notification)
        })

        NotificationCenter.default.addObserver(forName: .UIKeyboardDidHide,
                                               object: nil, queue: nil, using: { notification in
            self.keyboardDidHide(notification: notification)
        })
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    func keyboardWillShow(notification: Notification) {
        // gets the height of the keyboard, but moves up the text fields by a constant amount
        // could eventually update so this is a function of the keyboard height
        guard let userInfo = notification.userInfo,
            let _ = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else
        { return }
        self.loginStackViewYAnchor.constant = -Constants.viewDelta
        self.loginStackView.frame.origin.y -= Constants.viewDelta
    }

    func keyboardDidHide(notification: Notification) {
        self.loginStackViewYAnchor.constant = 0
        self.loginStackView.frame.origin.y += Constants.viewDelta
    }

    // MARK: - Segue Actions
    @IBAction func unwindToLogin(unwindSegue: UIStoryboardSegue) {
    }

    // MARK: - Button Actions
    @IBAction func loginButtonDidTouchUpInside(_ sender: UIButton) {
        guard usernameTextField.text != "", passwordTextField.text != "" else { return }

        // Using Firebase Authentication to create users
        Auth.auth().signIn(withEmail: usernameTextField.text!,
                           password: passwordTextField.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }

        // Present tab bar VC, get information about the current user using Auth.auth().currentUser
            if let _ = user {
                let vc = UIStoryboard(name: "Main",
                    bundle: nil).instantiateViewController(withIdentifier: "TabBar")
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}

