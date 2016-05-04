//  userSubMenuDisplay.swift
//  Cautionizer
//  Created by Yaro on 4/28/16.
//  Copyright © 2016 Yaro. All rights reserved.

import UIKit
import Parse

protocol userSubMenuDisplayDelegate {
    func menuCloseButtonTapped()
}

class userSubMenuDisplay: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: userSubMenuDisplayDelegate?
    
    @IBAction func subMenuButtonClosed(sender: AnyObject) {
        delegate?.menuCloseButtonTapped()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "backGround.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        
        // no lines where there aren't cells
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // center and scale background image
        imageView.contentMode = .ScaleAspectFit
        
        // blur it
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
    }
    @IBAction func subMenuCloseButton(sender: AnyObject) {
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let index = indexPath.row
        switch (index) {
        case 1:
            goToAnotherScreen("")
        case 0:
            goToAnotherScreen("reportList")
        case 2:
            PFUser.logOut()
            goToAnotherScreen("reportList")
        default: print("he")
        }
    }
    
    func goToAnotherScreen (viewController: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(viewController)
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.backgroundColor = .clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(22)
        cell.layoutMargins = UIEdgeInsetsZero //full line separator
        
        if indexPath.row == 1 {
            cell.textLabel?.text = "My reports"
        } else if indexPath.row == 0 {
            cell.textLabel?.text = "All reports"
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "Log Off"
        }
        
        return cell
    }

}
