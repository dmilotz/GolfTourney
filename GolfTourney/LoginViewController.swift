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
  //MARK: Properties
  
  var ref: FIRDatabaseReference!
  
  // MARK: Outlets
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  @IBOutlet var facebookLogin: FBSDKLoginButton!
  
}


// MARK: Actions
extension LoginViewController{
  
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
}


// MARK : Lifecycle
extension LoginViewController{
  override func viewDidLoad() {
    super.viewDidLoad()
    facebookLogin.readPermissions = ["public_profile", "email"]
    facebookLogin.delegate = self
    GIDSignIn.sharedInstance().uiDelegate = self
    ref = FIRDatabase.database().reference()
    FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
      if user != nil {
        NetworkClient.checkUserExists(uid: (user?.uid)!, completion: { (userExists, error) in
          if error == nil{
            if !userExists!{
              var vals = ["userName": user?.displayName, "email": user?.email] as [String : Any]
              if let photoUrl = user?.photoURL{
                vals["profileImage"] = photoUrl.absoluteString
              }
              self.ref.child("users").child((user?.uid)!).updateChildValues(vals)
            }
            DispatchQueue.main.async{
              self.performSegue(withIdentifier: "TabController", sender: nil)
              
            }
          }
          
        })
        
      }
    }
  }
}


//MARK: private methods

private extension LoginViewController{
  func registerUserIntoDatabase(uid: String, values: [String: AnyObject]){
    let userRef = ref.child("users").child(uid)
    
    userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
      if error != nil{
        print(error)
        return
      }
    })
  }
  
}


// MARK: - FBSDKLoginButtonDelegate
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


// MARK: - UITextFieldDelegate
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
