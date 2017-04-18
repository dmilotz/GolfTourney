//
//  PlayerTableCell.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/10/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit

class PlayerTableCell: UITableViewCell{
    
    @IBOutlet var playerImage: UIImageView?
    
    @IBOutlet var playerName: UILabel!
    
    @IBOutlet var handicapLabel: UILabel!
    
    @IBOutlet var gamesWonLabel: UILabel!
    
  @IBOutlet var scoreLabel: UILabel!
  @IBOutlet var holeNumber: UILabel!
  
}
