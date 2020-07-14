//
//  ForgotPassOTPTableViewCell.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 1/23/19.
//  Copyright © 2019 DAT-Asset-115-DAPL. All rights reserved.
//

import UIKit
protocol ForgotPasswordOtpDelegate {
    func verifyOtpDelegateCalled()
}

class ForgotPassOTPTableViewCell: UITableViewCell,UITextFieldDelegate {
    var verifyPasswordDelegate : ForgotPasswordOtpDelegate?
    @IBOutlet var btn_closedTab: UIButton!
    @IBOutlet var img_closedTab: UIImageView!
    @IBOutlet var view_closedTab: UIView!
    @IBOutlet var view_extendedTab: UIView!
    @IBOutlet var img_tabBG: UIImageView!
    @IBOutlet var img_arrow: UIImageView!
    
    @IBOutlet weak var resendPinBtn: UIButton!
    @IBOutlet weak var otpBoxTextField6: UITextField!
    @IBOutlet weak var otpBoxTextField5: UITextField!
    @IBOutlet weak var otpBoxTextField4: UITextField!
    @IBOutlet weak var otpBoxTextField3: UITextField!
    @IBOutlet weak var otpBoxTextField2: UITextField!
    @IBOutlet weak var otpBoxTextField1: UITextField!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet var img_stepOver: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        otpBoxTextField1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpBoxTextField2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpBoxTextField3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpBoxTextField4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpBoxTextField5.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpBoxTextField6.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)


        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- TextField Delegate Methods ---
    @objc func textFieldDidChange(textField: UITextField){
        let text = textField.text
        if  text?.utf16.count == 1 {
            switch textField{
            case otpBoxTextField1:
                otpBoxTextField2.becomeFirstResponder()
                break
            case otpBoxTextField2:
                otpBoxTextField3.becomeFirstResponder()
                break
            case otpBoxTextField3:
                otpBoxTextField4.becomeFirstResponder()
                break
            case otpBoxTextField4:
                otpBoxTextField5.becomeFirstResponder()
                break
            case otpBoxTextField5:
                otpBoxTextField6.becomeFirstResponder()
                break
            default:
                otpBoxTextField6.resignFirstResponder()
                self.verifyPasswordDelegate?.verifyOtpDelegateCalled()
                break
            }
        }
        else if text?.utf16.count==0{
            switch textField{
            case otpBoxTextField1:
                otpBoxTextField1.becomeFirstResponder()
            case otpBoxTextField2:
                otpBoxTextField1.becomeFirstResponder()
            case otpBoxTextField3:
                otpBoxTextField2.becomeFirstResponder()
            case otpBoxTextField4:
                otpBoxTextField3.becomeFirstResponder()
            case otpBoxTextField5:
                otpBoxTextField4.becomeFirstResponder()
            case otpBoxTextField6:
                otpBoxTextField5.becomeFirstResponder()
            default:
                break
            }
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.keyboardType == .numberPad || textField.keyboardType == .phonePad {
            setDoneOnKeyboard()
            return true
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        if(textField != otpTextField){
            let maxLength = 1
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        else{
            return true
        }
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        
        otpTextField.inputAccessoryView = keyboardToolbar
        
    }
    
    @objc func dismissKeyboard(_sender : UIBarButtonItem!) {
//        txtFld_mobileNumber.endEditing(true)
        otpTextField.endEditing(true)
        
    }
    
}
