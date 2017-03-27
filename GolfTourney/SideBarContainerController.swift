//
//  SideBarContainerController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 3/27/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import SidebarOverlay

class SideBarContainerViewController: SOContainerViewController{
  
  
  override func viewDidLoad(){
    super.viewDidLoad()
    
    self.menuSide = .left
    self.topViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabController")
    self.sideViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileController")
    
  }
  
}
