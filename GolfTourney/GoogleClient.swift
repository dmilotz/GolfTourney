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
        guard let results = resultsDictionary else { return }
        print (results)
        if let results = results["results"] as? [[String : AnyObject]]{
        print ("RESULTSSS \(results)")
          if let photoInfo = results[0]["photos"] as? [[String: AnyObject]]{
            print("PHOTO \(photoInfo)")
            if let photoReference = photoInfo[0]["photo_reference"] as? String{
              print("REFEREEEN#################### \(photoReference)")
            }
          }else{
            return
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
}
