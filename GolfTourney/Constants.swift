//
//  Constants.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/8/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation

extension NetworkClient{
    
    struct Constants{
        let firebaseDbUrl = "https://tourneymaker-261e1.firebaseio.com/"
        let apiKey = ""
        let googleTextSearchUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json?"
        
    }
    
    struct args{
        
        let query = "&query=golf+course"
        let location = "&location="
        let radiusSize = "&radius=5000"
        let key =  "&key="
        
        
    }
}
