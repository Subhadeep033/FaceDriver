//
//  ForgotPassViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 1/23/19.
//  Copyright © 2019 DAT-Asset-115-DAPL. All rights reserved.
//

import UIKit
import SVProgressHUD
import Reachability

class ForgotPassViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ForgotPasswordOtpDelegate {
    
    @IBOutlet var img_closedTab: UIImageView!
    
    @IBOutlet var btn_closedTab: UIButton!
    
    @IBOutlet var img_arrow: UIImageView!
    @IBOutlet var tableView_forgotPass: UITableView!
    var phoneTabOpened = true
    var OTPTabOppened = false
    var setPassOppened = false
    var isResendOtpTap = Bool()
    var isVerificationCodeSent = Bool()
    var isVerified = Bool()
    var isPasswordChanged = Bool()
    var registeredMobileNumber = String()
    var securityCode = String()
    var userId = String()
    var tableOriginY = CGFloat()
    var otpArr = [String]()
    var setPassWord = String()
    var newPassword = String()
    var isInitial = Bool()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        tableOriginY = tableView_forgotPass.frame.origin.y
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- Keyboard Observer Method---
    @objc func keyboardWillShow(notification: NSNotification) {
        //if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3) {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= 150
                }
                self.view.layoutIfNeeded()
            }
            
        //}
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK:- TableView Delegate & Datasource ----
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if phoneTabOpened
            {
                return 328
            }
            else
            {
                return 105
            }
        }
        else if indexPath.row == 1
        {
            if OTPTabOppened
            {
                return 248
            }
            else
            {
               return 105
            }
        }
        else
        {
            if setPassOppened
            {
                return 309
            }
            else
            {
                return 73
            }
        }
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cellPhoneNumberForgotPassTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kForgotPasswordTableCell, for: indexPath) as! PhoneNumberForgotPassTableViewCell
            
            if phoneTabOpened
            {
               cellPhoneNumberForgotPassTableViewCell.btn_closedTab.addTarget(self, action: #selector(tabOpenClose(sender:)), for: .touchUpInside)
                cellPhoneNumberForgotPassTableViewCell.img_closedTab.isHidden = true
                cellPhoneNumberForgotPassTableViewCell.img_TabBG.isHidden = false
                cellPhoneNumberForgotPassTableViewCell.view_extendedBG.isHidden = false
                cellPhoneNumberForgotPassTableViewCell.txtFld_mobileNumber.text = registeredMobileNumber
                
                if isVerificationCodeSent {
                    cellPhoneNumberForgotPassTableViewCell.img_stepOver.image = UIImage.init(named: "stepComplete")
                }
                else{
                    cellPhoneNumberForgotPassTableViewCell.img_stepOver.image = UIImage.init(named: "stepIncomplete")
                }
                cellPhoneNumberForgotPassTableViewCell.img_arrow.image = UIImage.init(named: "downArrowGreen")
                cellPhoneNumberForgotPassTableViewCell.sendOtpBtn.addTarget(self, action: #selector(sendOtpBtnTap(sender:)), for: .touchUpInside)
                
                
            }
            else
            {
            cellPhoneNumberForgotPassTableViewCell.btn_closedTab.addTarget(self, action: #selector(tabOpenClose(sender:)), for: .touchUpInside)
                cellPhoneNumberForgotPassTableViewCell.img_closedTab.isHidden = false
                cellPhoneNumberForgotPassTableViewCell.img_TabBG.isHidden = true
                cellPhoneNumberForgotPassTableViewCell.view_extendedBG.isHidden = true
                cellPhoneNumberForgotPassTableViewCell.txtFld_mobileNumber.text = registeredMobileNumber
                
                if isVerificationCodeSent {
                    cellPhoneNumberForgotPassTableViewCell.img_stepOver.image = UIImage.init(named: "stepComplete")
                }
                else{
                    cellPhoneNumberForgotPassTableViewCell.img_stepOver.image = UIImage.init(named: "stepIncomplete")
                }
                cellPhoneNumberForgotPassTableViewCell.img_arrow.image = UIImage.init(named: "nextArrow")
                
            }
            return cellPhoneNumberForgotPassTableViewCell
        }
        else if indexPath.row == 1
        {
            let cellForgotPassOTPTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kForgotPasswordOTPTableCell, for: indexPath) as! ForgotPassOTPTableViewCell
                cellForgotPassOTPTableViewCell.verifyPasswordDelegate = self
            if OTPTabOppened
            {
                cellForgotPassOTPTableViewCell.btn_closedTab.addTarget(self, action: #selector(tabOpenClose(sender:)), for: .touchUpInside)
                cellForgotPassOTPTableViewCell.img_tabBG.isHidden = false
                cellForgotPassOTPTableViewCell.view_extendedTab.isHidden = false
                cellForgotPassOTPTableViewCell.img_closedTab.isHidden = true
                
                if isVerified {
                    cellForgotPassOTPTableViewCell.img_stepOver.image = UIImage.init(named: "stepComplete")
                    cellForgotPassOTPTableViewCell.otpBoxTextField1.text = otpArr[0]
                    cellForgotPassOTPTableViewCell.otpBoxTextField2.text = otpArr[1]
                    cellForgotPassOTPTableViewCell.otpBoxTextField3.text = otpArr[2]
                    cellForgotPassOTPTableViewCell.otpBoxTextField4.text = otpArr[3]
                    cellForgotPassOTPTableViewCell.otpBoxTextField5.text = otpArr[4]
                    cellForgotPassOTPTableViewCell.otpBoxTextField6.text = otpArr[5]
                }
                else{
                    cellForgotPassOTPTableViewCell.img_stepOver.image = UIImage.init(named: "stepIncomplete")
                }
                cellForgotPassOTPTableViewCell.img_arrow.image = UIImage.init(named: "downArrowGreen")
                cellForgotPassOTPTableViewCell.resendPinBtn.addTarget(self, action: #selector(sendOtpBtnTap(sender:)), for: .touchUpInside)
            }
            else
            {
                cellForgotPassOTPTableViewCell.btn_closedTab.addTarget(self, action: #selector(tabOpenClose(sender:)), for: .touchUpInside)
                cellForgotPassOTPTableViewCell.img_tabBG.isHidden = true
                cellForgotPassOTPTableViewCell.view_extendedTab.isHidden = true
                cellForgotPassOTPTableViewCell.img_closedTab.isHidden = false
                
                if isVerified {
                    cellForgotPassOTPTableViewCell.img_stepOver.image = UIImage.init(named: "stepComplete")
                    cellForgotPassOTPTableViewCell.otpBoxTextField1.text = otpArr[0]
                    cellForgotPassOTPTableViewCell.otpBoxTextField2.text = otpArr[1]
                    cellForgotPassOTPTableViewCell.otpBoxTextField3.text = otpArr[2]
                    cellForgotPassOTPTableViewCell.otpBoxTextField4.text = otpArr[3]
                    cellForgotPassOTPTableViewCell.otpBoxTextField5.text = otpArr[4]
                    cellForgotPassOTPTableViewCell.otpBoxTextField6.text = otpArr[5]
                    
                }
                else{
                    cellForgotPassOTPTableViewCell.img_stepOver.image = UIImage.init(named: "stepIncomplete")
                }
                cellForgotPassOTPTableViewCell.img_arrow.image = UIImage.init(named: "nextArrow")
//                cellForgotPassOTPTableViewCell.view_extendedTab.frame =
            }
            return cellForgotPassOTPTableViewCell
        }
        else{
            let cellSetPasswordForgotPassTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kForgotPasswordSetPasswordTableCell, for: indexPath) as! SetPasswordForgotPassTableViewCell
            if setPassOppened
            {
                cellSetPasswordForgotPassTableViewCell.btn_closedTab.addTarget(self, action: #selector(tabOpenClose(sender:)), for: .touchUpInside)
                cellSetPasswordForgotPassTableViewCell.img_tabBG.isHidden = false
                cellSetPasswordForgotPassTableViewCell.view_extendedBG.isHidden = false
                cellSetPasswordForgotPassTableViewCell.img_closedTab.isHidden = true
                if isPasswordChanged {
                    cellSetPasswordForgotPassTableViewCell.img_stepOver.image = UIImage.init(named: "stepComplete")
                    cellSetPasswordForgotPassTableViewCell.setNewPasswordTextField.text = setPassWord
                    cellSetPasswordForgotPassTableViewCell.reEnterPasswordTextField.text = newPassword
                }
                else{
                    cellSetPasswordForgotPassTableViewCell.img_stepOver.image = UIImage.init(named: "stepIncomplete")
                    
                }
                cellSetPasswordForgotPassTableViewCell.img_arrow.image = UIImage.init(named: "downArrowGreen")
                cellSetPasswordForgotPassTableViewCell.setPasswordDoneBtnTap.addTarget(self, action: #selector(setPassDoneBtnTap(sender:)), for: .touchUpInside)
            }
            else
            {
                cellSetPasswordForgotPassTableViewCell.btn_closedTab.addTarget(self, action: #selector(tabOpenClose(sender:)), for: .touchUpInside)
                cellSetPasswordForgotPassTableViewCell.img_tabBG.isHidden = true
                cellSetPasswordForgotPassTableViewCell.view_extendedBG.isHidden = true
                cellSetPasswordForgotPassTableViewCell.img_closedTab.isHidden = false
                if isPasswordChanged {
                    cellSetPasswordForgotPassTableViewCell.img_stepOver.image = UIImage.init(named: "stepComplete")
                    cellSetPasswordForgotPassTableViewCell.setNewPasswordTextField.text = setPassWord
                    cellSetPasswordForgotPassTableViewCell.reEnterPasswordTextField.text = newPassword
                    
                }
                else{
                    cellSetPasswordForgotPassTableViewCell.img_stepOver.image = UIImage.init(named: "stepIncomplete")
                    
                }
                cellSetPasswordForgotPassTableViewCell.img_arrow.image = UIImage.init(named: "nextArrow")
            }
                //                cellForgotPassOTPTableViewCell.view_extendedTab.frame =
            return cellSetPasswordForgotPassTableViewCell
        }
    }
    
    //MARK:- Verify OTP Delegate -----
    func verifyOtpDelegateCalled() {
        if Reachibility.isConnectedToNetwork(){
            verifyOtpToMobile()
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    //MARK:- All Button Action ----
    @objc func tabOpenClose(sender:UIButton!) {
        if sender.tag == 1024
        {
            phoneTabOpened = (phoneTabOpened) ? (false):(true)
            let indexPath = IndexPath(item: 0, section: 0)
            tableView_forgotPass.reloadRows(at: [indexPath], with: .top)
        }
        else if sender.tag == 1025
        {
            if isVerificationCodeSent {
                OTPTabOppened = (OTPTabOppened) ? (false):(true)
                let indexPath = IndexPath(item: 1, section: 0)
                tableView_forgotPass.reloadRows(at: [indexPath], with: .top)
            }
            else{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kCompleteStageOne, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
        }
        else if sender.tag == 1026
        {
            if isVerified {
                setPassOppened = (setPassOppened) ? (false):(true)
                let indexPath = IndexPath(item: 2, section: 0)
                tableView_forgotPass.reloadRows(at: [indexPath], with: .top)
            }
            else{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kCompleteStageTwo, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
        }
    }
    
    @IBAction func Click_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //    MARK : Send Otp Phone Number Verification.
    @objc func sendOtpBtnTap(sender:UIButton!) {
        if sender.tag == 1{
            isResendOtpTap = true
        }
        else{
            isResendOtpTap = false
        }
        if Reachibility.isConnectedToNetwork(){
            sendOtpToMobile()
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    //    MARK : Done Button Action For Password Change.
    @objc func setPassDoneBtnTap(sender:UIButton!){
        if Reachibility.isConnectedToNetwork(){
            changePasswordApiCalled()
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    
    //MARK:- Phone number verification with otp api called.
    func sendOtpToMobile(){
        let indexPath = IndexPath(row: 0, section: 0)
        let phoneNumberCell : PhoneNumberForgotPassTableViewCell = tableView_forgotPass.cellForRow(at: indexPath) as! PhoneNumberForgotPassTableViewCell
        if ((phoneNumberCell.countryCodeLabel.text?.isEmpty)! || (phoneNumberCell.txtFld_mobileNumber.text?.isEmpty)!){
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterMobileNumberAndCountryCode, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
        else{
            registeredMobileNumber = Utility.trimmingString(phoneNumberCell.txtFld_mobileNumber.text!)
            DispatchQueue.main.async {
                SVProgressHUD.setContainerView(self.view)
                SVProgressHUD.show(withStatus: "Loading...")
            }
            let codeCountry = phoneNumberCell.countryCodeLabel.text!.replacingOccurrences(of: "+", with: "")
            let paramDict = [ApiKeyConstants.kCountry_code : codeCountry,
                             ApiKeyConstants.kMobile_number : registeredMobileNumber] as [String : AnyObject]
            let sendOtpApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kForgotPasswordSendOtp
            Utility.removeAppCookie()
            APIWrapper.requestPOSTURL(sendOtpApi, params: paramDict , headers: [:], success: { (JSONResponse) in
                let jsonValue = JSONResponse
                let dictResponse = jsonValue.dictionaryObject
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                debugPrint(dictResponse!)
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        let dict:[String : Any] = dictResponse![ApiKeyConstants.kResult] as? [String : Any] ?? [:]
                        
                        self.securityCode = dict[ApiKeyConstants.kSecurityCode] as? String ?? ""
                        if self.isResendOtpTap {
                            
                        }
                        else{
                            self.phoneTabOpened = false
                            self.OTPTabOppened = true
                            self.isVerificationCodeSent = true
                            self.tableView_forgotPass.reloadData()
                            let indexPathToScroll = IndexPath(row: 1, section: 0)
                            self.tableView_forgotPass.scrollToRow(at: indexPathToScroll, at: .top, animated: false)
                            
                        }
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
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
        }
    }
    
    //MARK:- Otp verification api called.
    func verifyOtpToMobile(){
        let indexPath = IndexPath(row: 1, section: 0)
        let forgotPasswordCell : ForgotPassOTPTableViewCell = tableView_forgotPass.cellForRow(at: indexPath) as! ForgotPassOTPTableViewCell
        let indexPathPhoneCell = IndexPath(row: 0, section: 0)
        let phoneNumberCell : PhoneNumberForgotPassTableViewCell = tableView_forgotPass.cellForRow(at: indexPathPhoneCell) as! PhoneNumberForgotPassTableViewCell
        let codeCountry = phoneNumberCell.countryCodeLabel.text!.replacingOccurrences(of: "+", with: "")
        if ((forgotPasswordCell.otpBoxTextField1.text?.isEmpty)! || (forgotPasswordCell.otpBoxTextField2.text?.isEmpty)! || (forgotPasswordCell.otpBoxTextField3.text?.isEmpty)! || (forgotPasswordCell.otpBoxTextField4.text?.isEmpty)! || (forgotPasswordCell.otpBoxTextField5.text?.isEmpty)! || (forgotPasswordCell.otpBoxTextField6.text?.isEmpty)!){
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterVerificationCode, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
        else{
            otpArr.insert(forgotPasswordCell.otpBoxTextField1.text!, at: 0)
            otpArr.insert(forgotPasswordCell.otpBoxTextField2.text!, at: 1)
            otpArr.insert(forgotPasswordCell.otpBoxTextField3.text!, at: 2)
            otpArr.insert(forgotPasswordCell.otpBoxTextField4.text!, at: 3)
            otpArr.insert(forgotPasswordCell.otpBoxTextField5.text!, at: 4)
            otpArr.insert(forgotPasswordCell.otpBoxTextField6.text!, at: 5)
            var otpStr = forgotPasswordCell.otpBoxTextField1.text!
                otpStr += forgotPasswordCell.otpBoxTextField2.text!
                otpStr += forgotPasswordCell.otpBoxTextField3.text!
                otpStr += forgotPasswordCell.otpBoxTextField4.text!
                otpStr += forgotPasswordCell.otpBoxTextField5.text!
                otpStr += forgotPasswordCell.otpBoxTextField6.text!
            
            //if otpStr == securityCode {
                DispatchQueue.main.async {
                    SVProgressHUD.setContainerView(self.view)
                    SVProgressHUD.show(withStatus: "Loading...")
                }
                let paramDict = [ApiKeyConstants.kCountry_code : codeCountry,
                                 ApiKeyConstants.kMobile_number : registeredMobileNumber,
                                 ApiKeyConstants.kSecurityCode : otpStr]
                let sendOtpApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kForgotPasswordVerifyOtp
                Utility.removeAppCookie()
                APIWrapper.requestPOSTURL(sendOtpApi, params: paramDict as [String : AnyObject] , headers: [:], success: { (JSONResponse) in
                    let jsonValue = JSONResponse
                    let dictResponse = jsonValue.dictionaryObject
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    debugPrint(dictResponse!)
                    if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                        if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                            
                            let dict:[String : Any] = dictResponse![ApiKeyConstants.kResult] as? [String : Any] ?? [:]
                                self.userId = dict[ApiKeyConstants.kUser_id] as? String ?? ""
                            
                                self.OTPTabOppened = false
                                self.setPassOppened = true
                                self.isVerified = true
                                self.tableView_forgotPass.reloadData()
                                let indexPathToScroll = IndexPath(row: 2, section: 0)
                                self.tableView_forgotPass.scrollToRow(at: indexPathToScroll, at: .top, animated: false)
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
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
        }
    }
    
    //MARK:- Password change api called.
    func changePasswordApiCalled(){
        let indexPath = IndexPath(row: 2, section: 0)
        let changePasswordCell : SetPasswordForgotPassTableViewCell = tableView_forgotPass.cellForRow(at: indexPath) as! SetPasswordForgotPassTableViewCell
        
        if((changePasswordCell.setNewPasswordTextField.text?.isEmpty)! || (changePasswordCell.reEnterPasswordTextField.text?.isEmpty)!){
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterNewPassword, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
        else{
            if Utility.isEqualtoString(changePasswordCell.setNewPasswordTextField.text!, changePasswordCell.reEnterPasswordTextField.text!){
                DispatchQueue.main.async {
                    SVProgressHUD.setContainerView(self.view)
                    SVProgressHUD.show(withStatus: "Loading...")
                }
                let paramDict = [ApiKeyConstants.kUser_id : userId,
                                 ApiKeyConstants.kNewPassword : changePasswordCell.reEnterPasswordTextField.text!]
                
                let sendOtpApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kChangePassword
                Utility.removeAppCookie()
                APIWrapper.requestPOSTURL(sendOtpApi, params: paramDict as [String : AnyObject] , headers: [:], success: { (JSONResponse) in
                    let jsonValue = JSONResponse
                    let dictResponse = jsonValue.dictionaryObject
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    debugPrint(dictResponse!)
                    if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                        if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                            let alert = UIAlertController.init(title: Constants.AppAlertMessage.kAlertTitle, message: (dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong).capitalized, preferredStyle: .alert)
                            alert.view.tintColor = Constants.AppColour.kAppGreenColor
                            let okAction = UIAlertAction.init(title: Constants.AppAlertAction.kOKButton, style: .default, handler: { (action) in
                                self.isPasswordChanged = true
                                self.setPassWord = changePasswordCell.setNewPasswordTextField.text!
                                self.newPassword = changePasswordCell.reEnterPasswordTextField.text!
                                self.tableView_forgotPass.reloadData()
                                self.navigationController?.popViewController(animated: true)
                            })
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                            //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle,message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                            
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
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
                
            }
            else{
                
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kPasswordCheck, Button_Title: Constants.AppAlertAction.kOKButton, self)
                changePasswordCell.reEnterPasswordTextField.text = ""
                changePasswordCell.reEnterPasswordTextField.becomeFirstResponder()
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
