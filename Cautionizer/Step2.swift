//
//  Step2.swift
//  Cautionizer
//
//  Created by Yaro on 4/26/16.
//  Copyright © 2016 Yaro. All rights reserved.
//

import UIKit

class Step2: UIViewController {
    
    @IBOutlet weak var virtualProgress: UIImageView!
    @IBOutlet weak var viewWithSubBtns: UIView!
    
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var sub1: UIButton!
    @IBOutlet weak var sub2: UIButton!
    @IBOutlet weak var sub3: UIButton!
    @IBOutlet weak var sub4: UIButton!
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "exteriorPath" {
            if let destination: SubmitReportScreen = segue.destinationViewController as? SubmitReportScreen {
                 destination.headerText = "Exterior Blocked Path" }
            }
                else if segue.identifier == "interiorBlockedPath" {
                    if let destination: SubmitReportScreen = segue.destinationViewController as? SubmitReportScreen {
                destination.headerText = "Interior Blocked Path" }
        }
        else if segue.identifier == "contDebris" {
            if let destination: SubmitReportScreen = segue.destinationViewController as? SubmitReportScreen {
                destination.headerText = "Construction Debris" }
        }
        else if segue.identifier == "animal" {
            if let destination: SubmitReportScreen = segue.destinationViewController as? SubmitReportScreen {
                destination.headerText = "Animal-Related" }
        }
        else if segue.identifier == "accidents" {
            if let destination: SubmitReportScreen = segue.destinationViewController as? SubmitReportScreen {
                destination.headerText = "Accident" }
        }
    }
    
    
    
    var open: Bool = false
    var showimage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWithSubBtns.hidden = true
    }
    
    func moveBTN () {
        btn2.frame.origin = CGPoint(x: 10, y: 430)
    }
    
    @IBAction func sub1Clicked(sender: AnyObject) {
        viewWithSubBtns.hidden = true
        btn2.hidden = true
        btn1.hidden = true
    }
    @IBAction func btnClicked(sender: AnyObject) {
        
        if (!open) {
        
            self.moveBTN()
            self.viewWithSubBtns.hidden = false
            open = true
        }
        else {
            open = false

            viewWithSubBtns.hidden = true
            btn2.frame.origin = CGPoint(x: 10, y: 200)
        }
    }
    @IBAction func btn2Clicked(sender: AnyObject) {
        open = false
        viewWithSubBtns.hidden = true
        btn2.frame.origin = CGPoint(x: 10, y: 200)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

