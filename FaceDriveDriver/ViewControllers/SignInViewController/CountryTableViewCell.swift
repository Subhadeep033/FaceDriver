//
//  CountryTableViewCell.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 1/18/19.
//  Copyright © 2019 DAT-Asset-115-DAPL. All rights reserved.
//

import UIKit

class CountryTableViewCell: UITableViewCell {

    @IBOutlet var lbl_countryDialCode: UILabel!
    @IBOutlet var imgVw_CountryFlag: UIImageView!
    @IBOutlet var lbl_country: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
