//
//  hazardViewCell.swift
//  Cautionizer
//
//  Created by Yaro on 4/27/16.
//  Copyright © 2016 Yaro. All rights reserved.
//

import UIKit

class hazardViewCell: UITableViewCell {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
