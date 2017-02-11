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
class WelcomePageController: UIViewController,  UISearchBarDelegate{
    
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var tableView: UITableView!
    
    
    var ref: FIRDatabaseReference!
    var courses = [Course]()
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.delegate = self
        searchBar.delegate = self
        ref = FIRDatabase.database().reference()
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
          print (courses.count)
        self.courses = []
        for course in courses{
            print(course.biz_name)
            self.courses.append(course)
        }
        tableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searching...")
        search(search: searchBar.text!)
    
    }
}

extension WelcomePageController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = self.courses[(indexPath as NSIndexPath).row]

        print("Selected " + course.biz_name)
    }
    
  

}

    
extension WelcomePageController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(courses.count)
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell") as! CourseViewCell
        let course = self.courses[(indexPath as NSIndexPath).row]
        print(course)
        cell.title.text = course.biz_name
        cell.subtitle.text = course.e_address
        cell.currentGamesCount.text = cell.currentGamesCount.text! + "0"
        
        // Set the name and image
       // cell.textLabel?.text =
        return cell
    }
    
    
    
}
