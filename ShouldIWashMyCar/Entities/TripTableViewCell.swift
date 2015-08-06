//
//  TripTableViewCell.swift
//  ShouldIWashMyCar
//
//  Created by Amit Mondal on 7/29/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class TripTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tripDistanceLabel: UILabel!
    @IBOutlet weak var tripEndDateLabel: UILabel!
    @IBOutlet weak var tripTimeLabel: UILabel!
    var trip: Trip? {
        didSet {
            displayTripInfo()
        }
    }
    var commute: Commute? {
        didSet {
            displayCommuteInfo()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func displayTripInfo() {
        if let trip = self.trip, distanceLabel = tripDistanceLabel, dateLabel = self.tripEndDateLabel, timeLabel = self.tripTimeLabel{
            let distanceInMiles = trip.distanceInMeters * CarInfoViewController.metersToMiles
            let distanceDisplayQuantity = CarInfoViewController.roundToDecimal(distanceInMiles, numberOfDecimals: 1)
            distanceLabel.text = "\(distanceDisplayQuantity) Miles"
            dateLabel.text = CarInfoViewController.dateFormatter.stringFromDate(trip.endDate)
            let timeInHours: Double = Double(trip.timeInSeconds/3600)
            let timeDisplayQuantity = CarInfoViewController.roundToDecimal(timeInHours, numberOfDecimals: 1.0)
            timeLabel.text = ("\(timeDisplayQuantity) Hours")
        }
    }
    func displayCommuteInfo() {
        if let commute = self.commute {
            self.tripDistanceLabel.text = commute.name
            var distanceInMiles = commute.distance * CarInfoViewController.metersToMiles
            println(distanceInMiles)
            self.tripEndDateLabel.text = ("\(round(distanceInMiles)) Miles One Way")
            self.tripTimeLabel.text = ("\(commute.timesPerWeek) Time(s) Per Week")
        }
    }
}

