//
//  CarInfoViewController.swift
//  ShouldIWashMyCar
//
//  Created by Amit Mondal on 7/24/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import Realm
import RealmSwift

class CarInfoViewController: UIViewController, CLLocationManagerDelegate{
    @IBOutlet weak var distanceLabel: UILabel!

    @IBOutlet weak var oilProgressView: UIProgressView!
    @IBOutlet weak var carNameLabel: UILabel!

    @IBOutlet weak var infoDetailsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var drivingButtonLabel: UIButton!
    @IBOutlet weak var trackButton: UIButton!
    @IBAction func tapTrackButton(sender: UIButton) {
        if sender.selected == false {
            self.locationManager.startUpdatingLocation()
            self.updateLocationInfo()
        }
        else {
            self.locationManager.stopUpdatingLocation()
            if self.distance > minimumValidDriveDistance && self.seconds > minimumValidDriveTime {
                let trip  = Trip()
                trip.constructTrip(self.seconds, distance: self.distance)
                let realm = Realm()
                realm.write(){
                    self.car.trips.append(trip)
                }
            }
            println(self.car.trips.count)
        }
        animateDetailsView(!sender.selected)
        sender.selected = !sender.selected
    }
    static var milesToMeters = 0.000621371
    let minimumValidDriveDistance: Double = 0//1000
    let minimumValidDriveTime: Int = 0//300
    var distance: Double = 0.0
    var speed: Double = 0.0
    var seconds = 0
    
    let speedCutoff: Double = 4.4704 //10 miles per hor
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .AutomotiveNavigation
        _locationManager.distanceFilter = 10
        return _locationManager
    }()
    
    static var dateFormatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    
    lazy var locations: [CLLocation] = []
    lazy var timer = NSTimer()
    var car: Car = Car() {
        didSet {
            self.loadCarInfo()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        self.addBorderToObject(trackButton, radius: 10.0)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadCarInfo()
        self.setUpButton(self.trackButton, selectedText: "Track Trip")
        self.trackButton.setTitle("Stop Tracking", forState: .Selected)
        self.setUpButton(self.drivingButtonLabel, selectedText: "Driving")
        self.drivingButtonLabel.userInteractionEnabled = false
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addBorderToObject(button: UIControl!, radius: CGFloat){
        button.layer.borderWidth = 0.5
        button.layer.borderColor = (UIColor.orangeColor()).CGColor
        button.layer.cornerRadius = radius
    }
    func setUpButton(button: UIButton, selectedText: String) {
        button.setTitle(selectedText, forState: UIControlState.Selected)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.lineBreakMode = NSLineBreakMode.ByClipping
    }
    static func roundToDecimal(double: Double, numberOfDecimals: Double) -> Double{
        let power = pow(10, numberOfDecimals)
        return round(double*power)/power
    }
    func loadCarInfo() {
        if let label = self.carNameLabel {
            label.text = self.car.name
        }
        if let oilProgress = self.oilProgressView {
            let timeInSeconds: NSTimeInterval = (self.car.oilChangeConst/self.car.weeklyCommuteDistance) * 7 * 24 * 60 * 60
            let oilChangeDate: NSDate = self.car.modificationDate.dateByAddingTimeInterval(timeInSeconds)
            
        }
    }
    func updateLocationInfo() {
        seconds = 0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(10,
            target: self,
            selector: "runOnInterval:",
            userInfo: nil,
            repeats: true)
        startLocationUpdates()
    }
    func animateDetailsView(show: Bool) {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            if show {
                self.infoDetailsTopConstraint.constant = 130
            }
            else {
                self.infoDetailsTopConstraint.constant = 30
            }
            self.view.layoutIfNeeded()
        })

    }
}
extension CarInfoViewController {
    func runOnInterval(timer: NSTimer) {
        self.seconds+=5
        let distanceQuantity = distance * 0.000621371 * 10
        self.distanceLabel.text = "Distance: \(round(distanceQuantity)/10) Mi."
    }
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        for location in locations as! [CLLocation] {
            if location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 && location.speed > (self.speedCutoff) {
                    distance += location.distanceFromLocation(self.locations.last)
                    self.drivingButtonLabel.selected = true
                    }
                else {
                    self.drivingButtonLabel.selected = false
                }
                self.locations.append(location)
                println(location.speed)
            }
        }
    }
}