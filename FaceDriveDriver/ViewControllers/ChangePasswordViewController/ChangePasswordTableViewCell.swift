//
//  ChangePasswordTableViewCell.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 26/02/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit

class ChangePasswordTableViewCell: UITableViewCell {

    @IBOutlet weak var showHideButton: UIButton!
    @IBOutlet weak var dataTextField: ACFloatingTextfield!
    @IBOutlet weak var headerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
