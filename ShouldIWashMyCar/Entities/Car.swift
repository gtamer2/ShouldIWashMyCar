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
    dynamic var commutes = List<Commute>()
    dynamic var commuteModifiers: Double = 0.0
    let oilChangeConst: Double = 3000
    func constructCar(name: String, miles: Int, weeklyCommuteDistance: Double, timesPerWeek: Int) {
        self.name = name
        self.miles = miles
        self.weeklyCommuteDistance = weeklyCommuteDistance
        let commute = Commute()
        commute.constructCommute(weeklyCommuteDistance, times: timesPerWeek, name: "")
        self.commutes.append(commute)
        self.timesPerWeek = timesPerWeek
    }
    func totalMetersPerWeek() -> Double {
        var result: Double = 0
        for commute in commutes {
            let product: Double = Double(commute.timesPerWeek) * commute.distance
            result += product
        }
        return result
    }
    func addMiles(miles: Double) {
        self.commuteModifiers += miles
    }
}