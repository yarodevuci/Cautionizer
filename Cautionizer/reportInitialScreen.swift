//
//  reportInitialScreen.swift
//  Cautionizer
//
//  Created by Yaro on 4/28/16.
//  Copyright © 2016 Yaro. All rights reserved.
//

import UIKit

class reportInitialScreen: UIViewController, userSubMenuDisplayDelegate{
    
    var blackMaskView = UIView(frame: CGRectZero)
    
    //View Controller
    let menuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("userSubMenuDisplay") as! userSubMenuDisplay
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        //Swipe Guestures
        let leftSwipe = UISwipeGestureRecognizer(target: self, action:#selector(reportInitialScreen.handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(reportInitialScreen.handleSwipes(_:)))
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        //Add menu view controller
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
    
    func tapGestureRecognized() {
        toogleMenu()
    }
    func menuCloseButtonTapped() {
        toogleMenu()
    }
    @IBAction func menuButtonPressed(sender: AnyObject) {
        toogleMenu()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "securityRisk" {
            if let destination: SubmitReportScreen = segue.destinationViewController as? SubmitReportScreen {
                destination.headerText = "Security Risk" }
        }
       
        else if segue.identifier == "other" {
            if let destination: SubmitReportScreen = segue.destinationViewController as? SubmitReportScreen {
                destination.headerText = "Other" }
        }
    }



}
