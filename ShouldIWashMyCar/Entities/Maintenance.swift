//
//  File.swift
//  ShouldIWashMyCar
//
//  Created by Amit Mondal on 8/6/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import RealmSwift
import Foundation
class Maintenance: Object {
    dynamic var maintenanceDescription: String = ""
    dynamic var cost: Double = 0.0
    dynamic var shop: String = ""
    dynamic var date: NSDate = NSDate()
    func constructMaintenance(description: String, cost: Double, shop: String, date: NSDate) {
        self.maintenanceDescription = description
        self.cost = cost
        self.shop = shop
        self.date = date
    }
}