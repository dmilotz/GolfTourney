//
//  LoginViewController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/7/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import FBSDKLoginKit

class LoginViewController: UIViewController, GIDSignInUIDelegate{
    
    // MARK: Constants
    //    let loginToList = "LoginToList"
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    @IBOutlet var facebookLogin: FBSDKLoginButton!
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookLogin.readPermissions = ["public_profile", "email"]
        facebookLogin.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        ref = FIRDatabase.database().reference()
        
        //GIDSignIn.sharedInstance().signInSilently()
        //                if FBSDKAccessToken.current().tokenString.isEmpty{
        //
        //
        //                }
        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
            if user != nil {
//                let vals = ["name": user?.displayName!, "email": user?.email!, "photoUrl": user?.photoURL!] as [String : AnyObject]
//                registerUserIntoDatabase(uid: (user?.uid)!, values: vals as [String : AnyObject])
                self.ref.child("users").child((user?.uid)!).setValue(["userName":user?.displayName])
                self.ref.child("users").child((user?.uid)!).setValue(["email":user?.email])
                self.ref.child("users/\(user?.uid)").setValue(["photo": user?.photoURL])
                self.performSegue(withIdentifier: "loginToOpeningScreen", sender: nil)
            }
            
        }
    }
    
    
    // MARK: Actions
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        FIRAuth.auth()!.signIn(withEmail: textFieldLoginEmail.text!,
                               password: textFieldLoginPassword.text!)
    }
    
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
       
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
                                        let emailField = alert.textFields![0]
                                        let passwordField = alert.textFields![1]
                                        
                                        FIRAuth.auth()!.createUser(withEmail: emailField.text!,
                                                                   password: passwordField.text!) { user, error in
                                                                    if error == nil {
                                                                        FIRAuth.auth()!.signIn(withEmail: self.textFieldLoginEmail.text!,
                                                                                               password: self.textFieldLoginPassword.text!)
                                                                    }
                                        }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    private func registerUserIntoDatabase(uid: String, values: [String: AnyObject]){
        let userRef = ref.child("users").child(uid)
        
        userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil{
                print(error)
                return
            }
        })
    }
    
}

extension LoginViewController: FBSDKLoginButtonDelegate{
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            print("FB sign in")
            if let error = error {
                print(error)
                return
            }
            else{
                //self.performSegue(withIdentifier: "loginToHome", sender: nil)
                print("Logged in with facebook")
                
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
