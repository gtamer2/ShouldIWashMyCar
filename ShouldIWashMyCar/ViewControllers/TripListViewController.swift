//
//  TripListViewController.swift
//  ShouldIWashMyCar
//
//  Created by Amit Mondal on 7/29/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import RealmSwift

class TripListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var sections: [String] = ["Weekly Commutes", "Tracked Trips"]
    var car: Car = Car() {
        didSet {
            if let tableView = self.tableView {
                self.tableView.reloadData()
            }
        }
    }
    var trips: [Trip] = []
    var commutes: [Commute] = []
    var sectionsDictionary: [String: [Object]] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        for trip in self.car.trips {
            self.trips.append(trip)
        }
        for commute in self.car.commutes {
            self.commutes.append(commute)
        }
        self.sectionsDictionary["Weekly Commutes"] = self.commutes
        self.sectionsDictionary["Tracked Trips"] = self.trips
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension TripListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sectionTitle = self.sections[indexPath.section]
        let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) as! TripTableViewCell
        let row = indexPath.row
        if sectionTitle == "Weekly Commutes" {
            cell.commute = self.commutes[row]
        }
        else {
            let trip = self.trips[row]
            cell.trip = trip
        }
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){return self.commutes.count}
        else {return self.trips.count}
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        if Int(self.trips.count + self.commutes.count) == 0 {
            var messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            messageLabel.text = "No Trips Tracked"
            messageLabel.textColor = UIColor.grayColor()
            messageLabel.font = UIFont(name: "Helvetica Neue", size: 24)
            messageLabel.numberOfLines = 1
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        }
        else {
            self.tableView.backgroundView = nil
            //self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            return self.sections.count
        }
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            let realm = Realm()
            if indexPath.section == 1 {
                realm.write {
                    self.car.trips.removeAtIndex(indexPath.row)
                }
                self.tableView.reloadData()
            }
            else {
                realm.write {
                    self.car.commutes.removeAtIndex(indexPath.row)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if(title == "Weekly Commutes") {return 0}
        else {return 1}
    }
}
