//
//  FindTourneyController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/13/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//


import Foundation
import UIKit
import CoreLocation
import Firebase
import FirebaseCore
import FirebaseDatabase
import RealmSwift

class FindTourneyController: UIViewController,  UISearchBarDelegate{
    
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var tableView: UITableView!
    
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
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.delegate = self
        searchBar.delegate = self
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
    
    func requestLocation(){
        locationManager.requestLocation()
    }
    
    
    func deg2rad(degrees:Double) -> Double{
        return degrees * M_PI / 180
    }
    
    func search(search : String){
        
        
        let courses = try! Realm().objects(Course.self).filter("e_city CONTAINS %@ OR e_state CONTAINS %@ OR biz_name CONTAINS %@",search,search,search)
        self.courses = []
        for course in courses{
            self.courses.append(course)
        }
        
        findCoursesWithGames()
    }
    
    
    func searchByUserLocation(predicate: NSPredicate){
        let courseResults = try? Realm().objects(Course.self).filter(predicate)
        self.courses = []
        for course in courseResults!{
            self.courses.append(course)
        }
        findCoursesWithGames()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searching...")
        courses = []
        search(search: searchBar.text!)
        
    }
    
    
    func findCoursesWithGames(){
        games = []
        for course in courses{
            ref.child("courses").child(String(course.id)).child("currentGames").observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String:String]{
                    for id in dict.keys{
                        // self.gamesIdArr.append(id)
                        self.getGameInfoFromCourse(gameId: id)
                    }
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    func getGameInfoFromCourse(gameId: String){
        //games = []
        
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
    
    
    extension FindTourneyController: CLLocationManagerDelegate{
        
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
    
    extension FindTourneyController: UITableViewDelegate{
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            chosenGame = games[(indexPath as NSIndexPath).row]
            performSegue(withIdentifier: "gameChosen", sender: self)
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
    
    
    extension FindTourneyController: UITableViewDataSource{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print(games.count)
            return games.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            //let courses = try! Realm().objects(Course.self).filter("e_city CONTAINS %@ OR e_state CONTAINS %@ OR biz_name CONTAINS %@",search,search,search)
            let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell") as! GameCell
            
            let game = self.games[(indexPath as NSIndexPath).row]
            cell.buyInAmount.text = String(describing: game.buyIn)
            cell.title.text = game.description!
            cell.courseAddress.text = game.courseAddress!
            cell.courseName.text = game.courseName!
            cell.date.text = game.date!
            return cell
        }
        
        
        
}
