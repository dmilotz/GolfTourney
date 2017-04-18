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

  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
  }
  
  @IBOutlet var updateScore: UIBarButtonItem!
  
  
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "playerCollectionCell", for: indexPath) as! PlayerCollectionCell
    
    
  
  }
  
  
  
}
