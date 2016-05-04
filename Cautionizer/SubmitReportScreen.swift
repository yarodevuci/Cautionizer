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
    @IBOutlet weak var headerName: UILabel!
    @IBOutlet weak var fakeImageView: UIImageView!
    
    var locationManager = CLLocationManager()
    var headerText = String()
    
    
    @IBAction func addImageButtonAction(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.choosingImageSource(.Camera)
            
        })
        let saveAction = UIAlertAction(title: "Gallery", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.choosingImageSource(.PhotoLibrary)
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })

        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
    
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func choosingImageSource(source: UIImagePickerControllerSourceType) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = source
        myPickerController.allowsEditing = false
        self.presentViewController(myPickerController, animated: true, completion: nil)
        view.endEditing(true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        hazardImage.image = info [UIImagePickerControllerOriginalImage] as? UIImage
        if hazardImage.image != nil {
            fakeImageView.hidden = true
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in

            if error != nil { print("Erorr: " + (error?.localizedDescription)!)
                return }
            
                if placemarks?.count > 0 { let placeMark  = placemarks![0]
                
                        // Street address
                        if let street = placeMark.addressDictionary!["Street"] as? NSString {
                            if let city = placeMark.addressDictionary!["City"] as? NSString {
                            let loc: String = ((street as String) + ", " + (city as String))
                            self.locationTextField.text = loc } }
        } })
    }

    func displayLocationInfo (placemark: CLPlacemark) {
        self.locationManager.startUpdatingLocation()
//        print(placemark.locality)
//        print(placemark.postalCode)
//        print(placemark.administrativeArea)
//        print(placemark.country)
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        headerName.text = headerText
        //Location points
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    
        LogInDisplay().makeImageBlur(backgroundImage)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubmitReportScreen.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SubmitReportScreen.textChangeDescriptionField(_:)), name: UITextViewTextDidChangeNotification, object: nil)
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
            if descriptionField.text == "Type a brief description of hazard" {
                descriptionField.text = ""
            }
            scrollView.setContentOffset(CGPointMake(0, 135), animated: true)
        }
    }
    func textViewDidEndEditing(textView: UITextView) {
        if descriptionField.text.isEmpty {
            descriptionField.text = "Type a brief description of hazard"
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
        let user: PFUser = PFUser.currentUser()!
        let userIdenty = user.username!
        
        userReport.setObject(headerText + "@" + locationTextField.text!, forKey: "Location")
        userReport.setObject(convertedDate + " by #\(userIdenty)", forKey: "timeStamp")
        userReport.setObject(userIdenty, forKey: "reportedBy")
        
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
