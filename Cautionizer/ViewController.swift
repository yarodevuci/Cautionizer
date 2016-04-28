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
    
    
    var array = [String]()
    var dataStamp = [String]()
    var descriptionHazard = [String]()
    
    
    func loadData() {
        
        array.removeAll()
        
        let findTweets:PFQuery = PFQuery(className: "Data")
        
        findTweets.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                for data in objects! {
                    self.array.append(data["Location"] as! String)
                    self.dataStamp.append(data["timeStamp"] as! String)
                    self.descriptionHazard.append(data["hazardInfo"] as! String)
                    self.hazardListTableView.reloadData()
                }
            }
                
             else { print("nothing to load") }
        }
    }
    
    @IBOutlet weak var hazardListTableView: UITableView!
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let userCell = hazardListTableView.dequeueReusableCellWithIdentifier("hazardViewCell", forIndexPath: indexPath) as! hazardViewCell
        
        userCell.userLabel?.text = array[indexPath.row]
        userCell.timeStamp?.text = "Submittted: " + dataStamp[indexPath.row]
        userCell.descriptionLabel.text = descriptionHazard[indexPath.row]
        return userCell
    }
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        loadData()
       // singIn()
        
      // signUP()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

