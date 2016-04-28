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
    
    var hazardInfoArray = [PFObject]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
            loadData()
            refreshControl.endRefreshing()
    }
    
    func loadData() {
        
        hazardInfoArray.removeAll()
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return hazardInfoArray.count
    }
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
        let userCell = hazardListTableView.dequeueReusableCellWithIdentifier("hazardViewCell", forIndexPath: indexPath) as! hazardViewCell
        
        let hazardDataObject: PFObject = self.hazardInfoArray[indexPath.row] as PFObject
        userCell.userLabel?.text  = hazardDataObject.objectForKey("Location") as? String
        let timeStamp: String = (hazardDataObject.objectForKey("timeStamp") as? String)!
        userCell.timeStamp?.text = "Submittted: " + timeStamp
        userCell.descriptionLabel.text = hazardDataObject.objectForKey("hazardInfo") as? String
        
        
        //Load images
        if (hazardDataObject.objectForKey("hazard_image") != nil) {
        
            let providerLicenseImageFile: PFFile = hazardDataObject.objectForKey("hazard_image") as! PFFile
            providerLicenseImageFile.getDataInBackgroundWithBlock({(imageData: NSData?, error: NSError?) -> Void in
                
                if(imageData != nil) { userCell.hazardImage.image = UIImage(data: imageData!) }
            })
        } else { userCell.hazardImage.image = UIImage(named: "no_image") }
        
           return userCell
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
        
        self.hazardListTableView.addSubview(self.refreshControl)
       
        loadData()
          }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

