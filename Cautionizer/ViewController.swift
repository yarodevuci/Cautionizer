//
//  ViewController.swift
//  Cautionizer
//
//  Created by Yaro on 4/26/16.
//  Copyright © 2016 Yaro. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle { return UIStatusBarStyle.LightContent }
    
    @IBOutlet weak var backGroundImage: UIImageView!
    var hazardInfoArray = [PFObject]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.whiteColor() //makes refresh activity indicator white
        refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
            loadData()
            refreshControl.endRefreshing()
    }
    
    func loadData() {
        
        let loadData:PFQuery = PFQuery(className: "Data")
        loadData.orderByDescending("createdAt")
            animateHUD("Loading Reports", detailsLabel: "Please Wait")
        
        loadData.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if error == nil {
                
                    self.hazardInfoArray = objects!
                    self.hazardListTableView.reloadData()
            } else { print("nothing to load") }
        }
    }
    
    @IBOutlet weak var hazardListTableView: UITableView!
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return hazardInfoArray.count }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)  {
        
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            var selectedQuoteFromFavourites:PFObject = hazardInfoArray[indexPath.row] as PFObject
            selectedQuoteFromFavourites.deleteInBackground()
            self.hazardInfoArray.removeAtIndex(indexPath.row)
            self.hazardListTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = hazardListTableView.dequeueReusableCellWithIdentifier("hazardViewCell", forIndexPath: indexPath) as! hazardViewCell
        
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

    @IBAction func reportNewHazard(sender: AnyObject) {
        let user = PFUser.currentUser()
        if ((user?.username) == nil) {
            dispatch_async(dispatch_get_main_queue()) {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let main: UIViewController = storyBoard.instantiateViewControllerWithIdentifier("LoginDisplay")
                self.presentViewController(main, animated: true, completion: nil)
            }
        }
        else {
                dispatch_async(dispatch_get_main_queue()) {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let main: UIViewController = storyBoard.instantiateViewControllerWithIdentifier("mainMenu")
                self.presentViewController(main, animated: true, completion: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hazardListTableView.addSubview(self.refreshControl)
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: "BlurImage.png")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.hazardListTableView.backgroundView = imageViewBackground
        
        // no lines where there aren't cells
        hazardListTableView.tableFooterView = UIView(frame: CGRectZero)
    }
}

