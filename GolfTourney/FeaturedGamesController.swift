//
//  FeaturedGamesController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 3/27/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import CoreLocation
import RealmSwift

class FeaturedGamesViewController: UITableViewController{
  
  //MARK: properties
  var chosenGame: Game?
  var ref: FIRDatabaseReference!
  var courses :[Course] = []
  var games : [Game] = []
  let locationManager = CLLocationManager()
  
  let searchDistance:Double =  20 //float value in KM
  
  //Using two arrays instead of dictionary because of table indexing issues
  var gamesPerCourse : [Course: [String]] = [:]
  var gamesIdArr : [String] = []
  var gamesArr: [Game] = []
  var coursesWithGamesArr: [Course] = []
  
  
  //MARK: Outlets
  //@IBOutlet var searchBar: UISearchBar!
  override var shouldAutorotate: Bool {
    return false
  }
  
  @IBAction func nearbyCourses(_ sender: Any) {
    requestLocation()
  }
  
  
}

// MARK: - Lifecycle
extension FeaturedGamesViewController{
  override func viewDidLoad(){
    super.viewDidLoad()
    hideKeyboardWhenTappedAround()
    tableView.delegate = self
    
    ref = FIRDatabase.database().reference()
    
    self.locationManager.requestWhenInUseAuthorization()
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    requestLocation()
  }
}


// MARK: - Search methods
private extension FeaturedGamesViewController{
  func findCoursesWithGames(){
    games = []
    let group = DispatchGroup()
    var gameCount = 0
    for course in courses{
      group.enter()
      ref.child("courses").child(String(course.id)).child("currentGames").observeSingleEvent(of: .value, with: { (snapshot) in
        if let dict = snapshot.value as? [String:String]{
          for id in dict.keys{
            gameCount += 1
            self.getGameInfoFromCourse(gameId: id)
          }
        }
        group.leave()
      }) { (error) in
        group.leave()
        print(error.localizedDescription)
      }
    }
    group.notify(queue: DispatchQueue.main) {
      if gameCount == 0{
        self.games = []
        self.tableView.reloadData()
        self.displayAlert("No games found at this location.", title: "No games found.")
        
      }
    }
  }
  
  func getGameInfoFromCourse(gameId: String){
    ref.child("games").child(gameId).observeSingleEvent(of: .value, with: { (snapshot) in
      if let gameInfo = snapshot.value as? [String:Any]{
        var game = Game(dict:gameInfo)
        game.gameId = gameId
        if self.games.contains(where: { $0.gameId == game.gameId}){
          return
        }
        else{
          self.games.append(game)
          self.games.sort{$0.date! < $1.date!}
          DispatchQueue.main.async{
            self.tableView.reloadData()
          }
        }
      }
    })
  }
  
}

// MARK: - Private methods
extension FeaturedGamesViewController{
  func requestLocation(){
    locationManager.requestLocation()
  }
  
  func deg2rad(degrees:Double) -> Double{
    return degrees * M_PI / 180
  }
  
  func search(search : String){
    let coursesArr = try! Realm().objects(Course.self).filter("e_city CONTAINS %@ OR e_state CONTAINS %@ OR biz_name CONTAINS %@ OR e_postal CONTAINS %@",search,search,search,search)
    if coursesArr.isEmpty{
      displayAlert("No courses found for this location.", title: "No courses found")
    }
    self.courses = []
    for course in coursesArr{
      self.courses.append(course)
    }
    findCoursesWithGames()
  }
  
  //Call is coming from Location delegate below
  func searchByUserLocation(predicate: NSPredicate){
    let courseArr = try? Realm().objects(Course.self).filter(predicate)
    self.courses = []
    if (courseArr?.isEmpty)!{
      displayAlert("No nearby courses found.  Please try searching by name or city.", title: "No courses found")
    }
    for course in courseArr!{
      self.courses.append(course)
    }
    findCoursesWithGames()
  }
  
  
}


// MARK: - UISearchBarDelegate
extension FeaturedGamesViewController: UISearchBarDelegate{
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //searchActive = false
    searchBar.endEditing(true)
    searchBar.resignFirstResponder()
    search(search: searchBar.text!)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    searchBar.resignFirstResponder()
  }
}


//MARK: Location Manager

extension FeaturedGamesViewController: CLLocationManagerDelegate{
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways {
      if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
        if CLLocationManager.isRangingAvailable() {
          // do stuff
        }
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let userLocation = locations.first{
      let minLat = userLocation.coordinate.latitude - (searchDistance / 69)
      let maxLat = userLocation.coordinate.latitude + (searchDistance / 69)
      
      let minLon = userLocation.coordinate.longitude - searchDistance / fabs(cos(deg2rad(degrees: userLocation.coordinate.latitude))*69)
      let maxLon = userLocation.coordinate.longitude + searchDistance / fabs(cos(deg2rad(degrees: userLocation.coordinate.latitude))*69)
      
      searchByUserLocation(predicate: NSPredicate(format: "lat < %f AND lat > %f AND long < %f AND long > %f",maxLat, minLat, maxLon, minLon))
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Failed to find user's location: \(error.localizedDescription)")
  }
}


//MARK : Table delegate
extension FeaturedGamesViewController{
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let gameVc = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
    gameVc.game = games[(indexPath as NSIndexPath).row]
    self.present(gameVc, animated: true, completion: nil)
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    
    if segue.identifier! == "gameChosen" {
      
      if let gameVc = segue.destination as? GameViewController {
        gameVc.game = chosenGame
      }
    }
  }
  
  
}


extension FeaturedGamesViewController{
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print(games.count)
    return games.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //let courses = try! Realm().objects(Course.self).filter("e_city CONTAINS %@ OR e_state CONTAINS %@ OR biz_name CONTAINS %@",search,search,search)
    let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell") as! GameCell
    
    let game = self.games[(indexPath as NSIndexPath).row]
    cell.buyInAmount.text = "Buy in: $\(String(describing: game.buyIn!))"
    //cell.title.text = game.description!
    //cell.courseAddress.text = game.courseAddress!
    cell.courseName.text = game.courseName!
    cell.date.text = game.date!
//    cell.currentPot.text = "Pot: $\(game.buyIn! * game.players!.count)"
//    cell.courseAddress.text = game.courseAddress!
    cell.playerCount.text = "\(game.players!.count) Players"
    GoogleClient.getDataFromUrl(url: URL(string: game.coursePicUrl!)!, completion: { (data, response, error) in
      
      guard let data = data, error == nil else {
        cell.coursePic?.image = UIImage(named: "golfDefault.png")
//        cell.activityIndicator.stopAnimating()
        return
      }
      DispatchQueue.main.async {
        cell.coursePic?.image = UIImage(data: data)
//        cell.activityIndicator.stopAnimating()
      }
    })
    cell.coursePic?.image = UIImage(named: "golfDefault.png")?.circle
//    cell.activityIndicator.startAnimating()
    
    
    return cell
  }
  
  
  
}


