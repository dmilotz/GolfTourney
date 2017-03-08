//
//  FlickrClient.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 1/28/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
// MARK: - OnTheMapClient: NSObject

class FlickrClient{
  
  static func getFlickrPhotos(latitude: String, longitude:String, completionHandlerForGetPhotos: @escaping (_ error: String?, [PhotoModel]?) -> Void) {
    
    //let randomPageNum = String(Int(arc4random_uniform(10)))
    
    let url = Constants.flickrApiUrl + Constants.flickrPhotoLocationMethod + FlickrArgs.apiKey +  FlickrArgs.latitude + latitude + FlickrArgs.longitude + longitude + FlickrArgs.pageNum + 0 + FlickrArgs.tags + FlickrArgs.jsonFormat
    
    print(url)
    
    let request = NSMutableURLRequest(url: URL(string: url)!)
    
    
    let session = URLSession.shared
    let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
      
      if error != nil {
        print("Error fetching photos: \(error)")
        completionHandlerForGetPhotos(error?.localizedDescription as String!, nil)
        return
      }
      
      do {
        let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
        guard let results = resultsDictionary else { return }
        
        if let statusCode = results["code"] as? Int {
          if statusCode == 100 {
            let invalidAccessError = NSError(domain: "com.flickr.api", code: statusCode, userInfo: nil)
            completionHandlerForGetPhotos(invalidAccessError.localizedDescription as String!, nil)
            return
          }
        }
        
        guard let photosContainer = resultsDictionary!["photos"] as? NSDictionary else { return }
        guard let photosArray = photosContainer["photo"] as? [NSDictionary] else { return }
        
        if (photosArray.isEmpty){
          completionHandlerForGetPhotos("No Photos Found", nil)
        }
        else{
          let flickrPhotos: [PhotoModel] = photosArray.map { photoDictionary in
            
            let photoId = photoDictionary["id"] as? String ?? ""
            let farm = photoDictionary["farm"] as? Int ?? 0
            let secret = photoDictionary["secret"] as? String ?? ""
            let server = photoDictionary["server"] as? String ?? ""
            let title = photoDictionary["title"] as? String ?? ""
            
            let flickrPhoto = PhotoModel(photoId: photoId, farm: farm, secret: secret, server: server, title: title)
            return flickrPhoto
          }
          //print (flickrPhotos)
          completionHandlerForGetPhotos(nil, flickrPhotos)
        }}catch let error as NSError {
          print("Error parsing JSON: \(error)")
          completionHandlerForGetPhotos(error.localizedDescription as! String, nil)
          return
      }
    })
    task.resume()
  }
  
  
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
}
