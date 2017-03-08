//
//  GameCollectionViewCell.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/8/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
class CourseViewCell : UITableViewCell{
  
  
  
  @IBOutlet var courseName: UILabel!
  @IBOutlet var coursePic: UIImageView?
  @IBOutlet var courseAddress: UILabel!
  @IBOutlet var currentGamesCount: UILabel!
  
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
}
