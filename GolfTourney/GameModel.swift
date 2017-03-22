//
//  GameModel.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/10/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation

struct Game{
    var gameId : String?
    let preferredHandicap: String?
    let courseName: String?
    let courseId: String?
    let courseAddress: String?
    let date: String?
    let players : [String: String]?
    let buyIn : Int?
    let description : String?
    let maxPlayers: Int?
    let currentPlayerCount: Int?
    let currentPot : Int?
    let gameOwner : String?
  var coursePicUrl : String?
  var courseWebsiteUrl: String?
   // init(){}

    
    func getDict()->[String:Any]{
        return ["courseName": courseName!, "courseAddress": courseAddress!, "courseId": courseId!, "preferredHandicap": preferredHandicap!, "date": date!, "players": players!,"buyIn":buyIn!,"description": description!, "maxPlayers":maxPlayers!, "currentPlayerCount":currentPlayerCount!, "currentPot":currentPot!, "gameOwner":gameOwner!, "coursePicUrl":coursePicUrl!, "courseWebsiteUrl": courseWebsiteUrl!]
    }
    
}

extension Game{
    
    init(dict: [String:Any]){
        //gameId = dict["gameId"] as! String?
        preferredHandicap = dict["preferredHandicap"] as! String?
        courseName = dict["courseName"] as! String?
        courseId = dict["courseId"] as! String?
        courseAddress = dict["courseAddress"] as! String?
        date = dict["date"] as! String?
        players = dict["players"] as! [String: String]?
        buyIn = dict["buyIn"] as! Int?
        description = dict["description"] as! String?
        maxPlayers = dict["maxPlayers"] as! Int?
        currentPlayerCount = dict["currentPlayerCount"] as! Int?
        currentPot = dict["currentPot"] as! Int?
        gameOwner = dict["gameOwner"] as! String?
        coursePicUrl = dict["coursePicUrl"] as! String?
        courseWebsiteUrl = dict["courseWebsiteUrl"] as! String?
    }
}
