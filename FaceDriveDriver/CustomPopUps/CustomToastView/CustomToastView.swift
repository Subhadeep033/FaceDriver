//
//  CustomToastView.swift
//  Facedrive
//
//  Created by DAPL-Asset-275 on 22/04/19.
//  Copyright © 2019 DAT-Asset-115-DAPL. All rights reserved.
//

import UIKit

class CustomToastView: UIView {
    @IBOutlet weak var lbl_toastMessage: UILabel!
    
    @IBOutlet weak var btn_toastMessage: UIButton!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    class func instanceFromNib() -> CustomToastView {
        return UINib(nibName: "CustomToastView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomToastView
    }

}
