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
import GooglePlaces

class FindCoursesController: UIViewController{
  
  
  
  
  //MARK: Properties
  var placesClient: GMSPlacesClient!
  var ref: FIRDatabaseReference!
  var courses = [Course]()
  var course = Course()
  var courseGameArr: [(course: Course, value: Int)] = []
  let searchDistance:Double =  10
  let locationManager = CLLocationManager()
  let serialQueue = DispatchQueue(label: "arrayQueue")
  var coursePhotoArr: [Course : String] = [:]
  var courseImage: UIImage?
  var extraCourseInfo: [Course: [String: AnyObject]] = [:]
  //MARK: Outlets
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var tableView: UITableView!
  
  
  override var shouldAutorotate: Bool {
    return false
  }
  
  
  //MARK: Actions
  @IBAction func nearbyCourses(_ sender: Any) {
    requestLocation()
  }
  
  //MARK: Lifecycle
  override func viewDidLoad(){
    super.viewDidLoad()
    hideKeyboardWhenTappedAround()
    placesClient = GMSPlacesClient.shared()
    tableView.delegate = self
    searchBar.delegate = self
    ref = FIRDatabase.database().reference()
    locationManager.requestWhenInUseAuthorization()
    
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      requestLocation()
    }
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier! == "courseChosen" {
      if let gameVc = segue.destination as? CourseGameViewController {
        gameVc.extraCourseInfo = extraCourseInfo[course]
        gameVc.course = course
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
    let courseArr = try! Realm().objects(Course.self).filter("e_city CONTAINS %@ OR e_state CONTAINS %@ OR biz_name CONTAINS %@ OR e_postal CONTAINS %@",search,search,search,search)
    if courseArr.isEmpty{
      displayAlert("No courses found for this location.", title: "No courses found")
    }
    courses = []
    for course in courseArr{
      self.courses.append(course)
    }
    sortCoursesWithGames()
  }
  
  func searchByUserLocation(predicate: NSPredicate){
    let courseArr = try? Realm().objects(Course.self).filter(predicate)
    if (courseArr?.isEmpty)!{
      displayAlert("No nearby courses found.  Please try searching by name." , title: "No courses found")
    }
    courses = []
    for course in courseArr!{
      courses.append(course)
    }
    sortCoursesWithGames()
  }
  
  func sortCoursesWithGames(){
    courseGameArr = []
    tableView.reloadData()
    let group = DispatchGroup()
    for course in courses{
      group.enter()
      NetworkClient.getGamesPerCourse(courseId: String(course.id)) { (arr, error) in
          if !self.courseGameArr.contains(where:{$0.course.id == course.id}){
            group.leave()
            if let games = arr{
              self.courseGameArr.append((course: course, value: games.count))
              self.getCourseGoogleInfo(course: course)
            }else{
              self.courseGameArr.append((course: course, value: 0))
              self.getCourseGoogleInfo(course: course)
            }
            
            self.courseGameArr.sort{$0.value > $1.value}
            DispatchQueue.main.async {
              self.tableView.reloadData()
            }
          }
      }
      
      group.notify(queue: DispatchQueue.main, execute: {
        self.courseGameArr.sort{$0.value > $1.value}
        self.tableView.reloadData()
      })
    }
    
  }
  
  //Info that's not stored in realm database such as website and course photos are retrieved here
  
  func getCourseGoogleInfo(course: Course){
    GoogleClient.getCourseInfo(lat: String(course.lat), long: String(course.long), name: course.biz_name) { (error, dict) in
      if let photoUrl = dict?["photoUrl"]{
        self.coursePhotoArr[course] = photoUrl
        DispatchQueue.main.async{
          self.tableView.reloadData()
        }
      }
      
      if let id = dict?["placeId"]{
        self.placesClient.lookUpPlaceID(id, callback: { (place, error) -> Void in
          if let error = error {
            print("lookup place id query error: \(error.localizedDescription)")
            return
          }
          
          guard let place = place else {
            print("No place details for \(id)")
            self.extraCourseInfo[course] = ["websiteUrl": "" as AnyObject]
            return
          }
          if let url = place.website{
            print("URLLL \(url)")
            self.extraCourseInfo[course] = ["websiteUrl": url as AnyObject]
            
          }else{
            self.extraCourseInfo[course] = ["websiteUrl": "" as AnyObject]
            
          }
        })
      }else{
        self.extraCourseInfo[course] = ["websiteUrl": "" as AnyObject]
      }
    }
    
  }
  
  
}



// MARK: - UISearchBarDelegate
extension FindCoursesController: UISearchBarDelegate{
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
    let cell = tableView.cellForRow(at: indexPath) as! CourseViewCell
    course = self.courseGameArr[(indexPath as NSIndexPath).row].course
    var tmpDict = extraCourseInfo[course]! as [String:AnyObject]
    tmpDict["image"] = (cell.coursePic?.image)!
    extraCourseInfo[course] = tmpDict
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
    cell.currentGamesCount.text = "Games: \(courseGameArr[(indexPath as NSIndexPath).row].value)"
    
    if let url = coursePhotoArr[course]{
      
      GoogleClient.getDataFromUrl(url: URL(string: url)!, completion: { (data, response, error) in
        
        guard let data = data, error == nil else {
          cell.coursePic?.image = UIImage(named: "golfDefault.png")?.circle
          cell.activityIndicator.stopAnimating()
          return
        }
        DispatchQueue.main.async {
          cell.coursePic?.image = UIImage(data: data)?.circle
          cell.activityIndicator.stopAnimating()
        }
      })
      cell.coursePic?.image = UIImage(named: "golfDefault.png")?.circle
      cell.activityIndicator.startAnimating()
      
    }
    else{
      cell.coursePic?.image = UIImage(named: "golfDefault.png")?.circle
    }
    return cell
  }
  
  
  
}
