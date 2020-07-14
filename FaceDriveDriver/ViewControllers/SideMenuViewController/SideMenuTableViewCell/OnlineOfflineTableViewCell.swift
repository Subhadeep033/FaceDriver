//
//  OnlineOfflineTableViewCell.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 13/02/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit

class OnlineOfflineTableViewCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var selectImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
