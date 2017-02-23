//
//  NetworkClient.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/7/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NetworkClient{
    
    // shared session
    var session = URLSession.shared
    
    
    static func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data, error == nil else{
                print("problem loading photo from url \(url)")
                return
            }
            
            completion(data, response, error)
            }.resume()
    }
    
    static func getGameInfo(gameId: String, completion: @escaping (_ dict: [String:Any]?, _ error: Error?) -> Void) {
        let ref = FIRDatabase.database().reference()
        ref.child("games").child(gameId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                completion(dict, nil)
            }
        }) { (error) in
            completion(nil,error)
        }
        
    }
    
    static func getUserInfo(userId: String, completion: @escaping (_ dict: [String:Any]?, _ error: Error?) -> Void) {
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                completion(dict, nil)
            }
        }) { (error) in
            completion(nil,error)
        }
        
    }
    
    
    static func getGamesPerCourse(courseId: String, completion: @escaping (_ arr: [String]?, _ error: Error?) -> Void) {
        let ref = FIRDatabase.database().reference()
        ref.child("courses").child(courseId).child("currentGames").observeSingleEvent(of: .value, with: { (snapshot) in
            if let arr = snapshot.value as? [String]{
                completion(arr, nil)
            }
        }) { (error) in
            completion(nil,error)
        }
        
    }
    
    static func leaveGame(uid: String, gameId: String, completion: @escaping (_ string: String?, _ error: Error?) -> Void){
        let ref = FIRDatabase.database().reference()
        ref.child(uid).child("currentGames").observeSingleEvent(of: .value, with: { (snapshot) in
            if let arr = snapshot.value as? [String]{
                for val in arr{
                    if val == gameId{
                    }
                }
            }
            
//                    if item.value as! String == gameId{
//                        item.ref.child(item.key!).parent?.removeValue()
//                    }
                }
            }
            
        })
        
        
        
    }
    
    
}



