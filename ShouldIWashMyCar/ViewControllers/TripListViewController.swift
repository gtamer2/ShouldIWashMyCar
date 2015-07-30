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
    var car: Car = Car() {
        didSet {
            if let tableView = self.tableView {
                self.tableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
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
        let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) as! TripTableViewCell
        let row = indexPath.row
        let trip = self.car.trips[row]
        cell.trip = trip
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(self.car.trips.count)
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        if Int(self.car.trips.count) == 0 {
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
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            return 1
        }
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            let realm = Realm()
            realm.write {
                self.car.trips.removeAtIndex(indexPath.row)
                self.tableView.reloadData()
            }
        }
    }
}
