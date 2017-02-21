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
    
    var game: Game?
    var ref: FIRDatabaseReference!
    var courses = [Course]()
    var games = [Game]()
    let locationManager = CLLocationManager()
    
    let searchDistance:Double =  20 //float value in KM
    
    //let coursesWithGames = [Course]()
    
    
    
    //Using two arrays instead of dictionary because of table indexing issues
    var gamesPerCourse : [Course: [String]] = [:]
    var gamesIdArr = [String]()
    var gamesArr: [Game] = []
    var coursesWithGamesArr: [Course] = []
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.delegate = self
        searchBar.delegate = self
        ref = FIRDatabase.database().reference()
        
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
    }
    
    
    func deg2rad(degrees:Double) -> Double{
        return degrees * M_PI / 180
    }
    
    func search(search : String){
        //     ref.child("courses").removeValue { (error, ref) in
        //        if error != nil{
        //            print(error?.localizedDescription)
        //        }
        //        }
        
        //        .queryOrdered(byChild: "e_city").queryEqual(toValue: search).observeSingleEvent(of: .value, with: { (snapshot) in
        //            // Get user value
        //            print(snapshot)
        //            let value = snapshot.value as? NSDictionary
        //            let biz_name = value?["biz_name"] as? String ?? ""
        //            print(biz_name)
        //
        //            // ...
        //        }) { (error) in
        //            print(error.localizedDescription)
        //        }
        
        
        let courses = try! Realm().objects(Course.self).filter("e_city CONTAINS %@ OR e_state CONTAINS %@ OR biz_name CONTAINS %@",search,search,search)
        //let tables = try! Realm().objects(Course.self).first
        //print (tables)
        //print (courses.count)
        self.courses = []
        for course in courses{
            // print(course.biz_name)
            self.courses.append(course)
        }
        //tableView.reloadData()
        findCoursesWithGames()
    }
    
    
    func searchByUserLocation(predicate: NSPredicate){
        
        
        //        let courses = try? Realm().objects(Course.self).filter(predicate)
        //        self.courses = []
        //        for course in courses!{
        //            print(course.biz_name)
        //            self.courses.append(course)
        //        }
        //tableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searching...")
        search(search: searchBar.text!)
        
    }
    
    
    func findCoursesWithGames(){
        for course in courses{
//            print(course.biz_name)
            //let courseName = course.biz_name.replacingOccurrences(of: ".", with: "")
            try? ref.child("courses").child(String(course.id)).queryOrdered(byChild: "currentGames").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if let vals = value?.allValues{
                    for val in vals{
                        print (val)
                        self.gamesPerCourse[course] = val as? [String]
                        //self.coursesWithGamesArr.append(course)
                        if let gameIds = val as? [String]{
                            self.gamesIdArr.append(contentsOf: gameIds)
                        }else{
                            print("game id\(val) not added")
                        }
                        

                    }
                }
               self.getGameInfoFromCourse()
            //self.tableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    
    func getGameInfoFromCourse(){
        for game in gamesIdArr{
            
            ref.child("games").child(game).observeSingleEvent(of: .value, with: { (snapshot) in
                
                    if let gameInfo = snapshot.value as? [String:Any]{
                        self.games.append(Game(dict: gameInfo))
                        print("GAME INFO\(self.games)")
                    }else{
                        print("NOPE\(snapshot.value)")
                    }
                self.tableView.reloadData()
            })
            
        }
        
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
        let userLocation = locations[0]
        let minLat = userLocation.coordinate.latitude - (searchDistance / 69)
        let maxLat = userLocation.coordinate.latitude + (searchDistance / 69)
        
        let minLon = userLocation.coordinate.longitude - searchDistance / fabs(cos(deg2rad(degrees: userLocation.coordinate.latitude))*69)
        let maxLon = userLocation.coordinate.longitude + searchDistance / fabs(cos(deg2rad(degrees: userLocation.coordinate.latitude))*69)
        
        searchByUserLocation(predicate: NSPredicate(format: "lat < %f AND lat > %f AND long < %f AND long > %f",maxLat, minLat, maxLon, minLon))
        
    }
}

extension FindTourneyController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.game = games[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: "gameChosen", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "gameChosen" {
            
            if let gameVc = segue.destination as? GameViewController {
                gameVc.game = self.game
            }
        }
    }
    
    
}


extension FindTourneyController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
