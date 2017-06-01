//
//  Pin.swift
//  VirtualTourist
//
//  Created by CarlJohan on 30/04/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import CoreData

class MapPin: Pin {
    
    convenience init ( latitude: Double, longitude: Double, context: NSManagedObjectContext ) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            
        } else {
            fatalError("ERROR. Pin. No NSEntityDescription matching 'Pin'")
        }
    }
    
}
