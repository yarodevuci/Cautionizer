//
//  LogInDisplay.swift
//  Cautionizer
//
//  Created by Yaro on 4/27/16.
//  Copyright © 2016 Yaro. All rights reserved.
//

import UIKit
import Parse

class LogInDisplay: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButtonOutlet: UIButton!
    @IBOutlet weak var createAccountOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      makeImageBlur(backgroundImage) //makes image blur
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogInDisplay.textChanged(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
   func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.userNameTextField {
            passwordTextField.becomeFirstResponder()
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textChanged(sender: NSNotification) {
        
        if let uP = self.passwordTextField {
            if let uE = userNameTextField {
                if uP.hasText() && uE.hasText() {
                    signInButtonOutlet.userInteractionEnabled = true
                    self.signInButtonOutlet.alpha = 1 }
                else {
                    signInButtonOutlet.userInteractionEnabled = false
                    self.signInButtonOutlet.alpha = 0.5 }
            }
        }
        
    }
    func disableInteraction () {
        signInButtonOutlet.userInteractionEnabled = false
        createAccountOutlet.userInteractionEnabled = false
        userNameTextField.userInteractionEnabled = false
        passwordTextField.userInteractionEnabled = false
    }

    func enableFields() {
        signInButtonOutlet.userInteractionEnabled = true
        createAccountOutlet.userInteractionEnabled = true
        userNameTextField.userInteractionEnabled = true
        passwordTextField.userInteractionEnabled = true
        view.endEditing(true)  //Dismisses keyboard if applicable
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
    
    func signUserIn () {
        let user = PFUser()
        user.username = userNameTextField.text
        user.password = passwordTextField.text
        
        disableInteraction()
        
        if Reachability.isConnectedToNetwork() == false {
            JSSAlertView().danger(self, title: "No Internet Connection", text: "Make sure your device is connected to the internet.")
            enableFields()
        }
        else {
            animateHUD("Loading", detailsLabel: "Please Wait")
            PFUser.logInWithUsernameInBackground(userNameTextField.text!, password: passwordTextField.text!, block: {(User: PFUser?, error: NSError?) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                
                if error == nil! {
                        
                    dispatch_async(dispatch_get_main_queue()) {
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let main: UIViewController = storyBoard.instantiateViewControllerWithIdentifier("mainMenu")
                    self.presentViewController(main, animated: true, completion: nil)} }
                else {
                        JSSAlertView().danger(self, title: "Error", text: "Invalid username or password", buttonText:"Try again")
                        self.userNameTextField.text = ""
                        self.passwordTextField.text = ""
                        self.enableFields()
                        self.signInButtonOutlet.userInteractionEnabled = false
                        self.signInButtonOutlet.alpha = 0.5
                }})}}
    
    @IBAction func autofillButton(sender: AnyObject) {
        userNameTextField.text = "test"
        passwordTextField.text = "1"
        self.signInButtonOutlet.userInteractionEnabled = true
        self.signInButtonOutlet.alpha = 1
    }
    
    @IBAction func signInButton(sender: AnyObject) {
        signUserIn()
    }
    
    func makeImageBlur (image: UIImageView) {
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = image.bounds
        image.insertSubview(blurView, atIndex: 0)
    }

    //To dismiss keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

}
