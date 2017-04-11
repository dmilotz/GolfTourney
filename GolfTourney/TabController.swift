//
//  TabController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/21/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import SidebarOverlay

class TabBarController:  UITabBarController {
    
    @IBInspectable var defaultIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
    }
  
  override var shouldAutorotate: Bool {
    return false
  }
  
}
