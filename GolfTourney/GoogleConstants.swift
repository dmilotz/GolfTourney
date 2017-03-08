//
//  GoogleConstants.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 3/8/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
extension GoogleClient {
  
  struct Constants{
    
    static let googleApiKey = "AIzaSyCVnIoTKBa8Ela7pupwCk9xKmGaTtq5VuE"
    static let googleApiUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json?query="
    //static let googleAuthUrl = "http://www.google.com/auth-72157676093107613"
    //https://maps.googleapis.com/maps/api/place/textsearch/json?query=123+main+street&location=42.3675294,-71.186966&radius=10000&key=YOUR_API_KEY
    static let googlePhotoUrl = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" 
  }
  
  struct Args{
    static let apiKey = "&key=" + Constants.googleApiKey
    static let location = "&location="
    static let latitude = "&lat="
    static let query = "&query="
    static let radius = "&radius=1000"
  }
  
  
}
