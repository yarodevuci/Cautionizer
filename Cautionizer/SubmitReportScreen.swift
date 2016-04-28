//
//  SubmitReportScreen.swift
//  Cautionizer
//
//  Created by Yaro on 4/28/16.
//  Copyright © 2016 Yaro. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class SubmitReportScreen: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle { return UIStatusBarStyle.LightContent }

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var hazardImage: UIImageView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var submitButtonOutlet: UIButton!
    @IBOutlet weak var addImageButton: UIButton!
    
    var locationManager = CLLocationManager()
    
    @IBAction func addImageButton(sender: AnyObject) {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = .PhotoLibrary
        myPickerController.sourceType = .Camera

        myPickerController.allowsEditing = false
        self.presentViewController(myPickerController, animated: true, completion: nil)
        view.endEditing(true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        hazardImage.image = info [UIImagePickerControllerOriginalImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
    
//        activityIndicatorView.transform = CGAffineTransformMakeScale(1.5, 1.5)
//        activityIndicatorView.startAnimating()
       
       
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
            self.locationManager.stopUpdatingLocation()
            if error != nil
            {
                print("Erorr: " + (error?.localizedDescription)!)
                return
            }
            if placemarks?.count > 0 {
                
                
                self.locationManager.stopUpdatingLocation()
                let placeMark  = placemarks![0]
                
                // Street address
                if let street = placeMark.addressDictionary!["Street"] as? NSString {
                    if let city = placeMark.addressDictionary!["City"] as? NSString {
                        var loc: String = ((street as String) + ", " + (city as String))
                self.locationTextField.text = loc
                    }
            
                    
                }
        }
        })
    }

    func displayLocationInfo (placemark: CLPlacemark) {
        self.locationManager.startUpdatingLocation()
        print(placemark.locality)
        print(placemark.postalCode)
        print(placemark.administrativeArea)
        print(placemark.country)
    }
    
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
        LogInDisplay().makeImageBlur(backgroundImage)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubmitReportScreen.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SubmitReportScreen.textChangeDescriptionField(_:)), name: UITextViewTextDidChangeNotification, object: nil)
        
        //Load picture from parse
        if(PFUser.currentUser()?.objectForKey("hazard_image") != nil)
        {
            let providerLicenseImageFile:PFFile = PFUser.currentUser()?.objectForKey("hazard_image") as! PFFile
            providerLicenseImageFile.getDataInBackgroundWithBlock({(imageData: NSData?, error: NSError?) -> Void in
                if(imageData != nil)
                {
                    self.hazardImage.image = UIImage(data: imageData!)
                }
            })
        }
    }
    
    //To dismiss keyboard
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 1 {
            descriptionField.becomeFirstResponder()
        }
        return false
    }
    func textViewDidBeginEditing(textView: UITextView) { //Handle the text changes here
        if (textView.tag == 2) {
            if descriptionField.text == "Write a brief description of hazard..." {
                descriptionField.text = ""
            }
            scrollView.setContentOffset(CGPointMake(0, 135), animated: true)
        }
    }
    func textViewDidEndEditing(textView: UITextView) {
        if descriptionField.text.isEmpty {
            descriptionField.text = "Write a brief description of hazard..."
        }
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if (textField.tag == 1) {
            scrollView.setContentOffset(CGPointMake(0, 150), animated: true)
        }
    }
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    
    func textChangeDescriptionField (sender: NSNotification) {
        if descriptionField.text != "" {
            submitButtonOutlet.userInteractionEnabled = true
            self.submitButtonOutlet.alpha = 1
        }
            else {
                submitButtonOutlet.userInteractionEnabled = false
                self.submitButtonOutlet.alpha = 0.5 }
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
    
    @IBAction func submitReportAction(sender: AnyObject) {
        self.view.endEditing(true)
        
        let timeStamp = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.AMSymbol = "AM"
        dateFormatter.PMSymbol = "PM"
        dateFormatter.dateFormat = "MM-dd-yy, hh:mma"
        let convertedDate = dateFormatter.stringFromDate(timeStamp)
        
        
        let userReport = PFObject(className: "Data")
        
        if hazardImage.image != nil {
            let imageUploadData = UIImageJPEGRepresentation(hazardImage.image!, 0.5)
            let imageFileObject = PFFile(data: imageUploadData!)
            userReport.setObject(imageFileObject!, forKey: "hazard_image")
            addImageButton.userInteractionEnabled = false
            addImageButton.hidden = false
        }
        
        userReport.setObject("Interior Blocked Path@ " + locationTextField.text!, forKey: "Location")
        userReport.setObject(convertedDate, forKey: "timeStamp")
        userReport.setObject(descriptionField.text!, forKey: "hazardInfo")
        
            animateHUD("Uploading Report", detailsLabel: "Please Wait")
        userReport.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if error == nil {
                self.addImageButton.userInteractionEnabled = true
                let alertview = JSSAlertView().success(self, title: "Success", text: "Your report was submitted! ")
                alertview.addAction(self.cancelCallback)
            }else {
                print(error)
            }
        })
    }
    func cancelCallback() {
        dispatch_async(dispatch_get_main_queue()) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let main: UIViewController = storyBoard.instantiateViewControllerWithIdentifier("reportList")
        self.presentViewController(main, animated: true, completion: nil)}  }
}
