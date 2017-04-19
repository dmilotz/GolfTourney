//
//  UpdateScoreViewController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 4/18/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class UpdateScoreViewController: UIViewController{
  
  var player: Player?
  var game: Game?
  let ref = FIRDatabase.database().reference()
  let uid = FIRAuth.auth()?.currentUser?.uid

//  MARK : Outlets
  @IBOutlet var scoreLabel: UILabel!
  @IBOutlet var scoreStepper: UIStepper!
  @IBOutlet var holeNumberStepper: UIStepper!
  @IBOutlet var saveButton: UIButton!
  @IBOutlet var scoreCardImage: UIImageView!
  @IBOutlet var holeNumberLabel: UILabel!

  
  // MARK: - Lifecycle
    override func viewDidLoad() {
      super.viewDidLoad()
      self.navigationController?.navigationBar.isHidden = false
      scoreStepper.maximumValue = 40
      scoreStepper.minimumValue = -40
      holeNumberStepper.maximumValue = 18
      holeNumberStepper.minimumValue = 1
    }
 
  
  
  // MARK : Actions
  @IBAction func uploadScoreCardButton(_ sender: Any) {
  }
  
  @IBAction func saveButtonPressed(_ sender: Any) {
    let userScoreInfo = ["score": scoreLabel.text, "thruHole":holeNumberLabel.text, "scoreCardImageUrl": "", "receiptImageUrl":""]
        ref.child("users").child(uid!).child("currentGames").child((game?.gameId!)!).setValue(userScoreInfo)
  }
  

  @IBAction func holeNumberStepper(_ sender: UIStepper) {
    holeNumberLabel.text = "\(Int(sender.value))"

  }
  
  @IBAction func scoreStepper(_ sender: UIStepper) {
    let score = Int(sender.value)
    if (score < 0){
      scoreLabel.textColor = .red
      scoreLabel.text = "\(score)"
    }else{
    scoreLabel.textColor = .black
    scoreLabel.text = "+\(score)"
    }
  }


}
