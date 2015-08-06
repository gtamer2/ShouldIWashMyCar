//
//  CarTabBarViewController.swift
//  ShouldIWashMyCar
//
//  Created by Amit Mondal on 7/24/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class CarTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.title = "Car Info"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if viewController is CarInfoViewController {
            self.navigationItem.title = "Car Info"
        }
        else if viewController is TripListViewController {
            self.navigationItem.title = "Commutes/Trips"
        }
        else if viewController is MaintenanceListViewController {
            self.navigationItem.title = "Maintenance"
        }
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
