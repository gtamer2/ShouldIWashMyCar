//
//  Car.swift
//  ShouldIWashMyCar
//
//  Created by Amit Mondal on 7/20/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Car: Object{
    dynamic var name: String = ""
    dynamic var miles: Int = 0
    dynamic var milesSinceCreation: Int = 0
    dynamic var modificationDate = NSDate()
    dynamic var weeklyCommuteDistance: Double = 0
    dynamic var timesPerWeek: Int = 0
    dynamic var trips = List<Trip>()
    let oilChangeConst: Double = 7500
    func constructCar(name: String, miles: Int, weeklyCommuteDistance: Double, timesPerWeek: Int) {
        self.name = name
        self.miles = miles
        self.weeklyCommuteDistance = weeklyCommuteDistance
        self.timesPerWeek = timesPerWeek
    }
    func addTrip(trip: Trip) {
        self.trips.append(trip)
    }
}