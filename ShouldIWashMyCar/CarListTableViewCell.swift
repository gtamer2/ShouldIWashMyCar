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
            self.carMilesLabel.text = ("Approximate Miles: \(car!.miles)")
            self.carDistanceLabel.text = ("Commute Distance: \(round(car!.weeklyCommuteDistance * 0.000621371)) Miles")
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
