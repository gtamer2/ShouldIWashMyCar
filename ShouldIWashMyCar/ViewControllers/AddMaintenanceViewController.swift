//
//  AddMaintenanceViewController.swift
//  ShouldIWashMyCar
//
//  Created by Amit Mondal on 8/6/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class AddMaintenanceViewController: UIViewController {
    @IBOutlet weak var dateViewHeightConstraint: NSLayoutConstraint!
    var car: Car? {
        didSet {
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentedViewChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.animateShowDatePicker(false)
        case 1:
            self.animateShowDatePicker(true)
        default:
            self.animateShowDatePicker(false)
        }
    }
    func animateShowDatePicker(show: Bool) {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            if show && self.dateViewHeightConstraint.constant < 160 {
                self.dateViewHeightConstraint.constant = 160
            }
            else if !show && self.dateViewHeightConstraint.constant > 0{
                self.dateViewHeightConstraint.constant = 0
            }
            self.view.layoutIfNeeded()
        })
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
