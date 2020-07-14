//
//  SetPasswordForgotPassTableViewCell.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 1/23/19.
//  Copyright © 2019 DAT-Asset-115-DAPL. All rights reserved.
//

import UIKit

class SetPasswordForgotPassTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet var img_tabBG: UIImageView!
    @IBOutlet var view_extendedBG: UIView!
    @IBOutlet var img_closedTab: UIImageView!
    @IBOutlet var btn_closedTab: UIButton!
    
    @IBOutlet var img_arrow: UIImageView!
    @IBOutlet var img_stepOver: UIImageView!
    @IBOutlet weak var setupNewPasswordBtn: UIButton!
    @IBOutlet weak var reEnterNewPasswordBtn: UIButton!
    
    @IBOutlet weak var reEnterPasswordTextField: UITextField!
    @IBOutlet weak var setNewPasswordTextField: UITextField!
    @IBOutlet weak var setPasswordDoneBtnTap: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        // Try to find next responder
        let nextResponder  = textField.superview?.viewWithTag(nextTag)
        
        if nextResponder != nil {
            // Found next responder, so set it
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        
        return false
    }

    
    @IBAction func setNewPasswordShowHideTap(_ sender: UIButton!) {
        if sender.tag == 101{
            setNewPasswordTextField.isSecureTextEntry = !setNewPasswordTextField.isSecureTextEntry
            
            if setNewPasswordTextField.isSecureTextEntry {
                setupNewPasswordBtn.setImage(UIImage(named: "EyeOff"), for: .normal)
            }
            else{
                setupNewPasswordBtn.setImage(UIImage(named: "EyeOn"), for: .normal)
            }
        }
        else{
            reEnterPasswordTextField.isSecureTextEntry = !reEnterPasswordTextField.isSecureTextEntry
            
            if reEnterPasswordTextField.isSecureTextEntry {
                reEnterNewPasswordBtn.setImage(UIImage(named: "EyeOff"), for: .normal)
            }
            else{
                reEnterNewPasswordBtn.setImage(UIImage(named: "EyeOn"), for: .normal)
            }
        }
    }
}
