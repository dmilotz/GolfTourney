//
//  GameCell.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/10/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit

class GameCell :UITableViewCell{
    
    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var spotsLeft: UILabel!
    @IBOutlet var buyInAmount: UILabel!
    @IBOutlet var currentPot: UILabel!
    @IBOutlet var playerCount: UILabel!
  @IBOutlet var coursePic: UIImageView?
    @IBOutlet var courseName: UILabel!
    @IBOutlet var courseAddress: UILabel!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
}
