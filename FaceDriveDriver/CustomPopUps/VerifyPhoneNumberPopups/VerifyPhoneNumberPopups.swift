//
//  VerifyPhoneNumberPopups.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 28/01/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Reachability

protocol verifyAndEditPhoneNumberDelegate {
    func verifyPhoneNumber(isVerified : Bool)
     func editPhoneNumber(isEdited : Bool)
}



class VerifyPhoneNumberPopups: UIView, UIGestureRecognizerDelegate,UITextFieldDelegate {

    var verifyEditPhoneNumberDelegateObject : verifyAndEditPhoneNumberDelegate?
    
    @IBOutlet weak var backgroundView: UIView!
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
    @IBOutlet weak var verifyPhoneNumberTrailConstraints: NSLayoutConstraint!
    
    @IBAction func phoneNumberEditTap(_ sender: Any) {
        self.dismiss(animated: true)
        verifyEditPhoneNumberDelegateObject?.editPhoneNumber(isEdited: true)
    }
    
    @IBAction func resendOtpTap(_ sender: Any) {
        if isFromUpdate{
            self.sendOtpToMobileForUpdate(code: countryCode, phoneNo: phoneNumber)
        }
        else if isFromSignUp{
            self.getOtpDriverPhoneVerificationAtSignUp(code: countryCode, phoneNo: phoneNumber)
        }
        else{
            self.sendOtpToMobile(code: countryCode, phoneNo: phoneNumber)
        }
    }
    
    @IBAction func verifyPhoneNumberTap(_ sender: Any) {
        if isFromUpdate{
            self.verifyOtpToMobileForUpdateProfile()
        }
        else if isFromSignUp{
            self.verifyOtpToMobileForSignUp()
        }
        else{
            self.verifyOtpToMobile()
        }
        
    }
    
    class func instanceFromNib() -> VerifyPhoneNumberPopups{
        return UINib(nibName: "VerifyPhoneNumberPopups", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! VerifyPhoneNumberPopups
        
    }
    
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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView))
        tapGestureRecognizer.delegate = self
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
        self.show(animated: true)
        
    }

}

extension VerifyPhoneNumberPopups{
    
    func show(animated:Bool){
        
        if Utility.isPlusDevice(){
            self.verifyPhoneNumberTrailConstraints.constant = 20.0
        }
        else{
            self.verifyPhoneNumberTrailConstraints.constant = 60.0
        }
        
        otpTextField.becomeFirstResponder()
        self.backgroundView.alpha = 1
        self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
        UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)
        
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 1
            })
            
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIView.AnimationOptions(rawValue: 0), animations: {
                self.dialogView.center = self.center
                //self.dialogView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                debugPrint("Dialog Frame:",self.dialogView.frame)
            }, completion: { (completed) in
//                self.sendOtpToMobile(code: code, phoneNo: phone)
            })
        }else{
            self.backgroundView.alpha = 1
            self.dialogView.center  = self.center
        }
        if isFromUpdate{
            self.sendOtpToMobileForUpdate(code: countryCode, phoneNo: phoneNumber)
        }
        else if isFromSignUp{
            self.getOtpDriverPhoneVerificationAtSignUp(code: countryCode, phoneNo: phoneNumber)
        }
        else{
            self.sendOtpToMobile(code: countryCode, phoneNo: phoneNumber)
        }
    }
    
    func dismiss(animated:Bool){
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0
            }, completion: { (completed) in
                
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIView.AnimationOptions(rawValue: 0), animations: {
                self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
            }, completion: { (completed) in
                self.removeFromSuperview()
            })
        }else{
            self.removeFromSuperview()
        }
        
    }
    
    @objc func didTappedOnBackgroundView(){
        dismiss(animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.dialogView){
            return false
        }
        else{
            return true
        }
    }
    
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
    
