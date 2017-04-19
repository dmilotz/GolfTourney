//
//  ScoreViewController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 3/22/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit

class ScoreViewController: UITableViewController{
  var players: [Player] = []
  var game: Game?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
  }
  
  @IBOutlet var updateScore: UIBarButtonItem!
  
  @IBAction func updateScore(_ sender: Any) {
    let controller = self.storyboard?.instantiateViewController(withIdentifier: "UpdateScoreViewController") as! UpdateScoreViewController
    controller.game =  game
    self.navigationController?.pushViewController(controller, animated: true)
  }
  
}

//MARK : Table delegate

extension ScoreViewController{
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("")
  }

}


extension ScoreViewController{
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return players.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableCell", for: indexPath) as! PlayerTableCell
    let player = players[(indexPath as NSIndexPath).row]
    cell.playerName.text = player.name
    
    if let url = player.profileImageUrl{
      
      GoogleClient.getDataFromUrl(url: URL(string: url)!, completion: { (data, response, error) in
        
        guard let data = data, error == nil else {
          cell.playerImage?.image = UIImage(named: "golfDefault.png")?.circle
//          cell.activityIndicator.stopAnimating()
          return
        }
        DispatchQueue.main.async {
          cell.playerImage?.image = UIImage(data:data)
//          cell.activityIndicator.stopAnimating()
        }
      })
      cell.playerImage?.image = UIImage(named: "placeHolder.png")?.circle
//      cell.activityIndicator.startAnimating()
      
    }
    else{
      cell.playerImage?.image = UIImage(named: "golfDefault.png")?.circle
    }
    
    NetworkClient.getUserScore(gameId: (game?.gameId)!) { (dict, error) in
      if error == nil{
        DispatchQueue.main.async{
          if let scoreString = dict?["score"] as? String{
            if scoreString.contains("-"){
            cell.scoreLabel.textColor = .red
            }else{
              cell.scoreLabel.textColor = .black
            }
             cell.scoreLabel.text = scoreString
          }
          cell.holeNumber.text = dict?["thruHole"] as? String
        }
      }
      
    }
  
    return cell
  }
  
  
  
}
