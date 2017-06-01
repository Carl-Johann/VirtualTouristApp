//
//  FlickrPin.swift
//  VirtualTourist
//
//  Created by CarlJohan on 30/04/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import CoreData



class PinPhotos: Photos {
    
    convenience init ( photoURL: String, context: NSManagedObjectContext ) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photos", in: context) {
            self.init(entity: ent, insertInto: context)
            self.photoURL = photoURL
        } else {
            fatalError("ERROR. FlickrPin. No NSEntityDescription matching 'Photos'")
        }
    }
}


/*
        self.init()
        
        guard let ent = NSEntityDescription.entity(forEntityName: "Photos", in: context) else {
            print("ERROR. FlickrPin. No NSEntityDescription matching 'Photos'")
            return
        }
        
        self.init(entity: ent, insertInto: context)
        self.dateTaken = NSDate()
        self.photoURL = photoURL
        
        
         let photo = Photos(entity: ent!, insertIntoManagedObjectContext: context)
         self.entity. = ent
         
         self.dateTaken = NSDate()
         self.photoURL = photoURL
        
    
    
    }*/
//}
/*  var title: String? = ""
 var height: Int? = 0
 var width: Int? = 0
 var url: String? = ""
 
 init(dictionary: [String:AnyObject]) {
 if let title = dictionary["title"] as? String { self.title = title }
 if let height = dictionary["height_m"] as? Int { self.height = height }
 if let width = dictionary["width_m"] as? Int { self.width = width }
 if let url = dictionary["url_m"] as? String { self.url = url }
 
 }
 
 static func dataFromStudents(_ results: [[String:AnyObject]]) -> [FlickrPinPhotos] {
 
 var PinData = [FlickrPinPhotos]()
 
 for result in results { PinData.append(FlickrPinPhotos(dictionary: result)) }
 
 return PinData
 }
 }*/
