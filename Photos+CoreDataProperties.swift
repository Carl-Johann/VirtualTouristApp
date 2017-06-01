//
//  Photos+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by CarlJohan on 09/05/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import CoreData


extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos")
    }

    @NSManaged public var dateTaken: NSDate?
    @NSManaged public var photoURL: String?
    @NSManaged public var pin: Pin?

}
