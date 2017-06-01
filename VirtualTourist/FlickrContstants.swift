//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by CarlJohan on 29/04/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation

extension FlickrClient {

    struct Flickr {
        static let ApiKey = "f86eb120b766b1f7ec940ecc64758e49"
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
    }

    struct FlickrMethods {
        static let photosSearch = "flickr.photos.search"
    }
    
    struct FlickrParameterKeys {
        static let NoJSONCallBack = "nojsoncallback"
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let BoundingBox = "bbox"
        static let Radius = "radius"
        static let PerPage = "per_page"
        static let Latitude = "lat"
        static let Longitude = "lon"
    }
    
    struct FlickrParameterValues {
        static let RadiusSize = "5"
        static let JSONResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let EnableJSONCallBack = "0"
        static let URLMedium = "url_m"
        static let URLSmall = "url_s"
        static let DateTaken = "date_taken"
        static let DateTakenAndUrlSmall = "url_s,date_taken"
        static let NumberOfPhotosPerPage = "25"
    }
    
}
