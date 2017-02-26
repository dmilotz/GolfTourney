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
    let name: String?
    let email: String?
    let handicap: String?
    let gamesWon: String?
    let profileImageUrl: String?
    let currentGames: [String: String]?
    let zipCode: String?
}
extension Player{
    
    init(dict: [String:Any]){
        //uid = dict["gameId"] as! String?
        handicap = dict["handicap"] as! String?
        name = dict["userName"] as! String?
        gamesWon = dict["gamesWon"] as! String?
        email = dict["email"] as! String?
        profileImageUrl = dict["profileImage"] as! String?
        currentGames = dict["currentGames"] as! [String: String]?
        }
    
    init(firstTimeSetUpDict: [String:Any]){
        handicap = firstTimeSetUpDict["handicap"] as! String?
        name = firstTimeSetUpDict["userName"] as! String?
        email = firstTimeSetUpDict["email"] as! String?
        profileImageUrl = firstTimeSetUpDict["profileImage"] as! String?
    }
}
