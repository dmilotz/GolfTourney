//
//  PlayerModel.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/10/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
struct Player{

    var uid: String?
    var name: String?
    var email: String?
    var handicap: String?
    var gamesWon: String?
    var profileImageUrl: String?
    var currentGames: [String: String]?
    var zipCode: String?
}
extension Player{
        init(dict: [String:Any]){
            //uid = dict["gameId"] as! String?
            if let handicap = dict["handicap"] as? String{
                self.handicap = handicap
            }else{
                self.handicap = "36"
            }
            
            if let name = dict["userName"] as? String{
                self.name = name
            }else{
                self.name = "Name not given"
            }
            
            if let gamesWon = dict["gamesWon"] as? String{
                self.gamesWon = gamesWon
            }else{
                self.gamesWon = "0"
            }

            if let email = dict["email"] as? String{
             self.email = email
            }else{
                self.email = "None provided"
            }
            
            if let profileImageUrl = dict["profileImage"] as? String{
                self.profileImageUrl = profileImageUrl
            }
            
            if let currentGames = dict["currentGames"] as? [String:String]{
                self.currentGames = currentGames
            }
//            }else{
//                self.profileImageUrl = "default"
//            }
            
            if let zipCode = dict["zipCode"] as? String{
                self.zipCode = zipCode
            }else{
                self.zipCode = "00000"
            }
    }
    
    
//    init(dict: [String:Any]){
//        //uid = dict["gameId"] as! String?
//        handicap = dict["handicap"] as! String?
//        name = dict["userName"] as! String?
//        gamesWon = dict["gamesWon"] as! String?
//        email = dict["email"] as! String?
//        profileImageUrl = dict["profileImage"] as! String?
//        currentGames = dict["currentGames"] as! [String: String]?
//        }
    
//    init(firstTimeSetUpDict: [String:Any]){
//        handicap = firstTimeSetUpDict["handicap"] as! String?
//        name = firstTimeSetUpDict["userName"] as! String?
//        email = firstTimeSetUpDict["email"] as! String?
//        profileImageUrl = firstTimeSetUpDict["profileImage"] as! String?
//    }
}
