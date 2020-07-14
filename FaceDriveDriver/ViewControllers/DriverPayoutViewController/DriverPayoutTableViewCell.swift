//
//  DriverPayoutTableViewCell.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 14/05/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit

class DriverPayoutTableViewCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var routingNumberLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.layer.borderColor = Constants.AppColour.kAppLightGreyColor.cgColor
        baseView.layer.borderWidth = 2.0
        baseView.layer.cornerRadius = 3.0
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
