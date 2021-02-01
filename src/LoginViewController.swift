//
//  LoginViewController.swift
//  FBLA Project 1
//
//  Created by Mason Dale on 2/6/18.
//  Copyright © 2018 Mason Dale. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    //variables
    var ref:DatabaseReference?
    
    //outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //Called when user opens view
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
    //Checks if it should allow a user directly into app
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser?.uid != nil {
            self.presentLoggedInScreen()
        }
    }
    
    //Creates new user account
    @IBAction func createAccountTapped(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            //authorize user
            Auth.auth().createUser(withEmail: email, password: password, completion: { user, error in
                
                //throw an error message if error
                if let firebaseError = error {
                    print(firebaseError.localizedDescription)
                    return
                }
                
                //adds user to the database
                let userReference = self.ref?.child("users").child((user?.uid)!)
                let values = ["email": email, "password": password, "mybooks": ""]
                
                userReference?.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error!)
                        return
                    }
                })
                
                //if no error then success
                self.presentLoggedInScreen()
            })
        }
    }
    
    //Called when user enters credentials and taps login button
    @IBAction func loginTapped(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { user, error in
                
                //throw an error message if error
                if let firebaseError = error {
                    print(firebaseError.localizedDescription)
                    return
                }
                
                //if no error then success
                self.presentLoggedInScreen()
            })
        }

    }
    
    //Called when user is authenticated during login/registration
    func presentLoggedInScreen() {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
    }

}

