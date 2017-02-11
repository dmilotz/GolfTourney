//
//  GameViewController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/10/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import Firebase

class GameViewController: UIViewController, UITableViewDelegate{
    
    var game: Game?
    
    @IBOutlet var buyInLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var spotsLeftLabel: UILabel!
    @IBOutlet var courseLabel: UILabel!
    @IBOutlet var playertTableView: UITableView!
    
}
