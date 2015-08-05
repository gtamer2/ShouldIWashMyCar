//
//  CarListTableViewCell.swift
//  ShouldIWashMyCar
//
//  Created by Amit Mondal on 7/7/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class CarListTableViewCell: UITableViewCell {
    @IBOutlet var carNameLabel: UILabel!
    @IBOutlet weak var carMilesLabel: UILabel!
    @IBOutlet weak var carDistanceLabel: UILabel!

    var car: Car? {
        didSet {
            self.carNameLabel.text = car?.name
            let newMiles: Double = CarInfoViewController.roundToDecimal(CarInfoViewController.metersSinceCreation(self.car!), numberOfDecimals: 1)
            let existingMiles: Double = Double(car!.miles)
            self.carMilesLabel.text = ("Approximate Miles: \(Double(newMiles + existingMiles))")
            var weeklyMeters = self.car?.totalMetersPerWeek()
            self.carDistanceLabel.text = ("Commute Distance: \(round(weeklyMeters! * 0.000621371)) Miles per Week")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
