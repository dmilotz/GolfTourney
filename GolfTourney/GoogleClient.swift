//
//  GoogleClient.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 3/8/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation

class GoogleClient{

  static func findPhotos(lat: String, long: String, name: String, completionHandlerForGetPhotos: @escaping (_ error: String?, String?) -> Void) {
    
    let formattedName = name.replacingOccurrences(of: " ", with: "+")
    let url = Constants.googleApiUrl + formattedName + Args.location + lat + "," + long + Args.radius + Args.apiKey
    
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
        guard let results = resultsDictionary else {     completionHandlerForGetPhotos(error?.localizedDescription, nil)
        return}
        print (results)
        if let results = results["results"] as? [[String : AnyObject]]{
        print ("RESULTSSS \(results)")
          if let photoInfo = results[0]["photos"] as? [[String: AnyObject]]{
            print("PHOTO \(photoInfo)")
            if let photoReference = photoInfo[0]["photo_reference"] as? String{
              print("REFEREEEN#################### \(photoReference)")
              let photoUrl = Constants.googlePhotoUrl + photoReference + Args.apiKey
              completionHandlerForGetPhotos(nil, photoUrl)
            }
          }else{
            completionHandlerForGetPhotos(error?.localizedDescription, nil)
          }
        //let reference = photoInfo[0]["photo_reference"]
        //print("REference \(reference)")
        }
        }catch let error as NSError {
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