//    func setDoneOnKeyboard() {
//        let keyboardToolbar = UIToolbar()
//        
//        keyboardToolbar.sizeToFit()
//        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
//        
//        keyboardToolbar.items = [flexBarButton, doneBarButton]
//        
//        
//        otpTextField.inputAccessoryView = keyboardToolbar
//        otpTextField1.inputAccessoryView = keyboardToolbar
//        otpTextField2.inputAccessoryView = keyboardToolbar
//        otpTextField3.inputAccessoryView = keyboardToolbar
//        otpTextField4.inputAccessoryView = keyboardToolbar
//        otpTextField5.inputAccessoryView = keyboardToolbar
//    }
//    
//    @objc func dismissKeyboard() {
//        
//        self.endEditing(true)
//    }
//    
    //    MARK : Phone number verification with otp api called.
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
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                    }
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                }
            })
            { (error) -> Void in
                
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
            }
        }
    
    //    MARK : Phone number verification with otp api called.
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
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                    }
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                }
            }
            else{
                Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
            }
        })
        { (error) -> Void in
            
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
        }
    }
    
    //    MARK: Get Otp for SignUp Mobile Verification.
    func getOtpDriverPhoneVerificationAtSignUp(code:String,phoneNo:String){
        
        let paramDict = [ApiKeyConstants.kCountry_code : code,
                         ApiKeyConstants.kMobile_number : Utility.trimmingString(phoneNo)]
        let sendOtpApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetOtpForMobileVerificationSignUp
        Utility.removeAppCookie()
        //"http://apps.nextdrive.deeccus.com:85/apps/driver/api/10650-driver-registration-step1"
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
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                    self.dismiss(animated: true)
                }
            }
            else{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                self.dismiss(animated: true)
            }
        })
        { (error) -> Void in
            
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
        }
    }
    
    //    MARK : Otp verification api called for Signup.
    func verifyOtpToMobileForSignUp(){
        
        if ((otpTextField.text?.isEmpty)! || (otpTextField1.text?.isEmpty)! || (otpTextField2.text?.isEmpty)! || (otpTextField3.text?.isEmpty)! || (otpTextField4.text?.isEmpty)! || (otpTextField5.text?.isEmpty)!){
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterVerificationCode, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
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
            let sendOtpApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kVerifyOtpForSignUp
            Utility.removeAppCookie()
//            "http://apps.nextdrive.deeccus.com:85/apps/driver/api/10660-driver-registration-step2"
            APIWrapper.requestPOSTURL(sendOtpApi, params: paramDict as [String : AnyObject] , headers: [:], success: { (JSONResponse) in
                let jsonValue = JSONResponse
                let dictResponse = jsonValue.dictionaryObject
                
                debugPrint(dictResponse!)
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        
                        self.verifyEditPhoneNumberDelegateObject?.verifyPhoneNumber(isVerified: true)
                        
                        self.dismiss(animated:true)
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                    }
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                }
            })
            { (error) -> Void in
                
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
            }
        }
    }
    
    //    MARK : Otp verification api called for update profile.
    func verifyOtpToMobileForUpdateProfile(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let token = "Bearer " + authToken
        debugPrint("Token For Update",token)
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
        if ((otpTextField.text?.isEmpty)! || (otpTextField1.text?.isEmpty)! || (otpTextField2.text?.isEmpty)! || (otpTextField3.text?.isEmpty)! || (otpTextField4.text?.isEmpty)! || (otpTextField5.text?.isEmpty)!){
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterVerificationCode, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
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
                            
                            //                        let dict:[String : Any] = dictResponse![ApiKeyConstants.kResult] as! [String : Any]
                            self.verifyEditPhoneNumberDelegateObject?.verifyPhoneNumber(isVerified: true)
                            
                            self.dismiss(animated:true)
                        }
                        else{
                            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                        }
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                    }
                })
                { (error) -> Void in
                    
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                }
            }
    }
    
    //    MARK : Otp verification api called.
    func verifyOtpToMobile(){
        
        if ((otpTextField.text?.isEmpty)! || (otpTextField1.text?.isEmpty)! || (otpTextField2.text?.isEmpty)! || (otpTextField3.text?.isEmpty)! || (otpTextField4.text?.isEmpty)! || (otpTextField5.text?.isEmpty)!){
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterVerificationCode, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
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
                let sendOtpApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kForgotPasswordVerifyOtp
            Utility.removeAppCookie()
            APIWrapper.requestPOSTURL(sendOtpApi, params: paramDict as [String : AnyObject] , headers: [:], success: { (JSONResponse) in
                    let jsonValue = JSONResponse
                    let dictResponse = jsonValue.dictionaryObject
                    
                    debugPrint(dictResponse!)
                    if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                        if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                            
    //                        let dict:[String : Any] = dictResponse![ApiKeyConstants.kResult] as! [String : Any]
                            self.verifyEditPhoneNumberDelegateObject?.verifyPhoneNumber(isVerified: true)
                            
                            self.dismiss(animated:true)
                        }
                        else{
                            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                        }
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                    }
                })
                { (error) -> Void in
                    
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                }
            }
    }
    
    // MARK:- Network Change Observer Methods-----
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            debugPrint("Reachable via WiFi")
            Utility.isNetworkEnabled(targetView: (self.window?.rootViewController!.view)!, targetedVC: self.window!.rootViewController!, message: Constants.AppAlertMessage.kBackToOnline, networkEnabled: true, btnMessage: "")
        case .cellular:
            debugPrint("Reachable via Cellular")
            Utility.isNetworkEnabled(targetView: (self.window?.rootViewController!.view)!, targetedVC: self.window!.rootViewController!, message: Constants.AppAlertMessage.kBackToOnline, networkEnabled: true, btnMessage: "")
        case .none:
            debugPrint("Network not reachable")
            Utility.isNetworkEnabled(targetView: (self.window?.rootViewController!.view)!, targetedVC: self.window!.rootViewController!, message: Constants.AppAlertMessage.kNoNetworkAccess, networkEnabled: false, btnMessage: "")
        case .unavailable:
            debugPrint("Network not available")
        }
    }
}

