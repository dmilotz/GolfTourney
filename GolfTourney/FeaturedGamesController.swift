//
//  FeaturedGamesController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 3/27/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import SidebarOverlay

class FeaturedGamesViewController: SOContainerViewController{
  

  override func viewDidLoad(){
    super.viewDidLoad()
    
    self.menuSide = .left
    self.topViewController = self.storyboard?.instantiateViewController(withIdentifier: "topScreen")
    self.sideViewController = self.storyboard?.instantiateViewController(withIdentifier: "leftScreen")
    
  }

}
