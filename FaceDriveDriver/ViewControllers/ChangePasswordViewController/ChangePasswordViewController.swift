//
//  ChangePasswordViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 26/02/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON
import Reachability


class ChangePasswordViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var changePasswordTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    // MARK:- All Button Actions-----
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTap(_ sender: Any) {
        let currentPasswordIndexPath = IndexPath(row: 0, section: 0)
        let newPasswordIndexPath = IndexPath(row: 1, section: 0)
        let confirmPasswordIndexPath = IndexPath(row: 2, section: 0)
        
        let currentPasswordCell = changePasswordTableView.cellForRow(at: currentPasswordIndexPath) as! ChangePasswordTableViewCell
        let newPasswordCell = changePasswordTableView.cellForRow(at: newPasswordIndexPath) as! ChangePasswordTableViewCell
        let confirmPasswordCell = changePasswordTableView.cellForRow(at: confirmPasswordIndexPath) as! ChangePasswordTableViewCell
        
        if Utility.IsEmtyString(currentPasswordCell.dataTextField.text){
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterOldPassword, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
        else{
            if Utility.IsEmtyString(newPasswordCell.dataTextField.text){
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterNewPassword, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
            else{
                if Utility.IsEmtyString(confirmPasswordCell.dataTextField.text){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kConfirmPassword, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
                else{
                    if Utility.isEqualtoString(newPasswordCell.dataTextField.text!, confirmPasswordCell.dataTextField.text!){
                        if (confirmPasswordCell.dataTextField.text!.count >= 6){
                            if Utility.isEqualtoString(currentPasswordCell.dataTextField.text!, confirmPasswordCell.dataTextField.text!){
                                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kOldPasswordCheck, Button_Title: Constants.AppAlertAction.kOKButton, self)
                            }
                            else{
                                if Reachibility.isConnectedToNetwork(){
                                    //Change Password Api Called.
                                    changePasswordApiCalled()
                                }
                                else{
                                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
                                }
                            }
                        }
                        else{
                            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidPasswordAlert, Button_Title: Constants.AppAlertAction.kOKButton, self)
                        }
                        
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNewPasswordConfirmPasswordCheck, Button_Title: Constants.AppAlertAction.kOKButton, self)
                        
                    }
                }
            }
        }
    }
    
    @objc func showHiddenTap(sender:UIButton!){
        if sender.tag == 0{
            let indexPath = IndexPath(row: 0, section: 0)
            let passwordCell = changePasswordTableView.cellForRow(at: indexPath) as! ChangePasswordTableViewCell
            passwordCell.dataTextField.isSecureTextEntry = !passwordCell.dataTextField.isSecureTextEntry
            if passwordCell.dataTextField.isSecureTextEntry{
                passwordCell.showHideButton.setImage(UIImage(named: "EyeOff"), for: .normal)
            }
            else{
                passwordCell.showHideButton.setImage(UIImage(named: "EyeOn"), for: .normal)
            }
        }
        else if sender.tag == 1{
            let indexPath = IndexPath(row: 1, section: 0)
            let passwordCell = changePasswordTableView.cellForRow(at: indexPath) as! ChangePasswordTableViewCell
            passwordCell.dataTextField.isSecureTextEntry = !passwordCell.dataTextField.isSecureTextEntry
            if passwordCell.dataTextField.isSecureTextEntry{
                passwordCell.showHideButton.setImage(UIImage(named: "EyeOff"), for: .normal)
            }
            else{
                passwordCell.showHideButton.setImage(UIImage(named: "EyeOn"), for: .normal)
            }
        }
        else{
            let indexPath = IndexPath(row: 2, section: 0)
            let passwordCell = changePasswordTableView.cellForRow(at: indexPath) as! ChangePasswordTableViewCell
            passwordCell.dataTextField.isSecureTextEntry = !passwordCell.dataTextField.isSecureTextEntry
            if passwordCell.dataTextField.isSecureTextEntry{
                passwordCell.showHideButton.setImage(UIImage(named: "EyeOff"), for: .normal)
            }
            else{
                passwordCell.showHideButton.setImage(UIImage(named: "EyeOn"), for: .normal)
            }
        }
    }
    
    // MARK:- TableView Delegate & DataSource Methods-----
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let changePasswordCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kChangePasswordCell) as! ChangePasswordTableViewCell
        //changePasswordCell.headerLabel.font = UIFont(name: "Roboto-Light", size: 16.0)
        if indexPath.row == 0{
            changePasswordCell.dataTextField.placeholder = "Current Password"
            changePasswordCell.showHideButton.tag = indexPath.row
            changePasswordCell.dataTextField.tag = indexPath.row
            changePasswordCell.showHideButton.addTarget(self, action: #selector(showHiddenTap(sender:)), for: .touchUpInside)
            if changePasswordCell.dataTextField.isSecureTextEntry{
                changePasswordCell.showHideButton.setImage(UIImage(named: "EyeOff"), for: .normal)
            }
            else{
                changePasswordCell.showHideButton.setImage(UIImage(named: "EyeOn"), for: .normal)
            }
        }
        else if indexPath.row == 1{
            changePasswordCell.dataTextField.placeholder = "New Password"
            changePasswordCell.showHideButton.tag = indexPath.row
            changePasswordCell.dataTextField.tag = indexPath.row
            changePasswordCell.showHideButton.addTarget(self, action: #selector(showHiddenTap(sender:)), for: .touchUpInside)
            if changePasswordCell.dataTextField.isSecureTextEntry{
                changePasswordCell.showHideButton.setImage(UIImage(named: "EyeOff"), for: .normal)
            }
            else{
                changePasswordCell.showHideButton.setImage(UIImage(named: "EyeOn"), for: .normal)
            }
        }
        else{
            changePasswordCell.dataTextField.placeholder = "Confirm New Password"
            changePasswordCell.showHideButton.tag = indexPath.row
            changePasswordCell.dataTextField.tag = indexPath.row
            changePasswordCell.showHideButton.addTarget(self, action: #selector(showHiddenTap(sender:)), for: .touchUpInside)
            if changePasswordCell.dataTextField.isSecureTextEntry{
                changePasswordCell.showHideButton.setImage(UIImage(named: "EyeOff"), for: .normal)
            }
            else{
                changePasswordCell.showHideButton.setImage(UIImage(named: "EyeOn"), for: .normal)
            }
        }
        return changePasswordCell
    }
    
    // MARK:- ChangePassword Api Called -------
    func changePasswordApiCalled(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let token = "Bearer " + authToken
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
        let updatePasswordUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kUpdatePassword
        
        let currentPasswordIndexPath = IndexPath(row: 0, section: 0)
        let newPasswordIndexPath = IndexPath(row: 1, section: 0)
        
        let currentPasswordCell = changePasswordTableView.cellForRow(at: currentPasswordIndexPath) as! ChangePasswordTableViewCell
        let newPasswordCell = changePasswordTableView.cellForRow(at: newPasswordIndexPath) as! ChangePasswordTableViewCell
        
        let dictParams = ["old_password" : currentPasswordCell.dataTextField.text ?? "" ,"new_password" : newPasswordCell.dataTextField.text ?? ""] as [String : Any]
        debugPrint(dictParams)
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Change Password...")
        }
        Utility.removeAppCookie()
        APIWrapper.requestPUTURL(updatePasswordUrl, params: dictParams as [String : AnyObject], headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        let changePasswordAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String, preferredStyle: .alert)
                        changePasswordAlert.view.tintColor = Constants.AppColour.kAppGreenColor
                        let ok = UIAlertAction(title: Constants.AppAlertAction.kOKButton, style: .default) { (action) in
                            self.navigationController?.popViewController(animated: true)
                        }
                        changePasswordAlert.addAction(ok)
                        
                        self.present(changePasswordAlert, animated: true, completion: nil)
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    }
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            }
            else{
                Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
            
        })
        { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            debugPrint("Error :",error)
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }

    // MARK:- TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentPasswordIndexPath = IndexPath(row: 0, section: 0)
        let newPasswordIndexPath = IndexPath(row: 1, section: 0)
        let confirmPasswordIndexPath = IndexPath(row: 2, section: 0)
        
        let currentPasswordCell = changePasswordTableView.cellForRow(at: currentPasswordIndexPath) as! ChangePasswordTableViewCell
        let newPasswordCell = changePasswordTableView.cellForRow(at: newPasswordIndexPath) as! ChangePasswordTableViewCell
        let confirmPasswordCell = changePasswordTableView.cellForRow(at: confirmPasswordIndexPath) as! ChangePasswordTableViewCell
        if textField == currentPasswordCell.dataTextField || textField == confirmPasswordCell.dataTextField || textField == newPasswordCell.dataTextField {
            if (string == " ") {
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        let cellIndex = IndexPath(row: nextTag, section: 0)
        let cell = changePasswordTableView.cellForRow(at: cellIndex) as? ChangePasswordTableViewCell
        if cell != nil {
          let _ =  cell?.dataTextField.becomeFirstResponder()
        }
        else{
            textField.resignFirstResponder()
        }
        return true
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
