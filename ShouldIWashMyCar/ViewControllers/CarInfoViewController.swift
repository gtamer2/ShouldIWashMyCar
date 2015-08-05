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
import GoogleMaps
import Realm
import RealmSwift
import MapKit

class CarInfoViewController: UIViewController, CLLocationManagerDelegate{
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var oilProgressView: UIProgressView!
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var calculateCommuteHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var enterDistanceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calculateAddCommuteButton: UIButton!
    @IBOutlet weak var enterAddCommuteButton: UIButton!
    @IBOutlet weak var infoDetailsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var drivingButtonLabel: UIButton!
    @IBOutlet weak var trackButton: UIButton!
    @IBOutlet weak var oilDateLabel: UILabel!
    @IBOutlet weak var calculateCommuteSliderLabel: UILabel!
    @IBOutlet weak var enterCommuteSliderLabel: UILabel!
    @IBOutlet weak var calculateCommuteStartTextField: AutoCompleteTextField!
    @IBOutlet weak var calculateCommuteDestinationTextField: AutoCompleteTextField!
    @IBOutlet weak var commuteNameTextField: UITextField!
    @IBOutlet weak var enterDistanceTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    static var metersToMiles = 0.000621371
    static var milesToMeters = (1/CarInfoViewController.metersToMiles)
    let minimumValidDriveDistance: Double = 1000
    let minimumValidDriveTime: Int = 300
    var data: [GMSAutocompletePrediction]? = []
    var placesClient: GMSPlacesClient? = GMSPlacesClient()
    var placesDict = [String : GMSAutocompletePrediction]()
    var distance: Double = 0.0
    var speed: Double = 0.0
    var seconds = 0
    var showsCalculateView: Bool = true
    var isStartField: Bool = false
    var startingPlace: GMSAutocompletePrediction?
    var destinationPlace: GMSAutocompletePrediction?
    var placeIDLookupResult: CLLocationCoordinate2D?
    var placeDistanceLookupResult: Double = 0.0
    var calculateSliderValue: Int = 4
    var enterSliderValue: Int = 4
    var textFields: [UITextField] = []
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
    @IBAction func segmentedControlSwitched(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                self.animateSwitchCommute(true)
            case 1:
                self.animateSwitchCommute(false)
            default:
                self.animateSwitchCommute(true)
        }
    }
    @IBAction func tapTrackButton(sender: UIButton) {
        if !sender.selected {
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
    @IBAction func didChangeCalculatePickerView(sender: UISlider) {
        var currentValue = Int(sender.value * 6) + 1
        self.calculateSliderValue = currentValue
        var sliderText: NSMutableAttributedString = NSMutableAttributedString(string: String(stringInterpolationSegment: currentValue))
        var attributedString = NSAttributedString(string: " days a week")
        sliderText.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: NSMakeRange(0,1))
        calculateCommuteSliderLabel.attributedText = sliderText
    }
    
    @IBAction func didChangeEnterSliderView(sender: UISlider) {
        var currentValue = Int(sender.value * 6) + 1
        self.enterSliderValue = currentValue
        var sliderText: NSMutableAttributedString = NSMutableAttributedString(string: String(stringInterpolationSegment: currentValue))
        var attributedString = NSAttributedString(string: " days a week")
        sliderText.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: NSMakeRange(0,1))
        self.enterCommuteSliderLabel.attributedText = sliderText
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        self.checkExternalTaps()
        self.calculateAddCommuteButton.enabled = false
        self.enterAddCommuteButton.enabled = false
        self.addBorderToObject(trackButton, radius: 10.0)
        self.addBorderToObject(self.calculateAddCommuteButton, radius: 10.0)
        self.addBorderToObject(self.enterAddCommuteButton, radius: 10.0)
        self.setUpAutocompleteTextView(self.calculateCommuteDestinationTextField)
        self.setUpAutocompleteTextView(self.calculateCommuteStartTextField)
        self.textFields = [self.calculateCommuteDestinationTextField, self.calculateCommuteStartTextField, self.commuteNameTextField]
        self.textFields.append(self.commuteNameTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    func keyboardWillShow(sender: NSNotification) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            if(self.view.frame.origin.y > -150) {
                self.view.frame.origin.y -= 150
            }
        })
    }
    func keyboardWillHide(sender: NSNotification) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.frame.origin.y += 150
        })
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
    static func metersSinceCreation(car: Car) -> Double{
        let today = NSDate()
        let creationDate = car.modificationDate
        let weeksSinceCreation: Double = Double(today.timeIntervalSinceDate(creationDate))/60/60/24/7
        let metersFromCommute = car.totalMetersPerWeek()
        var metersFromTrips: Double = 0.0
        for trip in car.trips {
            metersFromTrips += trip.distanceInMeters
        }
        return metersFromCommute + metersFromTrips + car.commuteModifiers
    }
    func loadCarInfo() {
        if let label = self.carNameLabel, let oilDateLabel = self.oilDateLabel {
            label.text = self.car.name
            self.oilDateLabel.text = "Change oil by \(CarInfoViewController.dateFormatter.stringFromDate(self.getMaintenanceDate(self.car.oilChangeConst)))"
        }
        self.setUpProgressBar(self.oilProgressView, constInMiles: self.car.oilChangeConst)
    }
    func setUpProgressBar(progressBar: UIProgressView!, constInMiles: Double) {
        if let progressBar = progressBar {
            let milesSinceCreation: Double = CarInfoViewController.metersSinceCreation(self.car)*CarInfoViewController.metersToMiles
            let progressFloat: Float = Float(milesSinceCreation % constInMiles)
            progressBar.progress = progressFloat/Float(constInMiles)
        }
    }
    func getMaintenanceDate(constInMiles: Double) -> NSDate {
        let remainingMiles: Double = (CarInfoViewController.metersSinceCreation(self.car) % constInMiles) * CarInfoViewController.metersToMiles
        let timeInSeconds: NSTimeInterval = ((constInMiles-remainingMiles)/(self.car.totalMetersPerWeek() * CarInfoViewController.metersToMiles)) * 7 * 24 * 60 * 60
        return NSDate(timeIntervalSinceNow: timeInSeconds)
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
                self.infoDetailsTopConstraint.constant = 80
            }
            self.view.layoutIfNeeded()
        })

    }
    func animateSwitchCommute(showCalculate: Bool) {
        var calculateConstant: CGFloat = 0
        var enterConstant: CGFloat = 127
        self.showsCalculateView = false
        if showCalculate {
            self.showsCalculateView = true
            calculateConstant = 145
            enterConstant = 0
        }
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.calculateCommuteHeightConstraint.constant = calculateConstant
            self.view.layoutIfNeeded()
        })
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.enterDistanceHeightConstraint.constant = enterConstant
            self.view.layoutIfNeeded()
        })
    }
    
}
extension CarInfoViewController {
    func runOnInterval(timer: NSTimer) {
        self.seconds+=10
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
            }
        }
    }
}
//MARK: Calculate Distance Add Commute
extension CarInfoViewController {
    func performMapSearch(searchText: String, textField: AutoCompleteTextField){
        self.data?.removeAll(keepCapacity: false)
        textField.autoCompleteStrings?.removeAll(keepCapacity: false)
        self.placesDict.removeAll(keepCapacity: false)
        let filter = GMSAutocompleteFilter()
        let bounds = GMSCoordinateBounds()
        filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
        if count(searchText) > 0 {
            //println("Searching for '\(searchText)'")
            placesClient?.autocompleteQuery(searchText, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
                if error != nil {
                    println("Autocomplete error \(error) for query '\(searchText)'")
                    return
                }
                //println("Populating results for query '\(searchText)'")
                self.data = [GMSAutocompletePrediction]()
                for result in results! {
                    if let result = result as? GMSAutocompletePrediction {
                        self.data!.append(result)
                        textField.autoCompleteStrings?.append(result.attributedFullText.string)
                        let test = result.attributedFullText.string
                        self.placesDict[test] = result
                    }
                }
            })
        } else {
            self.data = [GMSAutocompletePrediction]()
            textField.autoCompleteStrings = []
        }
    }
    func setUpAutocompleteTextView(field: AutoCompleteTextField){
        field.hidesWhenSelected = true
        field.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        field.maximumAutoCompleteCount = 5
        field.onSelect = {[weak self] text, indexpath in
            field.text = text
            if field == self!.calculateCommuteDestinationTextField {
                self!.view.endEditing(true)
            }
            self!.checkExternalTaps()
            self!.checkCalculateAddCommuteButton()
        }
        
        field.autoCompleteStrings = []
    }
    func textFieldDidChange(textField: AutoCompleteTextField){
        self.stopCheckingExternalTaps()
        if let strings = textField.autoCompleteStrings {
            
        }
        else {
            textField.autoCompleteStrings = []
        }
        if textField.text != "" && textField.text != nil {
            addBorderToObject(textField, radius: 5.0)
        }
        else {
            textField.layer.borderWidth = 0.0
        }
        self.performMapSearch(textField.text, textField: textField)
    }
    func getCoordFromID(placeID: String) -> Void{
        self.placeIDLookupResult = nil
        self.placesClient!.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if error != nil {
                println("lookup place id query error: \(error!.localizedDescription)")
                return
            }
            if let place = place {
                self.placeIDLookupResult = place.coordinate
            } else {
                println("No place details for \(placeID)")
            }
        })
    }
    func checkCalculateAddCommuteButton() {
        var didSetStart = false
        var didSetDestination = false
        if let startAC = placesDict[self.calculateCommuteStartTextField.text] {
            didSetStart = true
            self.startingPlace = startAC
        }
        if let destinationAC = placesDict[self.calculateCommuteDestinationTextField.text] {
            didSetDestination = true
            self.destinationPlace = destinationAC
        }
        if (self.startingPlace != nil && self.destinationPlace != nil && self.commuteNameTextField.text != "" && self.commuteNameTextField != nil){
            self.calculateAddCommuteButton.enabled = true
        }
        else {
            self.calculateAddCommuteButton.enabled = false
        }
    }
    func getRouteDistance(startPoint: CLLocationCoordinate2D, endPoint:CLLocationCoordinate2D) {
        placeDistanceLookupResult = 0
        var directions = MKDirections()
        var route = MKRoute()
        var directionsRequest = MKDirectionsRequest()
        directionsRequest.setSource(MKMapItem(placemark: MKPlacemark(coordinate: startPoint, addressDictionary: nil)))
        directionsRequest.setDestination(MKMapItem(placemark: MKPlacemark(coordinate: endPoint, addressDictionary: nil)))
        directionsRequest.transportType = MKDirectionsTransportType.Automobile
        directionsRequest.requestsAlternateRoutes = true
        directions = MKDirections(request: directionsRequest)
        directions.calculateDirectionsWithCompletionHandler { (response:MKDirectionsResponse?, error:NSError?) -> Void in
            if error == nil {
                route = response?.routes[0] as! MKRoute
                self.placeDistanceLookupResult = (Double(route.distance))
            } else {
                println(error)
            }
        }
    }
    func calculateAddCommute() {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            self.getCoordFromID(self.startingPlace!.placeID)
            while(self.placeIDLookupResult == nil) {
                NSThread.sleepForTimeInterval(0.1)
            }
            let startPoint = self.placeIDLookupResult
            self.getCoordFromID(self.destinationPlace!.placeID)
            while(self.placeIDLookupResult == nil) {
                NSThread.sleepForTimeInterval(0.1)
            }
            let destinationPoint = self.placeIDLookupResult
            self.getRouteDistance(startPoint!, endPoint: destinationPoint!)
            while(self.placeDistanceLookupResult == 0) {
                NSThread.sleepForTimeInterval(0.1)
            }
            let commute = Commute()
            commute.constructCommute(self.placeDistanceLookupResult * CarInfoViewController.milesToMeters, times: self.calculateSliderValue, name: self.commuteNameTextField.text)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let realm = Realm()
                realm.write(){
                    self.car.commutes.append(commute)
                }
                for textField in self.textFields {
                    textField.text = ""
                }
                self.loadCarInfo()
                self.calculateAddCommuteButton.userInteractionEnabled = true
                self.calculateAddCommuteButton.enabled = false
            })
        })
    }
    func checkExternalTaps(){
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "didTapView")
        self.view.addGestureRecognizer(tapRecognizer)
    }
    func didTapView(){
        self.view.endEditing(true)
    }
    func stopCheckingExternalTaps() {
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer as! UIGestureRecognizer)
            }
        }
    }
    @IBAction func didChangeNameField(sender: AnyObject) {
        self.checkCalculateAddCommuteButton()
        self.checkEnterAddCommuteButton()
    }
    @IBAction func didPressCalculateAddCommute(sender: UIButton) {
        self.calculateAddCommute()
        sender.userInteractionEnabled = false
    }
    
}
//MARK: Enter Distance Add Commute
extension CarInfoViewController {
    func enterAddCommute() {
        var commute = Commute()
        var distance: Double = 0.0
        if let distan: Int = self.enterDistanceTextField.text.toInt() {
            distance = Double(distan)
        }
        commute.constructCommute(distance * CarInfoViewController.milesToMeters, times: self.enterSliderValue, name: self.commuteNameTextField.text)
        let realm = Realm()
        realm.write() {
            self.car.commutes.append(commute)
        }
        self.loadCarInfo()
    }
    @IBAction func didPressEnterAddCommute(sender: AnyObject) {
        self.enterAddCommute()
        self.enterDistanceTextField.text = ""
        self.commuteNameTextField.text = ""
    }
    @IBAction func enterCommuteDistanceFieldChanged(sender: UITextField) {
        self.checkEnterAddCommuteButton()
    }
    func checkEnterAddCommuteButton() {
        if self.enterDistanceTextField.text != nil && self.enterDistanceTextField.text != "" && self.commuteNameTextField.text != "" && self.commuteNameTextField != nil{
            self.enterAddCommuteButton.enabled = true
        }
        else {
            self.enterAddCommuteButton.enabled = false
        }
    }
}

