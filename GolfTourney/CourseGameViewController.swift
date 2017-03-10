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
  
  //MARK: - Properties
  var extraCourseInfo: [String: AnyObject]?
  var course: Course?
  var games: [Game] = []
  var gamesIdArr: [String]?
  var game: Game?
  var photo: UIImage?
  
  //MARK: - Outlets
  @IBOutlet var courseName: UILabel!
  @IBOutlet var courseAddress: UILabel!
  @IBOutlet var numberOfHoles: UILabel!
  @IBOutlet var yearBuilt: UILabel!
  @IBOutlet var designer: UILabel!
  @IBOutlet var tableView: UITableView!
  @IBOutlet var courseImage: UIImageView!

  
  
  //MARK: - Overridden methods
  
  override var shouldAutorotate: Bool {
    return false
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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

//MARK: - Actions
extension CourseGameViewController{
  
  @IBAction func goToWebsite(_ sender: Any) {
    if let url = extraCourseInfo?["websiteUrl"] as? URL{
      UIApplication.shared.openURL(url)
    }
    else{
      let alertController = UIAlertController(title: "Url Error", message:
        "No website provided for this course.", preferredStyle: UIAlertControllerStyle.alert)
      alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
      
      self.present(alertController, animated: true, completion: nil)
    }
  }

  @IBAction func createAGame(_ sender: Any) {
    performSegue(withIdentifier: "createGame", sender: self)
  }

  @IBAction func back(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}


// MARK: - Lifecycle
extension CourseGameViewController{
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    setUp()
    getGamesInCourse()
  }
}


//MARK: - private methods
private extension CourseGameViewController{
  func setUp(){
    courseName.text = course?.biz_name
    courseAddress.text = "\(course!.e_address), \(course!.e_city), \(course!.e_state)"
    numberOfHoles.text = "Holes: \(course!.c_holes)"
    yearBuilt.text = "Year Built: \(course!.year_built)"
    designer.text = "Designer: \(course!.c_designer)"
    courseImage.image = extraCourseInfo?["image"] as! UIImage?
  }
  
  
  func getGamesInCourse(){
    NetworkClient.getGamesPerCourse(courseId: String(course!.id)) { (dict, error) in
      if error != nil{
        print(error)
        return
      }else{
        for (key, _) in dict! {
          print("ID \(key)")
          NetworkClient.getGameInfo(gameId: key, completion: { (dict, error) in
            if error != nil{
              print(error)
              return
            }else{
              self.games.append(Game(dict:dict!))
              self.games.sort{$0.date! < $1.date!}
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
}



// MARK: - UITableViewDelegate
extension CourseGameViewController: UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.game = games[(indexPath as NSIndexPath).row]
    performSegue(withIdentifier: "gameChosen", sender: self)
  }
}


// MARK: - UITableViewDataSource
extension CourseGameViewController: UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (games.count)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //let courses = try! Realm().objects(Course.self).filter("e_city CONTAINS %@ OR e_state CONTAINS %@ OR biz_name CONTAINS %@",search,search,search)
    let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell") as! GameCell
    
    let game = self.games[(indexPath as NSIndexPath).row]
    
    cell.buyInAmount.text = "Buy In: $\(String(describing: game.buyIn!))"
    cell.playerCount.text = "Players: \(String(game.players!.count))"
    cell.title.text = game.description!
    cell.date.text = game.date!
    cell.currentPot.text = "Pot: $\(String(game.buyIn! * game.players!.count))"
    return cell
  }
  
  
  
}
