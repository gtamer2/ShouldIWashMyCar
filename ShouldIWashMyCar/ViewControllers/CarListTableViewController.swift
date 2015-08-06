//
//  CarListTableViewController.swift
//  ShouldIWashMyCar
//
//  Created by Amit Mondal on 7/7/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import CoreLocation

class CarListTableViewController: UITableViewController {
    
    var selectedCar: Car?
    
    @IBOutlet weak var tableViewObj: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewObj.dataSource = self
        tableViewObj.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var cars: Results<Car>!{
        didSet{
            tableViewObj?.reloadData()
        }
    }
    // MARK: - Table view data source
    override func viewWillAppear(animated: Bool){
        let realm = Realm()
        cars = realm.objects(Car).sorted("name", ascending: false)
        super.viewWillAppear(animated)
    }
    
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        let source = segue.sourceViewController as! NewCarViewController
        switch segue.identifier! {
        case "Save":
            let realm = Realm()
            var miles: Int = 0
            if let int = source.milesTextField.text.toInt() {
                miles = int
            }
            let car = Car()
            car.constructCar(source.nameTextField.text, miles: miles, weeklyCommuteDistance: source.commuteDistance, timesPerWeek: source.commuteTimesPerWeek)
            car.commutes.first!.name = source.commuteNameTextField.text
            realm.write(){
                realm.add(car)
            }
        case "NoCommute":
            source.hasLeftController = true
            let realm = Realm()
            let car = Car()
            var miles: Int = 0
            if let int = source.milesTextField.text.toInt() {
                miles = int
            }
            car.constructCar(source.commuteNameTextField.text, miles: miles, weeklyCommuteDistance: 0, timesPerWeek: 0)
            realm.write(){
                realm.add(car)
            }
        case "Cancel":
            source.hasLeftController = true
        default:
            println("Default")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showExistingCar") {
            if let carTabController = segue.destinationViewController as? CarTabBarViewController {
                if let carInfoController = carTabController.viewControllers![0] as? CarInfoViewController, tripListController = carTabController.viewControllers![1] as? TripListViewController{
                    carInfoController.car = self.selectedCar!
                    tripListController.car = self.selectedCar!
                    
                }
                if let maintenanceController = carTabController.viewControllers![2] as? MaintenanceListViewController {
                    maintenanceController.carlist = self
                }
            }
            
        }
    }

}
extension CarListTableViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CarCell", forIndexPath: indexPath) as! CarListTableViewCell //1
        let row = indexPath.row
        let car = cars[row] as Car
        cell.car = car
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(cars?.count ?? 0)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        if Int(cars!.count) == 0 || cars?.count == nil {
            var messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            messageLabel.text = "No Cars"
            messageLabel.textColor = UIColor.grayColor()
            messageLabel.font = UIFont(name: "Helvetica Neue", size: 27)
            messageLabel.numberOfLines = 1
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.sizeToFit()
            self.tableViewObj.backgroundView = messageLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        }
        else {
            self.tableViewObj.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            return 1
        }
        //hi
    }
    
}

extension CarListTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCar = cars[indexPath.row]
        self.performSegueWithIdentifier("showExistingCar", sender: self)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            let car = cars[indexPath.row] as Object
            let realm = Realm()
            realm.write() {
                realm.delete(car)
            }
            cars = realm.objects(Car).sorted("name", ascending: false)
        }
    }

}