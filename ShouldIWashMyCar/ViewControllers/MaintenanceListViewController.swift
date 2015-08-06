//
//  MaintenanceListViewController.swift
//  ShouldIWashMyCar
//
//  Created by Amit Mondal on 8/6/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class MaintenanceListViewController: UIViewController {
    var carlist: CarListTableViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.parentViewController?.navigationItem.rightBarButtonItem = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "barButtonItemClicked")
        self.parentViewController?.navigationItem.rightBarButtonItem = addButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func barButtonItemClicked() {
        performSegueWithIdentifier("showAddMaintenance", sender: self)
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
