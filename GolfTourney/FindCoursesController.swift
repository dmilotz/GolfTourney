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

class FindCoursesController: UIViewController{
  
  
  
  
  //MARK: Properties
  var ref: FIRDatabaseReference!
  var courses = [Course]()
  var course = Course()
  var courseGameArr: [(course: Course, value: Int)] = []
  let searchDistance:Double =  20
  let locationManager = CLLocationManager()
  let serialQueue = DispatchQueue(label: "arrayQueue")
  var coursePhotoArr: [Course : URL] = [:]
  //MARK: Outlets
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var tableView: UITableView!
  
  //MARK: Actions
  @IBAction func nearbyCourses(_ sender: Any) {
    requestLocation()
  }
  
  //MARK: Lifecycle
  override func viewDidLoad(){
    super.viewDidLoad()
    tableView.delegate = self
    searchBar.delegate = self
    ref = FIRDatabase.database().reference()
    self.locationManager.requestWhenInUseAuthorization()
    
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      requestLocation()
    }
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier! == "courseChosen" {
      if let gameVc = segue.destination as? CourseGameViewController {
        gameVc.course = self.course
      }
    }
  }
  
  
}


// MARK: - Private Methods

private extension FindCoursesController{
  
  func requestLocation(){
    locationManager.requestLocation()
  }
  
  func deg2rad(degrees:Double) -> Double{
    return degrees * M_PI / 180
  }
  
  func search(search : String){
    let courseArr = try! Realm().objects(Course.self).filter("e_city CONTAINS %@ OR e_state CONTAINS %@ OR biz_name CONTAINS %@",search,search,search)
    for course in courseArr{
      self.courses.append(course)
    }
    sortCoursesWithGames()
  }
  
  func searchByUserLocation(predicate: NSPredicate){
    let courseArr = try? Realm().objects(Course.self).filter(predicate)
    courses = []
    for course in courseArr!{
      courses.append(course)
    }
    sortCoursesWithGames()
  }
  
  func sortCoursesWithGames(){
    courseGameArr = []
    tableView.reloadData()
    for course in courses{
      NetworkClient.getGamesPerCourse(courseId: String(course.id)) { (arr, error) in
        self.serialQueue.sync{
          if let games = arr{
            self.courseGameArr.append((course: course, value: games.count))
            self.getCoursePhotoUrl(course: course)
          }else{
            self.courseGameArr.append((course: course, value: 0))
            self.getCoursePhotoUrl(course: course)
          }
          self.courseGameArr.sort{$0.value > $1.value}
          
        }
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      }
      
    }
    
  }
  
  func getCoursePhotoUrl(course: Course){
      GoogleClient.findPhotos(lat: String(course.lat), long: String(course.long), name: course.biz_name) { (error, photoUrl) in
        print (photoUrl)
    
    }
  }
}



// MARK: - UISearchBarDelegate
extension FindCoursesController: UISearchBarDelegate{
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    search(search: searchBar.text!)
  }
}



// MARK: - CLLocationManagerDelegate
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


// MARK: - UITableViewDelegate
extension FindCoursesController: UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.course = self.courseGameArr[(indexPath as NSIndexPath).row].course
    performSegue(withIdentifier: "courseChosen", sender: self)
  }
  
  
  
}


// MARK: - UITableViewDataSource
extension FindCoursesController: UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return courseGameArr.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell") as! CourseViewCell
    let course = courseGameArr[(indexPath as NSIndexPath).row].course
    cell.courseName.text = course.biz_name
    cell.courseAddress.text = "\(course.e_address), \(course.e_city), \(course.e_state)"
    cell.currentGamesCount.text = "Current games: \(courseGameArr[(indexPath as NSIndexPath).row].value)"
//    if let url = coursePhotoArr[course]{
//      
//      FlickrClient.getDataFromUrl(url: url, completion: { (data, response, error) in
//        
//        guard let data = data, error == nil else {
//          //        print("Problem downloading photo from \(url)")
//          return
//        }
//        DispatchQueue.main.async {
//          cell.coursePic?.image = UIImage(data: data)?.circle
//        }
//      })
//    }
//    else{
      cell.coursePic?.image = UIImage(named: "golfDefault.png")?.circle
//    }
    return cell
  }
  
  
  
}
