//
//  ProfileTableCell.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 16/02/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit


class ProfileTableCell: UITableViewCell {

    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var downArrowImageview: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var countryCodeBtn: UIButton!
    @IBOutlet weak var countryCodeBtnWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var dataTextField: UITextField!
    @IBOutlet weak var btnVerified: UIButton!
    @IBOutlet weak var verifiedBtnWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var lineViewHorizontalSpacingConstraints: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        countryCodeBtn.setTitle("+\(appDelegate.dialCode)", for: .normal)
        flagImage.image = UIImage.init(named: "\(appDelegate.countryCode).png")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class ProfileCarListCell : UITableViewCell{
    @IBOutlet weak var carApproveImageView: UIImageView!
    @IBOutlet weak var carListImageView: UIImageView!
    @IBOutlet weak var labelCarNumber: UILabel!
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var carDetailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class DocumentsCell : UITableViewCell {
    
    
    @IBOutlet weak var documentsImageView: UIImageView!
    @IBOutlet weak var documentsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
