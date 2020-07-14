//
//  PhoneNumberForgotPassTableViewCell.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 1/23/19.
//  Copyright © 2019 DAT-Asset-115-DAPL. All rights reserved.
//

import UIKit


class PhoneNumberForgotPassTableViewCell: UITableViewCell,UITextFieldDelegate,CountryCodeDelegate {

    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet var view_closedTab: UIView!
    @IBOutlet var img_TabBG: UIImageView!
    
    @IBOutlet var img_arrow: UIImageView!
    @IBOutlet var img_stepOver: UIImageView!
    @IBOutlet var view_extendedBG: UIView!
    @IBOutlet var btn_closedTab: UIButton!
    
    @IBOutlet var img_closedTab: UIImageView!
    
    @IBOutlet weak var sendOtpBtn: UIButton!
    @IBOutlet var txtFld_mobileNumber: UITextField!
    
    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet weak var countryCodeButton: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func awakeFromNib() {
        super.awakeFromNib()
        countryCodeLabel.text = "+\(appDelegate.dialCode)"
        countryFlagImageView.image = UIImage.init(named: "\(appDelegate.countryCode).png")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- TextField Delegate Methods -----
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == txtFld_mobileNumber {
            if !Utility.IsEmtyString(textField.text) && Utility.isValidPhoneNumber(testStr: textField.text!)
            {
                if let range = textField.text?.range(of:"+\(appDelegate.dialCode)") {
                    let phone = textField.text?[range.upperBound...]
                    textField.text = Utility.trimmingString(String(phone!))   
                    countryCodeLabel.text = "+\(appDelegate.dialCode)"
                    countryFlagImageView.image = UIImage.init(named: "\(appDelegate.countryCode).png")
                    
                }
            }
            else{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidPhoneNumber, Button_Title: Constants.AppAlertAction.kOKButton, self.window!.rootViewController!)
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtFld_mobileNumber{
            let maxLength = 16
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            if (newString.length <= maxLength){
                let allowedCharacters = CharacterSet(charactersIn:"+0123456789 ")//Here change this characters based on your requirement
                let characterSet = CharacterSet(charactersIn: string)
                if (allowedCharacters.isSuperset(of: characterSet)){
                    return allowedCharacters.isSuperset(of: characterSet)
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidPhoneNumber, Button_Title: Constants.AppAlertAction.kOKButton, self.window!.rootViewController!)
                    return false
                }
            }
            else{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidPhoneNumber, Button_Title: Constants.AppAlertAction.kOKButton, self.window!.rootViewController!)
                return false
            }
        }
        else{
            return true
        }
    }
    
    //MARK:- Set Done Button ----
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        txtFld_mobileNumber.inputAccessoryView = keyboardToolbar
    }
    
    //MARK:- All Button Actions -----
    @objc func dismissKeyboard() {
        txtFld_mobileNumber.endEditing(true)
    }
    
    @IBAction func countryCodeButtonTap(_ sender: Any) {
        let countryPopUps = CountryCodePopups.instanceFromNib()
        countryPopUps.countryCodeObjDelegate = self
        countryPopUps.setupCountryCodePopups()
    }
    
    func selectedCountryCode(countryDetails: [String : Any]) {
        let flagImage = "\(countryDetails["code"]!).png"
        countryFlagImageView.image = UIImage(named: flagImage)
        
        countryCodeLabel.text = "+\(countryDetails["dial_code"] ?? "")"
    }
}
