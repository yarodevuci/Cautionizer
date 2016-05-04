//
//  SignUpDisplay.swift
//  Cautionizer
//
//  Created by Yaro on 4/28/16.
//  Copyright © 2016 Yaro. All rights reserved.
//

import UIKit
import Parse

class SignUpDisplay: UIViewController, UITextFieldDelegate {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle { return UIStatusBarStyle.LightContent }
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpDisplay.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpDisplay.textChanged(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
    }
    func textChanged(sender: NSNotification) {
        
        if userNameTextField.hasText() && emailTextField.hasText() && passwordTextField.hasText() && confirmPassTextField.hasText() {
                signUpButtonOutlet.userInteractionEnabled = true
                signUpButtonOutlet.alpha = 1
        }else {
                signUpButtonOutlet.userInteractionEnabled = false
                signUpButtonOutlet.alpha = 0.5
        }}
    
    func userSignsUp () {
        let user = PFUser()
        user.username = userNameTextField.text
        user.password = passwordTextField.text
        user.setObject(emailTextField.text!, forKey: "email")
        
        
        user.signUpInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
            
            if (error == nil) {
                
                let regSuccess = UIAlertController(title: "Success!", message: "Thank you for registration", preferredStyle: .Alert)
                let logInAction = UIAlertAction(title: "Begin reporting!", style: .Default) { (action:UIAlertAction!) in
                    //Load MainMenu
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainMenu")
                        self.presentViewController(viewController, animated: true, completion: nil) }) }
                        regSuccess.addAction(logInAction)
                        self.presentViewController(regSuccess, animated: true, completion:nil)
                } else { JSSAlertView().danger(self, title: "Error", text: "\(error)", buttonText:"Try again") }}
        
    }
    //Checks if user is already registered in the system via email
    func checkIsUserExists(userEmail: String, completion: ((isUser: Bool!) -> Void)!) {
        
        var isPresent: Bool = false
        let query: PFQuery = PFQuery(className: "_User")
        query.whereKey("email", equalTo: userEmail)
        
        animateHUD("Registraiton in progress...", detailsLabel: "Please Wait")
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        
            if error == nil {
                if (objects!.count > 0) { isPresent = true }
                else { isPresent = false }
                completion(isUser: isPresent) }
        }
    }
    
    //Display Alert if the user was found
    func userFound() {
        view.endEditing(true)
        JSSAlertView().danger(self, title: "Error", text: "Entered email is already exists", buttonText:"Try again")
        emailTextField.text = ""
    }
    
    //To dismiss keyboard
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == self.userNameTextField {
            emailTextField.becomeFirstResponder()
        }
        else if textField == self.emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == self.passwordTextField {
            confirmPassTextField.becomeFirstResponder()
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    //Check if the user inputed correct email format
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let range = testStr.rangeOfString(emailRegEx, options:.RegularExpressionSearch)
        let result = range != nil ? true : false
        return result
    }
    
    func animateHUD (labelText: String, detailsLabel: String) {
        let spinAct = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinAct.activityIndicatorColor = UIColor.whiteColor()
        spinAct.label.text = labelText
        spinAct.detailsLabel.textColor = UIColor.whiteColor()
        spinAct.detailsLabel.text = detailsLabel
        spinAct.label.textColor = UIColor.whiteColor()
        spinAct.bezelView.color = UIColor.blackColor()
        //MBProgressHUD.hideAllHUDsForView(self.view, animated: true)  For hiding the HUD
    }
    
    @IBAction func signUpButtonAction(sender: AnyObject) {
        
        if isValidEmail(emailTextField.text!) == false {
            JSSAlertView().danger(self, title: "Error", text: "Incorrect email address", buttonText:"Try again")
            view.endEditing(true)
            self.emailTextField.text = ""
            signUpButtonOutlet.userInteractionEnabled = false
            signUpButtonOutlet.alpha = 0.5
            
        } else if passwordTextField.text?.characters.count < 8 {
            JSSAlertView().danger(self, title: "Error", text: "Password must be greater than 8 characters", buttonText:"Try again")
            view.endEditing(true)
            self.passwordTextField.text = ""
            self.confirmPassTextField.text = ""
            signUpButtonOutlet.userInteractionEnabled = false
            signUpButtonOutlet.alpha = 0.5
        }
        else if passwordTextField.text != confirmPassTextField.text {
            JSSAlertView().warning(self, title: "Error", text: "Passwords do not match!", buttonText: "Retype passwords")
            view.endEditing(true)
            self.passwordTextField.text = ""
            self.confirmPassTextField.text = ""
            signUpButtonOutlet.userInteractionEnabled = false
            signUpButtonOutlet.alpha = 0.5
        }
        else {
            checkIsUserExists(emailTextField.text!){isUser in if let user = isUser where user {
                self.userFound()
            }
                else { self.userSignsUp() }
                } }
    }
}
