//
//  SignInOTPCollectionViewCell.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 1/18/19.
//  Copyright © 2019 DAT-Asset-115-DAPL. All rights reserved.
//

import UIKit
protocol SignInOTPDelegate {
    func checkMobile(_ valid:Bool)
    func OTPdone(_ done:Bool)
//    func validatePhoneNumberThroughOTP(phoneNumber:String)
}
class SignInOTPCollectionViewCell: UICollectionViewCell ,UITextFieldDelegate{
    @IBOutlet var txtFld_mobileNumber: UITextField!
    @IBOutlet var txtFld_backOTPreader: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var txtFld_OTP_one: UITextField!
    
    @IBOutlet var txtFld_OTP_second: UITextField!
    
    @IBOutlet var txtFld_OTP_third: UITextField!
    
    @IBOutlet var txtFld_OTP_fourth: UITextField!
    @IBOutlet var txtFld_OTP_fifth: UITextField!
    @IBOutlet var txtFld_OTP_sixth: UITextField!
    
    @IBOutlet weak var otpStackView: UIStackView!
    
    @IBOutlet weak var resendPinButton: UIButton!
    @IBOutlet var btn_CountrySelection: UIButton!
    
    @IBOutlet var img_flg: UIImageView!
    
    var delegate: SignInOTPDelegate?
    @IBOutlet var lbl_dialCode: UILabel!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func awakeFromNib() {
        super.awakeFromNib()
        txtFld_mobileNumber.becomeFirstResponder()
        lbl_dialCode.text = "+\(appDelegate.dialCode)"
        img_flg.image = UIImage.init(named: "\(appDelegate.countryCode).png")
        // Initialization code
    }
    
    // MARK:- TextField Delegate Methods -----
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == txtFld_mobileNumber {
            if !Utility.IsEmtyString(textField.text)
            {
                if let range = textField.text?.range(of:"+\(appDelegate.dialCode)") {
                    let phone = textField.text?[range.upperBound...]
                    textField.text = Utility.trimmingString(String(phone!))
                    lbl_dialCode.text = "+\(appDelegate.dialCode)"
                    img_flg.image = UIImage.init(named: "\(appDelegate.countryCode).png")
                    
                }
            }
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag != 1024 {
            let maxLength = 1
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            txtFld_OTP_one.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            txtFld_OTP_second.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            txtFld_OTP_third.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            txtFld_OTP_fourth.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            txtFld_OTP_fifth.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            txtFld_OTP_sixth.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            return newString.length <= maxLength
        }
        else{
            let maxLength = 16
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            txtFld_mobileNumber.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            if newString.length >= 8
            {
                delegate?.checkMobile(true)
            }
            else
            {
                delegate?.checkMobile(false)
            }
            if (newString.length <= maxLength){
                let allowedCharacters = CharacterSet(charactersIn:"+0123456789 ")//Here change this characters based on your requirement
                let characterSet = CharacterSet(charactersIn: string)
                if (allowedCharacters.isSuperset(of: characterSet)){
                    return allowedCharacters.isSuperset(of: characterSet)
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: "Please Enter Valid Mobile Number", Button_Title: Constants.AppAlertAction.kOKButton, self.window!.rootViewController!)
                    return false
                }
            }
            else{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: "Please Enter Valid Mobile Number", Button_Title: Constants.AppAlertAction.kOKButton, self.window!.rootViewController!)
                return false
            }
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        
        let text = textField.text
        
        if text?.utf16.count==1{
            switch textField{
            case txtFld_OTP_one:
                txtFld_OTP_second.becomeFirstResponder()
                break
            case txtFld_OTP_second:
                txtFld_OTP_third.becomeFirstResponder()
                break
            case txtFld_OTP_third:
                txtFld_OTP_fourth.becomeFirstResponder()
                break
            case txtFld_OTP_fourth:
                txtFld_OTP_fifth.becomeFirstResponder()
                break
            case txtFld_OTP_fifth:
                txtFld_OTP_sixth.becomeFirstResponder()
                break
            case txtFld_OTP_sixth:
                txtFld_OTP_sixth.resignFirstResponder()
                delegate?.OTPdone(true)
                break
            default:
                break
            }
        }else if text?.utf16.count==0{
            switch textField{
            case txtFld_OTP_one:
                txtFld_OTP_one.becomeFirstResponder()
            case txtFld_OTP_second:
                txtFld_OTP_one.becomeFirstResponder()
            case txtFld_OTP_third:
                txtFld_OTP_second.becomeFirstResponder()
            case txtFld_OTP_fourth:
                txtFld_OTP_third.becomeFirstResponder()
            case txtFld_OTP_fifth:
                txtFld_OTP_fourth.becomeFirstResponder()
            case txtFld_OTP_sixth:
                txtFld_OTP_fifth.becomeFirstResponder()
                delegate?.OTPdone(true)
            default:
                break
            }
        }
    }
    
    // MARK:- OTP Value changed method -----
    @IBAction func OTP_valueChnaged(_ sender: UITextField) {
        if sender == txtFld_OTP_one {
            txtFld_OTP_second.becomeFirstResponder()
        }
    }
}
