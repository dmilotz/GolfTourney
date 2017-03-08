//
//  FlickrConstants.swift
//  Virtual tourist
//
//  Created by Dirk Milotz on 1/28/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation

extension FlickrClient {
  
  struct Constants{
    
    static let flickrApiKey = "19cd135157448a3e000bd5f27a20720d"
    static let flickrPhotoLocationMethod = "flickr.photos.search"
    static let flickrApiUrl = "https://api.flickr.com/services/rest/?&method="
    static let flickrAuthUrl = "http://www.flickr.com/auth-72157676093107613"
    
  }
  
  struct FlickrArgs{
    static let apiKey = "&api_key=" + Constants.flickrApiKey
    static let longitude = "&lon="
    static let latitude = "&lat="
    static let accuracy = "&accuracy="
    static let jsonFormat = "&format=json&nojsoncallback=1"
    static let pageNum = "&page="
    static let tags = "&tags=golf course"
  }
  
  
}
