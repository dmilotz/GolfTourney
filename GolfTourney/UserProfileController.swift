//
//  PlayerProfileController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/19/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


class UserProfileController: UIViewController{
    
    var player: Player?
    var games: [Game]?
    
    @IBOutlet var nameField: UILabel!
    
    @IBOutlet var handicap: UILabel!
    
    @IBOutlet var email: UILabel!
    
    var ref: FIRDatabaseReference!
    //var storageRef: FIRStorageReference!
    @IBOutlet var gamesTableView: UITableView!
    @IBOutlet var profileImage: UIImageView!
    
    @IBAction func editProfile(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileController")
        vc?.modalPresentationStyle = .overCurrentContext
        present(vc!, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        //storageRef = FIRStorage.storage().reference()
        gamesTableView.delegate = self
        gamesTableView.dataSource = self
        getUserInfo()
    }
    
    func getUserInfo(){
        FIRAuth.auth()?.currentUser?.uid
        ref.child("users/\(FIRAuth.auth()?.currentUser?.uid)").observeSingleEvent(of: .value, with:  { (snapshot) in
            if let userInfo = snapshot.value as? [String:Any]{
                
        })
        
        
        
    }
    
    
}


extension UserProfileController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let gameCount = player?.currentGames.count {
            return gameCount
        }else{
            return 0
        }

        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = gamesTableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
        return cell
        
    }
    
    
}


