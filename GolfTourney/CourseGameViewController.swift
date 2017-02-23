//
//  CourseGameViewController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/10/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CourseGameViewController : UIViewController {
    
    var course : Course?
    var games : [Game] = []
    var gamesIdArr: [String]?
    var game: Game?
    
    @IBOutlet var courseName: UILabel!
    @IBOutlet var courseAddress: UILabel!
    @IBOutlet var phoneNumber: UILabel!
    @IBOutlet var numberOfHoles: UILabel!
    @IBOutlet var yearBuilt: UILabel!
    @IBOutlet var designer: UILabel!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func createAGame(_ sender: Any) {
        performSegue(withIdentifier: "createGame", sender: self)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setUp()
        getGamesInCourse()
    }
    
    func setUp(){
        courseName.text = course?.biz_name
        courseAddress.text = "\(course!.e_address), \(course!.e_city), \(course!.e_state)"
        phoneNumber.text =  course!.biz_phone
        numberOfHoles.text = "Holes: \(course!.c_holes)"
        yearBuilt.text = "Year Built: \(course!.year_built)"
        designer.text = "Designer: \(course!.c_designer)"
    }
    
 
    func getGamesInCourse(){
        NetworkClient.getGamesPerCourse(courseId: String(course!.id)) { (idArr, error) in
            if error != nil{
                print("BLAHHHHH")
                print(error)
                return
            }else{
                for id in idArr!{
                    print("ID \(id)")
                    NetworkClient.getGameInfo(gameId: id, completion: { (dict, error) in
                        print (dict)
                        if error != nil{
                            print(error)
                            return
                        }else{
                            self.games.append(Game(dict:dict!))
                            print("GAMES \(self.games)")
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
                
            }
        }
        
        
    }
//
//    func getGameInfoFromCourse(){
//        for game in gamesIdArr{
//            
//            ref.child("games").child(game).observeSingleEvent(of: .value, with: { (snapshot) in
//                
//                if let gameInfo = snapshot.value as? [String:Any]{
//                    self.games.append(Game(dict: gameInfo))
//                    print("GAME INFO\(self.games)")
//                }else{
//                    print("NOPE\(snapshot.value)")
//                }
//                self.tableView.reloadData()
//            })
//            
//        }
//        
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "createGame" {
            
            if let gameVc = segue.destination as? CreateGameController {
                gameVc.course = self.course!
            }
        }else if (segue.identifier! == "gameChosen"){
            if let vc = segue.destination as? GameViewController{
                vc.game = self.game
            }
        }
    }
    
    
}
extension CourseGameViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.game = games[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: "gameChosen", sender: self)
    }
    
    
}


extension CourseGameViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (games.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let courses = try! Realm().objects(Course.self).filter("e_city CONTAINS %@ OR e_state CONTAINS %@ OR biz_name CONTAINS %@",search,search,search)
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell") as! GameCell
        
        let game = self.games[(indexPath as NSIndexPath).row]
        
        cell.buyInAmount.text = String(describing: game.buyIn!)
        cell.title.text = game.description!
        cell.date.text = game.date!
        return cell
    }
    
    
    
}
