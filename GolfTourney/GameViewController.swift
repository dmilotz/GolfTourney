//
//  GameViewController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/10/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class GameViewController: UIViewController{
    
    var ref: FIRDatabaseReference!

    
    var game: Game?
    var players: [String]?
    
    @IBOutlet var buyInLabel: UILabel!
    @IBOutlet var currentPotLabel: UILabel!
    @IBOutlet var spotsLeftLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var courseLabel: UILabel!
    @IBOutlet var playerCollectionView: UICollectionView!

    @IBAction func joinGame(_ sender: Any) {
        
        
    }
    
    
    
   override func viewDidLoad() {
        super.viewDidLoad()
    
        ref = FIRDatabase.database().reference()
    
        playerCollectionView.delegate = self
     playerCollectionView.dataSource = self
        buyInLabel.text = String(describing: game?.buyIn!)
        currentPotLabel.text = String(describing: game?.currentPot!)
        dateLabel.text = game?.date!
        courseLabel.text = game?.courseName
        players = game?.players!
    }
    
    
    
}
extension GameViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (players?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = playerCollectionView.dequeueReusableCell(withReuseIdentifier: "playerCell", for: indexPath) as! PlayerCollectionCell

        
        let player = players![(indexPath as NSIndexPath).row]
        ref.child("players").child(player).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                if let name = dict["userName"]{
                    cell.playerName.text = name as? String
                }else{
                    cell.playerName.text = "No Name Provided"
                }
            }
            
        })
        
        return cell

        
        
        
    }
    
    
}
