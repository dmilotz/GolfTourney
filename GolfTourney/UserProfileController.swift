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
import FacebookLogin


class UserProfileController: UIViewController{
    
    var player: Player?
    var games: [Game] = []
    var game: Game?
    @IBOutlet var nameField: UILabel!
    
    @IBOutlet var handicapField: UILabel!
    
    @IBOutlet var email: UILabel!
    
    var ref: FIRDatabaseReference!
    //var storageRef: FIRStorageReference!
    @IBOutlet var gamesTableView: UITableView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func logout(_ sender: Any) {
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
    
    @IBAction func edit(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileController")
        vc?.modalPresentationStyle = .overCurrentContext
        present(vc!, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ModalTransitionMediator.instance.setListener(listener: self)
        ref = FIRDatabase.database().reference()
        //storageRef = FIRStorage.storage().reference()
        gamesTableView.delegate = self
        gamesTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        games = []
        getUserInfo()
        
    }
    
    func setUpFields(){
        if let name = player?.name{
            nameField.text = name
        }else{
            nameField.text = "No Name Given"
        }
        
        if let handicap = player?.handicap{
            handicapField.text = handicap
        }else{
            handicapField.text = "No handicap provided"
        }
        email.text = player?.email
        
//
//        profileImage.layer.cornerRadius = profileImage.frame.height/2
//        profileImage.clipsToBounds = true
    }
    
    func getUserInfo(){
        activityIndicator.startAnimating()
        let curUser = FIRAuth.auth()?.currentUser?.uid
        
        NetworkClient.getUserInfo(userId: curUser!) { (dict, error) in
            if error != nil{
                DispatchQueue.main.async {
                    self.displayAlert((error?.localizedDescription)!, title: "Error")
                }
            }else{
                self.player = Player(dict: dict!)
                self.player?.uid = curUser!
                self.getGames()
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
                            self.profileImage.image = UIImage(data:data!)?.circle
                            



                            self.activityIndicator.stopAnimating()
                            self.gamesTableView.reloadData()
                        }
                    })
                    
                }else{
                    DispatchQueue.main.async{
                    self.setUpFields()

                    self.profileImage.image = UIImage(named:"golfDefault.png")?.circle
                    self.activityIndicator.stopAnimating()
                    self.gamesTableView.reloadData()
                    }
                }
                
            }
        }
        
        
    }
    
    func getGames(){
        if let currentGameIds = player?.currentGames?.keys{
            for gameId in currentGameIds{
                NetworkClient.getGameInfo(gameId: gameId, completion: { (dict, error) in
                    if error != nil{
                        print(error)
                        return
                    }else{
                        var game = Game(dict:dict!)
                        game.gameId = gameId
                        self.games.append(game)
                        self.games.sort{$0.date! < $1.date!}
                        DispatchQueue.main.async {
                            self.gamesTableView.reloadData()
                        }
                    }
                })
            }
        }
    }
    
}

extension UserProfileController: ModalTransitionListener{
    //required delegate func
    func popoverDismissed() {
        games = []
        getUserInfo()
    }
}

extension UserProfileController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = games[(indexPath as NSIndexPath).row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        vc.game = game
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = gamesTableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
        let game = games[(indexPath as NSIndexPath).row]
        cell.buyInAmount.text = "Buy In: $\( String(describing: game.buyIn!))"
        cell.courseAddress.text = game.courseAddress
        cell.courseName.text = game.courseName
        //cell.title.text = game.description
        cell.date.text = game.date
        cell.currentPot.text = "Pot: $\(String(describing: game.currentPot!))"
        cell.playerCount.text = "Players: \(String(describing:game.players!.count))"
        
        return cell
        
    }
    
    
}


