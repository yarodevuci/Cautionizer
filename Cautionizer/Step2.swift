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
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var sub1: UIButton!
    @IBOutlet weak var sub2: UIButton!
    @IBOutlet weak var sub3: UIButton!
    @IBOutlet weak var sub4: UIButton!
    
    var open: Bool = false
    var showimage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWithSubBtns.hidden = true
    }
    
    func moveBTN () {
        btn2.frame.origin = CGPoint(x: 10, y: 430)
        btn3.frame.origin = CGPoint(x: 10, y: 500)
        
    }
    
    @IBAction func sub1Clicked(sender: AnyObject) {
        viewWithSubBtns.hidden = true
        btn2.hidden = true
        btn3.hidden = true
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
            btn3.frame.origin = CGPoint(x: 10, y: 270)
        }
    }
    @IBAction func btn2Clicked(sender: AnyObject) {
        open = false
        viewWithSubBtns.hidden = true
        btn2.frame.origin = CGPoint(x: 10, y: 200)
        btn3.frame.origin = CGPoint(x: 10, y: 270)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

