//
//  User+Extensions.swift
//  HomeHarbor
//
//  Created by Amulya Gangam on 1/23/24.
//

import Foundation
import CoreData

extension User {
    var userTypeEnum: SplitWise.UserType? {
        get {
            guard let userType = userType else { return nil }
            return SplitWise.UserType(rawValue: userType)
        }
        set {
            userType = newValue?.rawValue
        }
    }
}
