//
//  SelectCarTableViewCell.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 22/01/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit

class SelectCarTableViewCell: UITableViewCell {

    @IBOutlet weak var carModelNameLabel: UILabel!
    @IBOutlet weak var carModelNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
