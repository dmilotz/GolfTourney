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


class PlayerProfileController: UIViewController{
  
  
  //MARK: Properties
  var ref: FIRDatabaseReference!
  var player: Player?
  var games: [Game] = []
  var game: Game?
  var gameIds: [String]{
    if let keysAsGameIds = player?.currentGames?.keys{
      return Array(keysAsGameIds)
    }else{
      return []
    }
  }
  
  //MARK: Outlets
  
  @IBOutlet var nameField: UILabel!
  @IBOutlet var handicapField: UILabel!
  @IBOutlet var gamesTableView: UITableView!
  @IBOutlet var profileImage: UIImageView!
  

  //MARK: Actions
  
  @IBAction func back(_ sender: Any) {
  dismiss(animated: true, completion: nil)
  }
}

// MARK: Lifecycle

extension PlayerProfileController{
  override func viewDidLoad() {
    
    super.viewDidLoad()
    ref = FIRDatabase.database().reference()
    //storageRef = FIRStorage.storage().reference()
    gamesTableView.delegate = self
    gamesTableView.dataSource = self
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(false)
    getUserInfo()
    getGames()
    setUpFields()
  }
}

// MARK: Private methods

private extension PlayerProfileController{
  
  func setUpFields(){
    if let name = player?.name{
      nameField.text = name
    }else{
      nameField.text = "No name provided"
    }
    
    if let handicap = player?.handicap{
      handicapField.text = "Handicap: \(handicap)"
    }else{
      handicapField.text = "No handicap provided"
    }
  }
  
  func getUserInfo(){
    if let profileImageUrl = self.player?.profileImageUrl{
      print("ProfileUrl \(profileImageUrl)")
      NetworkClient.getDataFromUrl(url: NSURL(string: profileImageUrl) as! URL, completion: { (data, response, error) in
        if error != nil{
          DispatchQueue.main.async{
            self.displayAlert("Error downloading profile image", title: "Error")
            return
          }
        }
        DispatchQueue.main.async {
          self.profileImage.image = UIImage(data:data!)
        }
      })
      
    }else{
      self.profileImage.image = UIImage(named:"golfDefault.png")?.circle
    }
  }
  
  func getGames(){
    for gameId in gameIds{
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



//MARK: TableView Delegate

extension PlayerProfileController: UITableViewDelegate{
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let game = games[(indexPath as NSIndexPath).row]
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
    vc.game = game
    self.present(vc, animated: true, completion: nil)
  }
  
}

//MARK: TableView Datasource

extension PlayerProfileController: UITableViewDataSource{
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return games.count
    
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = gamesTableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
    let game = games[(indexPath as NSIndexPath).row]
    self.game = game
    
    //                    cell.buyInAmount.text = String(describing: chosenGame.buyIn!)
    //                    cell.courseAddress.text = chosenGame.courseAddress
    //                    cell.courseName.text = chosenGame.courseName
    //                    cell.date.text = chosenGame.date
    //                    cell.currentPot.text = String(describing: chosenGame.currentPot!)
//    cell.buyInAmount.text = "Buy In: $\( String(describing: game.buyIn!))"
//    cell.courseAddress.text = game.courseAddress
//    cell.courseName.text = game.courseName
//    cell.date.text = game.date
//    cell.currentPot.text = "Pot: $\(String(describing: game.currentPot!))"
//    cell.playerCount.text = "Players: \(String(describing:game.players!.count))"
    
    cell.title.text = game.description
    cell.buyInAmount.text = "Buy In: $\( String(describing: game.buyIn!))"
    cell.courseAddress.text = game.courseAddress
    cell.courseName.text = game.courseName
    cell.date.text = game.date
    cell.currentPot.text = "Pot: $\(String(describing: game.currentPot! * game.players!.count))"
    cell.playerCount.text = "Players: \(String(describing:game.players!.count))"
    
    return cell
    
  }
}



