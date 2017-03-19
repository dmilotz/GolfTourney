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
  
  //MARK: Properties
  var ref: FIRDatabaseReference!
  var player: Player?
  var user: Player?
  var players: [Player] = []
  var game: Game?
  var playerIds: [String] = []
  let uid = FIRAuth.auth()?.currentUser?.uid
  
  //MARK: Outlets
  @IBOutlet var buyInLabel: UILabel!
  @IBOutlet var currentPotLabel: UILabel!
  @IBOutlet var spotsLeftLabel: UILabel!
  @IBOutlet var gameTitleLabel: UILabel!
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var courseLabel: UILabel!
  @IBOutlet var playerCollectionView: UICollectionView!
  @IBOutlet var joinButton: UIBarButtonItem!
  
 
  
  override var shouldAutorotate: Bool {
    return false
  }
  
}


// MARK: - Actions
extension GameViewController{
  @IBAction func joinGame(_ sender: Any) {
    joinGame()
  }
  
  @IBAction func cancel(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func goToChat(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier :"chatViewController") as! ChatViewController
    vc.game = game
    self.present(vc, animated: true)
  }
  
}

// MARK: - Lifecycle
extension GameViewController{
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ref = FIRDatabase.database().reference()
    
    playerCollectionView.delegate = self
    playerCollectionView.dataSource = self
    buyInLabel.text = "Buy In: $\(String(describing: game!.buyIn!)) "
    currentPotLabel.text = "Pot: $\(String(describing: game!.currentPot! * game!.players!.count))"
    dateLabel.text = game?.date!
    courseLabel.text = game?.courseName
    gameTitleLabel.text = game?.description
    if let keys = game?.players?.keys{
      playerIds = Array(keys)
    }
    
    getPlayers()
    
    joinButton.title = "Join"
    if isGameOwner(){
      joinButton.title = "Cancel Game"
      
    }else if didAlreadyJoin(){
      joinButton.title = "Leave Game"
    }
  }
}


// MARK: - Private methods
private extension GameViewController{
  
  func didAlreadyJoin() -> Bool{
    return playerIds.contains((uid)!)
  }
  
  func isGameOwner() -> Bool{
    return game!.gameOwner == uid
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
  
  //MARK: Functionality for join button
  func joinGame(){
    if (joinButton.title == "Join"){
      ref.child("games").child((game?.gameId)!).child("players").child(uid!).setValue("")
      ref.child("users").child(uid!).child("currentGames").child((game?.gameId)!).setValue(game?.courseName)
      self.displayAlert("Game Joined!", title: "")
      let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabController")
      self.present(controller!, animated: true, completion: nil)
    }else if (joinButton.title == "Leave Game")  {
      NetworkClient.leaveGame(gameId: (game?.gameId)!, completion: { (message, error) in
        print(message)
      })
      let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabController")
      self.present(controller!, animated: true, completion: nil)
    }else{
      let deleteAlert = UIAlertController(title: "Cancel Game?", message: "Are you sure you want to cancel the game?", preferredStyle: UIAlertControllerStyle.alert)
      deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        NetworkClient.cancelGame(game:self.game!)
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabController")
        self.present(controller!, animated: true, completion: nil)}))
      deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        return            }))
      self.present(deleteAlert, animated: true, completion: nil)
    }
  }
}


// MARK: - UICollectionViewDelegate
extension GameViewController: UICollectionViewDelegate{
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let controller = self.storyboard?.instantiateViewController(withIdentifier: "PlayerProfileController") as! PlayerProfileController
    controller.player = players[(indexPath as NSIndexPath).row]
    self.present(controller, animated: true, completion: nil)
  }
}


// MARK: - UICollectionViewDataSource
extension GameViewController: UICollectionViewDataSource{
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
          cell.playerImage.image = UIImage(data:data!)?.circle
        }
      })
    }else{
      cell.playerImage.image = UIImage(named:"golfDefault.png")?.circle
    }
    cell.handicapLabel.text = "Handicap: \(player.handicap!)"
    cell.playerName.text = player.name
    return cell
  }
}

