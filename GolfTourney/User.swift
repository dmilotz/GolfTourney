//
//  User.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/7/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import FirebaseAuth

struct User {
    
    let uid: String
    let email: String
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}
