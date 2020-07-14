//
//  VerifyPhoneNumberPopupsViewController.swift
//  Facedriver
//
//  Created by DAT-Asset-259 on 27/06/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Reachability

class VerifyPhoneNumberPopupsViewController: UIViewController {
    
    
    var callback : ((Bool) -> Void)?
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var popupMessageLabel: UILabel!
    @IBOutlet weak var popupHeaderLabel: UILabel!
    
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var otpTextField1: UITextField!
    @IBOutlet weak var otpTextField2: UITextField!
    @IBOutlet weak var otpTextField3: UITextField!
    @IBOutlet weak var otpTextField4: UITextField!
    @IBOutlet weak var otpTextField5: UITextField!
    
    var securityCode = String()
    var countryCode = String()
    var phoneNumber = String()
    var isFromUpdate = Bool()
    var isFromSignUp = Bool()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        self.setupVerifyPhoneNumberPopups(countryCode: self.countryCode, phoneNumber: self.phoneNumber, isFromUpdateProfile: self.isFromUpdate, isFromSignUp: self.isFromSignUp)

        // Do any additional setup after loading the view.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK:- Button action
    
    @IBAction func dismissButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
        
    }
    
    @IBAction func phoneNumberEditTap(_ sender: Any) {
        
        self.callback?(true as Bool)
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func resendOtpTap(_ sender: Any) {
        if isFromUpdate{
            self.sendOtpToMobileForUpdate(code: countryCode, phoneNo: phoneNumber)
        }
    }
    
    @IBAction func verifyPhoneNumberTap(_ sender: Any) {
        if isFromUpdate{
            self.verifyOtpToMobileForUpdateProfile()
        }
    }
    
    // MARK:- Initialize view
    func setupVerifyPhoneNumberPopups(countryCode:String,phoneNumber:String,isFromUpdateProfile:Bool,isFromSignUp:Bool){
        phoneNumberLabel.text = "+" + countryCode + "-" + phoneNumber
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
        self.isFromUpdate = isFromUpdateProfile
        self.isFromSignUp = isFromSignUp
        
        otpTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField5.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        
        if isFromUpdate{
            self.sendOtpToMobileForUpdate(code: countryCode, phoneNo: phoneNumber)
        }
    }
    
    // MARK:- Textfield handling
    @objc func textFieldDidChange(textField: UITextField){
        
        let text = textField.text
        
        if text?.utf16.count==1{
            switch textField{
            case otpTextField:
                otpTextField1.becomeFirstResponder()
                break
            case otpTextField1:
                otpTextField2.becomeFirstResponder()
                break
            case otpTextField2:
                otpTextField3.becomeFirstResponder()
                break
            case otpTextField3:
                otpTextField4.becomeFirstResponder()
                break
            case otpTextField4:
                otpTextField5.becomeFirstResponder()
                break
            case otpTextField5:
                otpTextField5.resignFirstResponder()
                break
            default:
                break
            }
        }else if text?.utf16.count==0{
            switch textField{
            case otpTextField:
                otpTextField.becomeFirstResponder()
            case otpTextField1:
                otpTextField.becomeFirstResponder()
            case otpTextField2:
                otpTextField1.becomeFirstResponder()
            case otpTextField3:
                otpTextField2.becomeFirstResponder()
            case otpTextField4:
                otpTextField3.becomeFirstResponder()
            case otpTextField5:
                otpTextField4.becomeFirstResponder()
            default:
                break
            }
        }
    }
    
    // MARK:- Service call
    
    //Phone number verification with otp api called.
    func sendOtpToMobile(code:String,phoneNo:String){
        
        let paramDict = [ApiKeyConstants.kCountry_code : code,
                         ApiKeyConstants.kMobile_number : Utility.trimmingString(phoneNo)]
        let sendOtpApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kForgotPasswordSendOtp
        Utility.removeAppCookie()
        APIWrapper.requestPOSTURL(sendOtpApi, params: paramDict as [String : AnyObject] , headers: [:], success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                    let dict:[String : Any] = dictResponse![ApiKeyConstants.kResult] as? [String : Any] ?? [:]
                    
                    self.securityCode = dict[ApiKeyConstants.kSecurityCode] as? String ?? ""
                    
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            }
            else{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
        })
        { (error) -> Void in
            
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton,self)
        }
    }
    
    //Phone number verification with otp api called.
    func sendOtpToMobileForUpdate(code:String,phoneNo:String){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let token = "Bearer " + authToken
        debugPrint("Token For Update",token)
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
        let paramDict = [ApiKeyConstants.kCountry_code : code,
                         ApiKeyConstants.kMobile_number : Utility.trimmingString(phoneNo)]
        let sendOtpApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kSendOtpForUpdateProfie
        Utility.removeAppCookie()
        APIWrapper.requestPUTURL(sendOtpApi, params: paramDict as [String : AnyObject] , headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        let dict:[String : Any] = dictResponse![ApiKeyConstants.kResult] as? [String : Any] ?? [:]
                        
                        self.securityCode = dict[ApiKeyConstants.kSecurityCode] as? String ?? ""
                        
                    }
                    else{
                        self.dismiss(animated: true, completion: nil)
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton,self)
                    }
                }
                else{
                    self.dismiss(animated: true, completion: nil)
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton,self)
                }
            }
            else{
                self.dismiss(animated: true, completion: nil)
                Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton,self)
            }
        })
        { (error) -> Void in
            self.dismiss(animated: true, completion: nil)
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // Otp verification api called for update profile.
    func verifyOtpToMobileForUpdateProfile(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let token = "Bearer " + authToken
        debugPrint("Token For Update",token)
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
        if ((otpTextField.text?.isEmpty)! || (otpTextField1.text?.isEmpty)! || (otpTextField2.text?.isEmpty)! || (otpTextField3.text?.isEmpty)! || (otpTextField4.text?.isEmpty)! || (otpTextField5.text?.isEmpty)!){
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterVerificationCode, Button_Title: Constants.AppAlertAction.kOKButton,self)
        }
        else{
            var otpPhone = otpTextField.text!
            otpPhone += otpTextField1.text!
            otpPhone += otpTextField2.text!
            otpPhone += otpTextField3.text!
            otpPhone += otpTextField4.text!
            otpPhone += otpTextField5.text!
            
            let paramDict = [ApiKeyConstants.kCountry_code : countryCode,
                             ApiKeyConstants.kMobile_number : phoneNumber,
                             ApiKeyConstants.kSecurityCode : otpPhone]
            let sendOtpApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kVerifyOtpForUpdateProfile
            Utility.removeAppCookie()
            APIWrapper.requestPOSTURL(sendOtpApi, params: paramDict as [String : AnyObject] , headers: dictHeaderParams, success: { (JSONResponse) in
                let jsonValue = JSONResponse
                let dictResponse = jsonValue.dictionaryObject
                
                debugPrint(dictResponse!)
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        
                        //                        let dict:[String : Any] = dictResponse![ApiKeyConstants.kResult] as? [String : Any] ?? [:]
                        self.callback?(true as Bool)
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    else{
                        self.dismiss(animated: true, completion: nil)
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton,self)
                    }
                }
                else{
                    self.dismiss(animated: true, completion: nil)
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton,self)
                }
            })
            { (error) -> Void in
                self.dismiss(animated: true, completion: nil)
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton,self)
            }
        }
    }
    
    // MARK:- Network Change Observer Methods-----
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            debugPrint("Reachable via WiFi")
            Utility.isNetworkEnabled(targetView: self.view, targetedVC: self, message: Constants.AppAlertMessage.kBackToOnline, networkEnabled: true, btnMessage: "")
        case .cellular:
            debugPrint("Reachable via Cellular")
            Utility.isNetworkEnabled(targetView: self.view, targetedVC: self, message: Constants.AppAlertMessage.kBackToOnline, networkEnabled: true, btnMessage: "")
        case .none:
            debugPrint("Network not reachable")
            Utility.isNetworkEnabled(targetView: self.view, targetedVC: self, message: Constants.AppAlertMessage.kNoNetworkAccess, networkEnabled: false, btnMessage: "")
        case .unavailable:
            debugPrint("Network not available")
        }
    }

}

extension VerifyPhoneNumberPopupsViewController : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.keyboardType == .numberPad || textField.keyboardType == .phonePad {
            //            setDoneOnKeyboard()
            return true
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == otpTextField || textField == otpTextField1 || textField == otpTextField2 || textField == otpTextField3 || textField == otpTextField4 || textField == otpTextField5{
            let maxLength = 1
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        else{
            return true
        }
    }
    
}
