//
//  NetworkClient.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/7/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

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
    
    static func checkUserExists(uid: String, completion: @escaping (_ bool: Bool? , _ error: Error?) -> Void) {
        let ref = FIRDatabase.database().reference()
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(uid){
                completion(true, nil)
            }else{
                completion(false, nil)
            }
            
        }){ (error) in
            completion(nil,error)
        }
        
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
                print (dict)
                completion(dict, nil)
            }
        }) { (error) in
            completion(nil,error)
        }
        
    }
    
    static func createGame(_ game: Game, completion: @escaping (_ string: String?, _ error: Error?) -> Void){
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        ref.child("games").child(game.gameId!).setValue(game.getDict())
        ref.child("users").child(uid!).child("currentGames").child(game.gameId!).setValue(game.courseName)
        ref.child("courses").child(game.courseId!).child("currentGames").child(game.gameId!).setValue("")
        ref.child("courses").child(game.courseId!).child("courseName").setValue(game.courseName)
      completion("Done", nil)
    }
    
    static func getGamesPerCourse(courseId: String, completion: @escaping (_ dict: [String:Any]?, _ error: String?) -> Void) {
        let ref = FIRDatabase.database().reference()
        ref.child("courses").child(courseId).child("currentGames").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                completion(dict, nil)
            }else{
            completion(nil, "No Current Games")
            }
        })
        
    }
    
    static func leaveGame(gameId: String, completion: @escaping (_ string: String?, _ error: Error?) -> Void){
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(uid!).child("currentGames").child(gameId).removeValue()
        ref.child("games").child(gameId).child("players").child(uid!).removeValue()
        
    }
    
    
    static func cancelGame(game: Game){
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(uid!).child("currentGames").child(game.gameId!).removeValue()
        ref.child("games").child(game.gameId!).removeValue()
        ref.child("courses").child(game.courseId!).child("currentGames").child(game.gameId!).removeValue()
        for playerId in (game.players?.keys)!{
            ref.child("users").child(playerId).child("currentGames").child(game.gameId!).removeValue()
        }
    }
    
    
}



