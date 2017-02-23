//
//  GameViewController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/10/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class GameViewController: UIViewController{
    
    var ref: FIRDatabaseReference!
    
    var player: Player?
    var user: Player?
    var players: [Player] = []
    var game: Game?
    var playerIds: [String] = []
    let uid = FIRAuth.auth()?.currentUser?.uid
    @IBOutlet var buyInLabel: UILabel!
    @IBOutlet var currentPotLabel: UILabel!
    @IBOutlet var spotsLeftLabel: UILabel!
    
    @IBOutlet var gameTitleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var courseLabel: UILabel!
    @IBOutlet var playerCollectionView: UICollectionView!
    
    @IBOutlet var joinButton: UIButton!
    
    @IBAction func joinGame(_ sender: Any) {
        
        if (joinButton.titleLabel.text == "Join"){
        ref.child("games").child((game?.gameId)!).child("players").updateChildValues([String(describing: game!.players!.count) : uid!])
        if let currentGameCount = user?.currentGames!.count{
            ref.child("users").child(uid!).child("currentGames").updateChildValues([String(describing: currentGameCount): uid!])
        }else{
            ref.child("users").child(uid!).child("currentGames").updateChildValues(["0": uid!])
        }
        self.displayAlert("Game Joined!", title: "")
        //performSegue(withIdentifier: "backHome", sender: self)
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabController")
        self.present(controller!, animated: true, completion: nil)
        }else {
            ref.child("games").child((game?.gameId)!).child("players").updateChildValues([String(describing: game!.players!.count) : uid!])
            ref.child("users").child(uid!).child("currentGames").observeSingleEvent(of: .value, with: { (snapshot) in
                
            })
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabController")
            self.present(controller!, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        playerCollectionView.delegate = self
        playerCollectionView.dataSource = self
        buyInLabel.text = String(describing: game?.buyIn!)
        currentPotLabel.text = String(describing: game?.currentPot!)
        dateLabel.text = game?.date!
        courseLabel.text = game?.courseName
        gameTitleLabel.text = game?.description
        playerIds = (game?.players)!
        getPlayers()
        if didAlreadyJoin(){
            joinButton.setTitle("Leave Game", for: .normal)
        }
    }
    
    func getUserInfo(){
        NetworkClient.getUserInfo(userId: (uid)!) { (dict, error) in
            if error != nil{
                print (error)
                return
            }
            self.user = Player(dict: dict!)
        }
    }
    
    func getPlayers(){
        for playerId in playerIds{
            NetworkClient.getUserInfo(userId: playerId) { (dict, error) in
                if error != nil{
                    DispatchQueue.main.async {
                        self.displayAlert((error?.localizedDescription)!, title: "Error")
                        return
                    }
                }else{
                    self.players.append(Player(dict:dict!))
                    DispatchQueue.main.async{
                        self.playerCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func didAlreadyJoin() -> Bool{
        return playerIds.contains((uid)!)
    }
    
    
    
}
extension GameViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PlayerProfileController") as! PlayerProfileController
        controller.player = players[(indexPath as NSIndexPath).row]
        self.present(controller, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = playerCollectionView.dequeueReusableCell(withReuseIdentifier: "playerCollectionCell", for: indexPath) as! PlayerCollectionCell
        let player = players[(indexPath as NSIndexPath).row]
        if let profileUrl = player.profileImageUrl {
            NetworkClient.getDataFromUrl(url: NSURL(string: (profileUrl)) as! URL, completion: { (data, response, error) in
                if error != nil{
                    DispatchQueue.main.async{
                        self.displayAlert("Error downloading profile image", title: "Error")
                        return
                    }
                }
                DispatchQueue.main.async {
                    cell.playerImage.image = UIImage(data:data!)
                }
            })
        }else{
            cell.playerImage.image = UIImage(named:"golfDefault.png")
        }
        
        cell.handicapLabel.text = self.player?.handicap
        cell.playerName.text = self.player?.name
        
        
        return cell
        
        
        
    }
    
    
}
