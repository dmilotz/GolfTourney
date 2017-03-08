//
//  PhotoModel.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 1/28/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation

struct PhotoModel{
  let photoId: String
  let farm: Int
  let secret: String
  let server: String
  let title: String
  
  var photoUrl: URL{
    return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret)_m.jpg")!
  }
}
