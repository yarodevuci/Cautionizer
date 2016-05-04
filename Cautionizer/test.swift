//
//  test.swift
//  Cautionizer
//
//  Created by Yaro on 5/4/16.
//  Copyright © 2016 Yaro. All rights reserved.
//

import UIKit

class test: UIViewController {
    
    
    @IBOutlet weak var imageBack: UIImageView!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     // LogInDisplay().makeImageBlur(imageBack)
    }
    
   
}
