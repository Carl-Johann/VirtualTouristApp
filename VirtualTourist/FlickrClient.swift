//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by CarlJohan on 27/04/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation


struct FlickrClient {
    
    let session = URLSession.shared
    //let photos = [String]
    
    func getImagesForPin(_ Latitude: Double,_ Longitude: Double,_ numberOfPicturesToDownload: Int = 25, CHForImagesForPin: @escaping (_ data: [[String:AnyObject]],_ succes: Bool) -> Void) {
        
        let parameters = [
            FlickrParameterKeys.Method:FlickrMethods.photosSearch,
            FlickrParameterKeys.APIKey:Flickr.ApiKey,
            FlickrParameterKeys.Radius:FlickrParameterValues.RadiusSize,
            FlickrParameterKeys.Latitude:Latitude,
            FlickrParameterKeys.Longitude:Longitude,
            FlickrParameterKeys.Format:FlickrParameterValues.JSONResponseFormat,
            FlickrParameterKeys.NoJSONCallBack:FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.Extras:FlickrParameterValues.DateTakenAndUrlSmall,
            FlickrParameterKeys.PerPage:numberOfPicturesToDownload
        ] as [String : AnyObject]
        
        
        let request = URLRequest(url: flickrURLFromParameters(parameters))
        
        let task = self.session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { print("error: \(error!)"); return }
            
            
            let parsedResult = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
          
            guard let results = parsedResult["photos"] as? [String:AnyObject] else {
                print("ERROR: FlickrClient. Couldn't find 'photos' in 'parsedResult'")
                CHForImagesForPin([[:]], false)
                return
            }
            guard let photos = results["photo"] as? [[String:AnyObject]] else {
                print("ERROR: FlickrClient. Couldn't find 'photo' in 'results'")
                CHForImagesForPin([[:]], false)
                return
            }
            CHForImagesForPin(photos, true)
        }
        task.resume()
        
        
    }
    
    
    
    
    func flickrURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Flickr.APIScheme
        components.host = Flickr.APIHost
        components.path = Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
            
        }
        
        return components.url!
    }
    
    
    static let sharedInstance = FlickrClient()
}
