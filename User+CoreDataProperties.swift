//
//  User+CoreDataProperties.swift
//  
//
//  Created by Amulya Gangam on 1/31/24.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var rent: String?
    @NSManaged public var userType: String?
    @NSManaged public var utilities: String?
    @NSManaged public var due: Date?

}
