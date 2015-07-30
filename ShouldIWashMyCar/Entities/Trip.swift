//
//  Trip.swift
//  ShouldIWashMyCar
//
//  Created by Amit Mondal on 7/29/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Trip: Object {
    dynamic var timeInSeconds: Int = 0
    dynamic var distanceInMeters: Double = 0.0
    dynamic var endDate: NSDate = NSDate()
    func constructTrip(time: Int, distance: Double) {
        self.timeInSeconds = time
        self.distanceInMeters = distance
    }
}