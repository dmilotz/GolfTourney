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
    var games : [Game]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    func loadGamesFromFireBase(){
        
        
        
    }
}
extension CourseGameViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let course = self.courses[(indexPath as NSIndexPath).row]
//        
//        print("Selected " + course.biz_name)
    }
    
    
    
}


extension CourseGameViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(courses.count)
        return games!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell") as! CourseViewCell
        let game = self.games![(indexPath as NSIndexPath).row]
//        print(course)
//        cell.title.text = course.biz_name
//        cell.subtitle.text = course.e_address
//        cell.currentGamesCount.text = cell.currentGamesCount.text! + "0"
//        
        // Set the name and image
        // cell.textLabel?.text =
        return cell
    }
    
    
}
