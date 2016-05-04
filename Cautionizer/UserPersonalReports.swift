//
//  UserPersonalReports.swift
//  Cautionizer
//
//  Created by Yaro on 5/3/16.
//  Copyright © 2016 Yaro. All rights reserved.
//

import UIKit
import Parse

class UserPersonalReports: UIViewController, UITableViewDataSource, UITableViewDelegate, userSubMenuDisplayDelegate {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle { return UIStatusBarStyle.LightContent }
    var blackMaskView = UIView(frame: CGRectZero)

    @IBOutlet weak var userReportsTableView: UITableView!
    let menuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("userSubMenuDisplay") as! userSubMenuDisplay
    
    var hazardInfoArray = [PFObject]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.whiteColor() //makes refresh activity indicator white
        refreshControl.addTarget(self, action: #selector(UserPersonalReports.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        loadData()
        refreshControl.endRefreshing()
    }
    //Constraint (Used animate menu in/out)
    var menuLeftConstraint: NSLayoutConstraint?
    
    var isShowingMenu = false
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            if isShowingMenu == false {
                toogleMenu()
            }
        }
        
        if (sender.direction == .Right) {
            if isShowingMenu == true {
                toogleMenu()
            }
        }
    }
    

    func loadData() {
        let user: String = (PFUser.currentUser()?.username)!
        
        let loadData:PFQuery = PFQuery(className: "Data")
        loadData.whereKey("reportedBy", equalTo: user)
        loadData.orderByDescending("createdAt")
        animateHUD("Loading Reports", detailsLabel: "Please Wait")
        
        loadData.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if error == nil {
                if objects?.count == 0 {
                   JSSAlertView().danger(self, title: "Ooops!", text: "You don't have any reports yet", buttonText:"OK")
                }
                self.hazardInfoArray = objects!
                self.userReportsTableView.reloadData()
            } else { print("nothing to load") }
        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return hazardInfoArray.count }
    //Users can delete their posts
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)  {
        
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            let userData:PFObject = hazardInfoArray[indexPath.row] as PFObject
            userData.deleteInBackground()
            self.hazardInfoArray.removeAtIndex(indexPath.row)
            self.userReportsTableView.reloadData()
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = userReportsTableView.dequeueReusableCellWithIdentifier("hazardViewCell", forIndexPath: indexPath) as! hazardViewCell
        
        cell.backgroundColor = .clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(22)
        cell.layoutMargins = UIEdgeInsetsZero //full line separator
        
        let hazardDataObject: PFObject = self.hazardInfoArray[indexPath.row] as PFObject
        cell.userLabel?.text  = hazardDataObject.objectForKey("Location") as? String
        let timeStamp: String = (hazardDataObject.objectForKey("timeStamp") as? String)!
        cell.timeStamp?.text = "Submittted: " + timeStamp
        cell.descriptionLabel.text = hazardDataObject.objectForKey("hazardInfo") as? String
        
        let MHFacebookImageViewerInstance: MHFacebookImageViewer = MHFacebookImageViewer();
        
        //Load images
        if (hazardDataObject.objectForKey("hazard_image") != nil) {
            
            let providerLicenseImageFile: PFFile = hazardDataObject.objectForKey("hazard_image") as! PFFile
            providerLicenseImageFile.getDataInBackgroundWithBlock({(imageData: NSData?, error: NSError?) -> Void in
                
                if(imageData != nil) {
                    cell.hazardImage.image = UIImage(data: imageData!)
                    cell.hazardImage.setupImageViewerWithDatasource(MHFacebookImageViewerInstance.imageDatasource, onOpen: { },
                        onClose: { })
                }
            })
        } else { cell.hazardImage.image = UIImage(named: "no_image") }
        
        return cell
    }
    
    func animateHUD (labelText: String, detailsLabel: String) {
        let spinAct = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        spinAct.activityIndicatorColor = UIColor.whiteColor()
        spinAct.label.text = labelText
        spinAct.detailsLabel.textColor = UIColor.whiteColor()
        spinAct.detailsLabel.text = detailsLabel
        spinAct.label.textColor = UIColor.whiteColor()
        spinAct.bezelView.color = UIColor.blackColor()
        //MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userReportsTableView.addSubview(self.refreshControl)
        loadData()
        
        //Swipe Guestures
        let leftSwipe = UISwipeGestureRecognizer(target: self, action:#selector(reportInitialScreen.handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(reportInitialScreen.handleSwipes(_:)))
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        addChildViewController(menuViewController)
        menuViewController.delegate = self
        menuViewController.didMoveToParentViewController(self)
        menuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuViewController.view)
        
        let topConstraint = NSLayoutConstraint(item: menuViewController.view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        
        let bottomConstraint = NSLayoutConstraint(item: menuViewController.view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        let widthConstraint = NSLayoutConstraint(item: menuViewController.view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 250)
        
        menuLeftConstraint = NSLayoutConstraint(item: menuViewController.view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: -widthConstraint.constant)
        
        view.addConstraints([topConstraint, menuLeftConstraint!, bottomConstraint, widthConstraint])
        
        toogleMenu()
        
    }
    
    func toogleMenu() {
        isShowingMenu = !isShowingMenu
        
        if(isShowingMenu) {
            //Hide Menu
            
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
            
            menuLeftConstraint?.constant = -menuViewController.view.bounds.size.width
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (completed) -> Void in
                    self.menuViewController.view.hidden = true
            })
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.blackMaskView.alpha = 0.0
                }, completion: { (completed) -> Void in
                    self.blackMaskView.removeFromSuperview()
            })
            
        } else {
            //Present Menu
            
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
            
            blackMaskView = UIView(frame: CGRectZero)
            blackMaskView.alpha = 0.0
            blackMaskView.translatesAutoresizingMaskIntoConstraints = false
            blackMaskView.backgroundColor = UIColor.blackColor()
            view.insertSubview(blackMaskView, belowSubview: menuViewController.view)
            
            let topConstraint = NSLayoutConstraint(item: blackMaskView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            
            let bottomConstraint = NSLayoutConstraint(item: blackMaskView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            
            let leftConstraint = NSLayoutConstraint(item: blackMaskView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
            
            let rightConstraint = NSLayoutConstraint(item: blackMaskView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
            
            view.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
            view.layoutIfNeeded()
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.blackMaskView.alpha = 0.5
                }, completion: { (completed) -> Void in
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(reportInitialScreen.tapGestureRecognized))
                    self.blackMaskView.addGestureRecognizer(tapGesture)
            })
            
            menuViewController.view.hidden = false
            menuLeftConstraint?.constant = 0
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (completed) -> Void in
                    
            })
        }
    }
    
    @IBAction func subMenuPressed(sender: AnyObject) {
        toogleMenu()
    }
    
    func tapGestureRecognized() {
        toogleMenu()
    }
    func menuCloseButtonTapped() {
        toogleMenu()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "BlurImage.png")
        let imageView = UIImageView(image: backgroundImage)
        self.userReportsTableView.backgroundView = imageView
        
        // no lines where there aren't cells
        userReportsTableView.tableFooterView = UIView(frame: CGRectZero)
        
        // center and scale background image
        imageView.contentMode = .ScaleAspectFit
    }
    
}
