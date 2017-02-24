//
//  WelcomePageController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/8/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseDatabase
import RealmSwift
import CoreLocation

class FindCoursesController: UIViewController,  UISearchBarDelegate{
    
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var tableView: UITableView!
    
    
    var ref: FIRDatabaseReference!
    var courses = [Course]()
    var course = Course()
    let searchDistance:Double =  20
    let locationManager = CLLocationManager()

    @IBAction func nearbyCourses(_ sender: Any) {
        requestLocation()
    }
    
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
            requestLocation()
        }
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
        tableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        courses = []
        tableView.reloadData()
        search(search: searchBar.text!)
        
    }
    
    func searchByUserLocation(predicate: NSPredicate){
        
        
        let courseArr = try? Realm().objects(Course.self).filter(predicate)
        self.courses = []
        for course in courseArr!{
            self.courses.append(course)
        }
        tableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "courseChosen" {
            
            if let gameVc = segue.destination as? CourseGameViewController {
                gameVc.course = self.course
            }
        }
    }
    
}

extension FindCoursesController: CLLocationManagerDelegate{
    
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
}


extension FindCoursesController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.course = self.courses[(indexPath as NSIndexPath).row]
        
        performSegue(withIdentifier: "courseChosen", sender: self)
    }
    
    
    
}


extension FindCoursesController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell") as! CourseViewCell
        let course = self.courses[(indexPath as NSIndexPath).row]
      
        cell.courseName.text = course.biz_name
        cell.courseAddress.text = "\(course.e_address), \(course.e_city), \(course.e_state)"
        

        NetworkClient.getGamesPerCourse(courseId: String(course.id)) { (arr, error) in
            if error != nil{
                print(error)
                return
            }
                    cell.currentGamesCount.text = "Current games: \(arr!.count)"
                    //tableView.reloadData()
              
            
        }
        // Set the name and image
        // cell.textLabel?.text =
        return cell
    }
    
    
    
}
