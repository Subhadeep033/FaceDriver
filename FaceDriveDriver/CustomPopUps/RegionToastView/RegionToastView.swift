//
//  RegionToastView.swift
//  FaceDriveDriver
//
//  Created by DAT-Asset-259 on 26/04/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit

class RegionToastView: UIView {

    @IBOutlet weak var regionDetailsLabel: UILabel!
    @IBOutlet weak var regionHeaderLabel: UILabel!
    /*
     @IBOutlet weak var regionDetailsLabel: UILabel!
     // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    class func instanceFromNib() -> RegionToastView {
        return UINib(nibName: "RegionToastView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! RegionToastView
    }
}
