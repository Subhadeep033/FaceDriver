//
//  OTPsignUpFormCollectionViewCell.swift
//  Facedrive
//
//  Created by DAT-Asset-115 on 1/18/19.
//  Copyright © 2019 DAT-Asset-115-DAPL. All rights reserved.
//

import UIKit

class OTPsignUpFormCollectionViewCell: UICollectionViewCell,UITextFieldDelegate {
    @IBOutlet var txtFld_OTP_one: UITextField!
    @IBOutlet var txtFld_OTP_two: UITextField!
    @IBOutlet var txtFld_OTP_Three: UITextField!
    
    @IBOutlet var txtFld_OTP_four: UITextField!
    
    @IBOutlet var txtFld_OTP_fifth: UITextField!
    @IBOutlet var txtFld_OTP_sixth: UITextField!
    
    @IBOutlet var btn_EditNumber: UIButton!
    @IBOutlet var btn_ResendCode: UIButton!
    @IBOutlet var lbl_mobileNumber: UILabel!
    
    // MARK:- TextField Delegate Methods -----
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let maxLength = 1
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            txtFld_OTP_one.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            txtFld_OTP_two.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            txtFld_OTP_Three.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            txtFld_OTP_four.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        txtFld_OTP_fifth.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        txtFld_OTP_sixth.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            return newString.length <= maxLength
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        
        let text = textField.text
        
        if text?.utf16.count==1{
            switch textField{
            case txtFld_OTP_one:
                txtFld_OTP_two.becomeFirstResponder()
            case txtFld_OTP_two:
                txtFld_OTP_Three.becomeFirstResponder()
            case txtFld_OTP_Three:
                txtFld_OTP_four.becomeFirstResponder()
            case txtFld_OTP_four:
                txtFld_OTP_fifth.becomeFirstResponder()
            case txtFld_OTP_fifth:
                txtFld_OTP_sixth.becomeFirstResponder()
            case txtFld_OTP_sixth:
                txtFld_OTP_sixth.resignFirstResponder()
            default:
                break
            }
        }
        else if text?.utf16.count==0{
            switch textField{
            case txtFld_OTP_one:
                txtFld_OTP_one.becomeFirstResponder()
            case txtFld_OTP_two:
                txtFld_OTP_one.becomeFirstResponder()
            case txtFld_OTP_Three:
                txtFld_OTP_two.becomeFirstResponder()
            case txtFld_OTP_four:
                txtFld_OTP_Three.becomeFirstResponder()
            case txtFld_OTP_fifth:
                txtFld_OTP_four.becomeFirstResponder()
            case txtFld_OTP_sixth:
                txtFld_OTP_fifth.becomeFirstResponder()
//                delegate?.OTPdone(true)
            default:
                break
            }
        }
    }
    
    // MARK:- Clear TextField Method -----
    func clearTextFields(){
        txtFld_OTP_one.text     = ""
        txtFld_OTP_two.text     = ""
        txtFld_OTP_Three.text   = ""
        txtFld_OTP_four.text    = ""
        txtFld_OTP_fifth.text   = ""
        txtFld_OTP_sixth.text   = ""
    }
}
