//
//  SideBarController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 3/27/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import FacebookLogin


class SideBarController: UIViewController{
  
  
  //MARK: Properties
  var ref: FIRDatabaseReference!
  var player: Player?
  var games: [Game] = []
  var game: Game?
  
  @IBOutlet var profilePic: UIImageView!
  
  @IBOutlet var name: UILabel!
  
  @IBAction func currentGames(_ sender: Any) {
  }
  
  @IBAction func friendsButton(_ sender: Any) {
  }
  
  @IBAction func editProfileButton(_ sender: Any) {
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileController")
    vc?.modalPresentationStyle = .overCurrentContext
    present(vc!, animated: true, completion: nil)
  }

  @IBAction func logoutButton(_ sender: Any) {
    let firebaseAuth = FIRAuth.auth()
    do {
      try firebaseAuth?.signOut()
    } catch let signOutError as NSError {
      print ("Error signing out: %@", signOutError)
    }
    LoginManager().logOut()
    let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
    UIApplication.shared.keyWindow?.rootViewController = loginViewController
  }
  
  

  
  //MARK: Outlets
  
  override var shouldAutorotate: Bool {
    return false
  }
  
}


// MARK: - Actions
extension SideBarController{

}


// MARK: - Lifecycle
extension SideBarController{
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ref = FIRDatabase.database().reference()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(false)
    games = []
    getUserInfo()
  }
}


// MARK: - Private Methods
extension SideBarController{
  
  func setUpFields(){
    if let nameField = player?.name{
      name.text = nameField
    }else{
      name.text = "No Name Given"
    }
  }
  
  func getUserInfo(){
//    activityIndicator.startAnimating()
    let curUser = FIRAuth.auth()?.currentUser?.uid
    
    NetworkClient.getUserInfo(userId: curUser!) { (dict, error) in
      if error != nil{
        DispatchQueue.main.async {
          self.displayAlert((error?.localizedDescription)!, title: "Error")
        }
      }else{
        self.player = Player(dict: dict!)
        self.player?.uid = curUser!
        if let profileImageUrl = self.player?.profileImageUrl{
          NetworkClient.getDataFromUrl(url: NSURL(string: profileImageUrl) as! URL, completion: { (data, response, error) in
            if error != nil{
              DispatchQueue.main.async{
                self.displayAlert("Error downloading profile image", title: "Error")
                return
              }
            }
            DispatchQueue.main.async {
              self.setUpFields()
              self.profilePic.image = UIImage(data:data!)?.circle
//              self.activityIndicator.stopAnimating()
            }
          })
        }else{
          DispatchQueue.main.async{
            self.setUpFields()
            self.profilePic.image = UIImage(named:"golfDefault.png")?.circle
//            self.activityIndicator.stopAnimating()
          }
        }
        
      }
    }
  }
  
  
}
