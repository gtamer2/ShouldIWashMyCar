//
//  NewCarViewController.swift
//  ShouldIWashMyCar
//
//  Created by Amit Mondal on 7/7/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class NewCarViewController: UIViewController {

    @IBOutlet weak var milesTextField: UITextField!
    @IBOutlet weak var mapView: GMSMapView!

    //@IBOutlet weak var datePickerView: UIPickerView!
    @IBOutlet weak var destinationTextField: AutoCompleteTextField!
    @IBOutlet weak var startTextField: AutoCompleteTextField!
    @IBOutlet weak var commuteView: UIView!
    @IBOutlet weak var yesCommuteButton: UIButton!
    @IBOutlet weak var noCommuteButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var datePickerDataSource: [String] = []
    var locationManager: CLLocationManager? = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var data: [GMSAutocompletePrediction]?
    var placesDict = [String : GMSAutocompletePrediction]()
    var startMarker: GMSMarker = GMSMarker()
    var destinationMarker: GMSMarker = GMSMarker()
    let placesClient: GMSPlacesClient! = GMSPlacesClient()
    var bounds = GMSCoordinateBounds()
    var path = GMSMutablePath()
    var isStartMarker: Bool = true
    var doesCommute: Bool = false
    var hasLeftController: Bool = false

    
    @IBAction func pressYesCommute(sender: AnyObject) {
        doesCommute = true
        if(commuteView.hidden){
            commuteView.hidden = false
            if let locationManager = locationManager {
                locationManager.startUpdatingLocation()
            }
        }
        self.view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commuteView.hidden = true
        checkSaveButton()
        addBorderToObject(yesCommuteButton, radius: 10)
        addBorderToObject(noCommuteButton, radius: 10)
        addBorderToObject(startTextField, radius: 5)
        addBorderToObject(destinationTextField, radius: 5)
        self.setUpAutocompleteTextView(startTextField)
        self.setUpAutocompleteTextView(destinationTextField)
        fillPickerDataSource()
        //datePickerView.dataSource = self
        //datePickerView.delegate = self
        setUpLocationManager()
        createLocationManager()
        checkLocationAuthorizationStatus()
        checkExternalTaps()
        //self.mapView.showsUserLocation = true
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        self.nameTextField.becomeFirstResponder()
        self.startTextField.returnKeyType = .Search
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
    
    func displayAlert(string: String){
        var alert = UIAlertController(title: "Empty Field", message: string, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func checkSaveButton(){
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            var hasName: Bool = false
            var hasMiles = false
            var hasStartMarker = false
            var hasDestinationMarker = false
            while !hasName || !hasMiles || !hasStartMarker || !hasDestinationMarker {
                if self.hasLeftController {
                    break
                }
                hasName = !(count(self.nameTextField.text) <= 0 || self.nameTextField.text == nil)
                hasMiles = !(count(self.milesTextField.text) <= 0 || self.milesTextField.text == nil)
                hasStartMarker = !(self.startMarker.title == nil)
                hasDestinationMarker = !(self.destinationMarker.title == nil)
                if self.saveButton.enabled {
                    self.saveButton.enabled = false
                }
                NSThread.sleepForTimeInterval(0.75)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if !self.hasLeftController {
                    self.saveButton.enabled = true
                }
            })
        })
    }

    
    func fillPickerDataSource(){
        for index in 1...7 {
            datePickerDataSource.append(String(index))
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
//MARK:Picker View
/*
extension NewCarViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datePickerDataSource.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return datePickerDataSource[row]
        
    }

}
*/
//MARK:Location Manager
extension NewCarViewController: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        currentLocation = locValue
        let northEast = CLLocationCoordinate2DMake(currentLocation!.latitude + 0.1, currentLocation!.longitude + 1)
        let southWest = CLLocationCoordinate2DMake(currentLocation!.latitude - 0.1, currentLocation!.longitude - 1)
        bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        //self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(locValue, zoom: 10.0))
        self.mapView.camera = self.mapView.cameraForBounds(self.bounds, insets:UIEdgeInsetsZero)
        locationManager?.stopUpdatingLocation()
    }
    func createLocationManager () {
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.distanceFilter = kCLDistanceFilterNone
    }
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.myLocationEnabled = true
        } else {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
}


//MARK: MapView
extension NewCarViewController: GMSMapViewDelegate{
    func setUpLocationManager(){
        self.mapView.delegate = self
        self.mapView.settings.myLocationButton = true
    }
    func refreshMapView(){
        self.mapView.animateToCameraPosition(mapView.cameraForBounds(self.bounds.includingPath(path), insets: UIEdgeInsetsMake(30,30,30,30)))
    }
}


//MARK:Text Field Polish
extension NewCarViewController{
    func checkExternalTaps(){
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "didTapView")
        self.view.addGestureRecognizer(tapRecognizer)
    }
    func didTapView(){
        self.view.endEditing(true)
    }
}


//MARK:GMSMapView Search
extension NewCarViewController{
    func getCoordFromID(placeID: String) -> Void{
        self.placesClient!.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if error != nil {
                println("lookup place id query error: \(error!.localizedDescription)")
                return
            }
            if let place = place {
                if self.isStartMarker {
                    self.startMarker.position = place.coordinate
                    self.setUpMarker(self.startMarker)
                }
                else if !self.isStartMarker {
                    self.destinationMarker.position = place.coordinate
                    self.setUpMarker(self.destinationMarker)
                }
                self.path.addCoordinate(place.coordinate)
                self.refreshMapView()
                println(self.path.count())
            } else {
                println("No place details for \(placeID)")
            }
        })
    }
    
    func setUpMarker(marker: GMSMarker){
        marker.map = mapView!
        if self.isStartMarker {
            marker.title = "Start"
        }
        else {
            marker.title = "Destination"
        }
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = GMSMarker.markerImageWithColor(UIColor.orangeColor())
        marker.opacity = 1
        
    }
    
    func setUpAutocompleteTextView(field: AutoCompleteTextField){
        field.hidesWhenSelected = true
        field.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        field.maximumAutoCompleteCount = 5
        field.onSelect = {[weak self] text, indexpath in
            field.text = text
            if field == self!.startTextField {
                self!.isStartMarker = true
                if let place = self!.placesDict[text] {
                    self!.getCoordFromID(place.placeID)
                }
                else {
                    println("Place not in dictionary")
                }
            }
            else {
                self!.isStartMarker = false
                if let place = self!.placesDict[text] {
                    self!.getCoordFromID(place.placeID)
                }
                else{
                    println("Place not in dictionary")
                }
            }
            self!.view.endEditing(true)

        }
        field.autoCompleteStrings = []
    }
    
    func performMapSearch(searchText: String, textField: AutoCompleteTextField){
        self.data?.removeAll(keepCapacity: false)
        textField.autoCompleteStrings?.removeAll(keepCapacity: false)
        self.placesDict.removeAll(keepCapacity: false)
        let filter = GMSAutocompleteFilter()
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
                //self.tableView.reloadData()
            })
        } else {
            self.data = [GMSAutocompletePrediction]()
            textField.autoCompleteStrings = []
        }
    }
    
    func textFieldDidChange(textField: AutoCompleteTextField){
        if let strings = textField.autoCompleteStrings {
            //DO NOTHING
        }
        else {
            textField.autoCompleteStrings = []
        }
        self.performMapSearch(textField.text, textField: textField)
    }
}