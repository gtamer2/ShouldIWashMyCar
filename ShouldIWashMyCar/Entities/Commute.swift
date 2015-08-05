//
//  Commute.swift
//  ShouldIWashMyCar
//
//  Created by Amit Mondal on 7/31/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Commute: Object {
    dynamic var distance: Double = 0
    dynamic var timesPerWeek: Int = 0
    dynamic var name: String = ""
    func constructCommute(distance: Double, times: Int, name: String) {
        self.distance = distance
        self.timesPerWeek = times
        self.name = name
    }
}