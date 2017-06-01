//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by CarlJohan on 29/05/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var imageURL: String?
    @NSManaged public var pin: Pin?

}
