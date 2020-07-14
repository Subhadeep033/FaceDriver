//
//  MobileNumberSignUpCollectionViewCell.swift
//  Facedrive
//
//  Created by DAT-Asset-115 on 1/18/19.
//  Copyright © 2019 DAT-Asset-115-DAPL. All rights reserved.
//

import UIKit

class MobileNumberSignUpCollectionViewCell: UICollectionViewCell,UITextFieldDelegate {
   
    @IBOutlet var txtFld_mobileNumber: UITextField!
    let appdelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var btn_dialCode: UIButton!
    @IBOutlet var lbl_countryCode: UILabel!
    @IBOutlet var img_countryFlag: UIImageView!
    
    // MARK:- TextField Delegate Method ------
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let maxLength = 16
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
    
   }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == txtFld_mobileNumber {
            if !Utility.IsEmtyString(textField.text)
            {
                if let range = textField.text?.range(of:"+\(appdelegate.dialCode)") {
                    let phone = textField.text?[range.upperBound...]
                    textField.text = String(phone!)
                    lbl_countryCode.text = "+\(appdelegate.dialCode)"
                    img_countryFlag.image = UIImage.init(named: "\(appdelegate.countryCode).png")
                    
                }
            }
            
        }
    }
}
