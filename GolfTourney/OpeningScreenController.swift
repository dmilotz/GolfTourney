//
//  OpeningScreenController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/13/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
class OpeningScreenController: UIViewController{
    
    @IBAction func startNewTourney(_ sender: Any) {
        performSegue(withIdentifier: "startNewTourney", sender: self)
    }
    

    
    @IBAction func joinTourney(_ sender: Any) {
         performSegue(withIdentifier: "joinExistingTourney", sender: self)
    }
}
