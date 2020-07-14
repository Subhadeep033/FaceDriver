//
//  SignInViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 22/01/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import Firebase
import SVProgressHUD
import SwiftyJSON
import FirebaseDatabase
import Reachability

class SignInViewController: UIViewController,UITextFieldDelegate,GIDSignInDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,EmailPassCheckDelegate,SignInOTPDelegate{ //GIDSignInUIDelegate
  
    fileprivate var search : String = ""
    fileprivate var keyboardshown : Bool = false
    fileprivate var userAuthToken = String()
    fileprivate var userID = String()
    fileprivate var tableDataCountry = [[String:String]]()
    fileprivate var tableSearchDataCountry = [[String:String]]()
    fileprivate var inPhoneSection = false
    fileprivate var signInRef: DatabaseReference!
    
    @IBOutlet weak var btnGoogle: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet var login_collectionView: UICollectionView!
    @IBOutlet var view_popupContainer: UIView!
    @IBOutlet var view_popup: UIView!
    @IBOutlet var tableView_Search: UITableView!
    @IBOutlet var btn_email: UIButton!
    @IBOutlet var btn_phone: UIButton!
    @IBOutlet var btn_SignIn: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    //    fileprivate var refHandle : DatabaseHandle!
    //var handle: UInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        searchTextField.setLeftPaddingPoints(20)
        searchTextField.setRightPaddingPoints(20)
        // Do any additional setup after loading the view, typically from a nib.
//        configureDatabase()
        
        login_collectionView.isScrollEnabled = false
        if let path = Bundle.main.path(forResource: "countryCodes", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                let json = try JSONSerialization.jsonObject(with: jsonData) as? [[String:String]] ?? [[:]]
                debugPrint(json)
                tableDataCountry = json
                tableDataCountry.remove(at: 0)
                tableSearchDataCountry = tableDataCountry
                
            } catch {
                // handle error
                let nsError = error as NSError
                debugPrint("Error = ",nsError.localizedDescription)
            }
        }
    }
    
//    private func configureDatabase()  {
//        signInRef = Database.database().reference()
//    }
    
    deinit{
        if (signInRef != nil){
           self.signInRef.removeAllObservers()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        Analytics.setScreenName("SignIn", screenClass: String(describing: self))
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- TableView Delegate & Datasource Methods -----
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSearchDataCountry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCountryCellId, for: indexPath) as! CountryTableViewCell
        cell.lbl_country.text = tableSearchDataCountry[indexPath.row][ApiKeyConstants.kDriverName]
        cell.lbl_countryDialCode.text = "+\(tableSearchDataCountry[indexPath.row]["dial_code"] ?? "")"
        cell.imgVw_CountryFlag.image = UIImage.init(named: "\(tableSearchDataCountry[indexPath.row]["code"] ?? "").png")
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = IndexPath(item: 1, section: 0)
        let refCell = login_collectionView.cellForItem(at: index as IndexPath) as! SignInOTPCollectionViewCell
        refCell.lbl_dialCode.text = "+\(tableSearchDataCountry[indexPath.row]["dial_code"] ?? "")"
        refCell.img_flg.image = UIImage.init(named: "\(tableSearchDataCountry[indexPath.row]["code"] ?? "").png")
        refCell.txtFld_mobileNumber.text = ""
        if inPhoneSection{
            btn_SignIn.isUserInteractionEnabled = false
        }
        self.view.endEditing(true)
        view_popupContainer.isHidden = true
        view_popup.isHidden = true
    }
    
    // MARK:- Phone Button Clicked -----
    @IBAction func Click_Phone(_ sender: UIButton) {
        if  !sender.isSelected {
            inPhoneSection = true
            sender.isSelected = true
            btn_email.isSelected = true
            btn_email.titleLabel?.font =  UIFont(name: "Roboto-Medium", size: 15)
            btn_phone.titleLabel?.font =  UIFont(name: "Roboto-Medium", size: 19)
            btn_SignIn.setTitle("Send Code", for: .normal)
            btn_SignIn.setTitleColor(UIColor.white, for: .normal)
            btn_SignIn.isUserInteractionEnabled = true
            btn_SignIn.alpha = 0.7
            
            let emailIndex = IndexPath(row: 0, section: 0)
            let emailCell = login_collectionView.cellForItem(at: emailIndex) as! LoginCollectionViewCell
            emailCell.txtFld_email.text = ""
            emailCell.txtFld_password.text = ""
        }
        self.view.endEditing(true)
        
        let indexPath = NSIndexPath(row: 1, section: 0)
        login_collectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
        
    }
    
    // MARK:- SignIn Button Click ------
    @IBAction func Click_SignIn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.btn_SignIn.isUserInteractionEnabled = false
        self.btnFacebook.isUserInteractionEnabled = false
        self.btnGoogle.isUserInteractionEnabled = false
        if !inPhoneSection {
            let index = IndexPath(item: 0, section: 0)
            let refCell = login_collectionView.cellForItem(at: index as IndexPath) as! LoginCollectionViewCell
            if Utility.IsEmtyString(Utility.trimmingString(refCell.txtFld_email.text?.lowercased() ?? "")) {
                btn_SignIn.isUserInteractionEnabled = true
                self.btnFacebook.isUserInteractionEnabled = true
                self.btnGoogle.isUserInteractionEnabled = true
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterEmailIdAlert, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
            else{
                if !Utility.isValidEmail(testStr: Utility.trimmingString(refCell.txtFld_email.text!.lowercased())) {
                    self.btnFacebook.isUserInteractionEnabled = true
                    self.btnGoogle.isUserInteractionEnabled = true
                    btn_SignIn.isUserInteractionEnabled = true
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidEmailIdAlert, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
                else if Utility.IsEmtyString(refCell.txtFld_password.text) || refCell.txtFld_password.text?.count ?? 0 < 5
                {
                    self.btnFacebook.isUserInteractionEnabled = true
                    self.btnGoogle.isUserInteractionEnabled = true
                    btn_SignIn.isUserInteractionEnabled = true
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterPasswordAlert, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
                else
                {
                    if Reachibility.isConnectedToNetwork(){
                        EmailLoginPassword(Utility.trimmingString(refCell.txtFld_email.text?.lowercased() ?? ""), Utility.trimmingString(refCell.txtFld_password.text ?? ""))
                    }
                    else{
                        btn_SignIn.isUserInteractionEnabled = true
                        self.btnFacebook.isUserInteractionEnabled = true
                        self.btnGoogle.isUserInteractionEnabled = true
                        
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    }
                }
            }
        }
        else
        {
            let index = IndexPath(item: 1, section: 0)
            let refCell = login_collectionView.cellForItem(at: index as IndexPath) as! SignInOTPCollectionViewCell
            if Utility.isEqualtoString(sender.title(for: .normal) ?? "", "Send Code")
            {
                
                if Utility.IsEmtyString(refCell.lbl_dialCode.text!) || Utility.IsEmtyString(refCell.txtFld_mobileNumber.text!){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterMobileNumberAndCountryCode, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
                else if !Utility.isValidPhoneNumber(testStr: refCell.txtFld_mobileNumber.text!){
                    refCell.txtFld_mobileNumber.resignFirstResponder()
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidPhoneNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
                else{
//                    if Reachibility.isConnectedToNetwork(){
                        validatePhoneNumberThroughOTP(phoneNumber: Utility.trimmingString(refCell.txtFld_mobileNumber.text!))
                   /* }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
                        
                    }*/
                }
            }
            else{
                if Utility.IsEmtyString(refCell.txtFld_OTP_one.text) || Utility.IsEmtyString(refCell.txtFld_OTP_second.text) || Utility.IsEmtyString(refCell.txtFld_OTP_third.text) || Utility.IsEmtyString(refCell.txtFld_OTP_fourth.text) || Utility.IsEmtyString(refCell.txtFld_OTP_fifth.text) || Utility.IsEmtyString(refCell.txtFld_OTP_sixth.text) {
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterOtpToValidatePhoneNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
                else{
                    //                    Verify otp api called.
                    var securityCode = refCell.txtFld_OTP_one.text!
                    securityCode += refCell.txtFld_OTP_second.text!
                    securityCode += refCell.txtFld_OTP_third.text!
                    securityCode += refCell.txtFld_OTP_fourth.text!
                    securityCode += refCell.txtFld_OTP_fifth.text!
                    securityCode += refCell.txtFld_OTP_sixth.text!
                    
                    let code = refCell.lbl_dialCode.text!.replacingOccurrences(of: "+", with: "")
                    if Reachibility.isConnectedToNetwork(){
                        self.verifyPhoneNumberWithOtp(phone: refCell.txtFld_mobileNumber.text!, countryCode: code, securityCode: securityCode)
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    }
                }
            }
        }
    }
    
    // MARK:- Keyboard Notification ----
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 && !keyboardshown{
                self.view.frame.origin.y -= 95
                keyboardshown = true
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
                keyboardshown = false
            }
        }
    }
    
    // MARK:- Google Sign In Button -----
    @IBAction func Click_GoogleSignIn(_ sender: Any) {
        btn_SignIn.isUserInteractionEnabled = false
        btnFacebook.isUserInteractionEnabled = false
        btnGoogle.isUserInteractionEnabled = false
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signOut()
        //GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    //MARK:- Google Delegate
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                     withError error: Error!) {
        if (error == nil) {
//            debugPrint("Google User = ",user)
            let userData = JSON(user)
            debugPrint("Google User = ",userData)
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            if user.profile.hasImage {
                let pic = user.profile.imageURL(withDimension: 100)
                debugPrint("Pic",pic as Any)
            }
            btn_SignIn.isUserInteractionEnabled = true
            btnFacebook.isUserInteractionEnabled = true
            btnGoogle.isUserInteractionEnabled = true
            
            debugPrint("\(userId ?? "Not Avialble"),\(idToken ?? "Not Avialble"),\(fullName ?? "Not Avialble"),\(givenName ?? "Not Avialble"),\(familyName ?? "Not Avialble"),\(email?.lowercased() ?? "Not Avialble")")
            socialLogin(userId ?? "", social_type: "google", email: email ?? "")
            // ...
        } else {
            btn_SignIn.isUserInteractionEnabled = true
            btnFacebook.isUserInteractionEnabled = true
            btnGoogle.isUserInteractionEnabled = true
            debugPrint("\(error ?? "Not Available" as! Error)")
        }
    }
    
    // MARK:- Email Button Click ----
    @IBAction func Click_mail(_ sender: UIButton) {
        if sender.isSelected {
            inPhoneSection = false
            sender.isSelected = false
            btn_phone.isSelected = false
            sender.titleLabel?.font =  UIFont(name: "Roboto-Medium", size: 19)
            btn_phone.titleLabel?.font =  UIFont(name: "Roboto-Medium", size: 15)
            btn_SignIn.setTitle("Sign In", for: .normal)
            btn_SignIn.isUserInteractionEnabled = true
            btnFacebook.isUserInteractionEnabled = true
            btnGoogle.isUserInteractionEnabled = true
            btn_SignIn.alpha = 1.0
            
            let otpIndex = IndexPath(row: 1, section: 0)
            let otpCell = login_collectionView.cellForItem(at: otpIndex) as! SignInOTPCollectionViewCell
            otpCell.txtFld_mobileNumber.text = ""
            otpCell.txtFld_OTP_one.text = ""
            otpCell.txtFld_OTP_second.text = ""
            otpCell.txtFld_OTP_third.text = ""
            otpCell.txtFld_OTP_fourth.text = ""
            otpCell.txtFld_OTP_fifth.text = ""
            otpCell.txtFld_OTP_sixth.text = ""
        }
        else{
            btn_SignIn.isUserInteractionEnabled = true
            btnFacebook.isUserInteractionEnabled = true
            btnGoogle.isUserInteractionEnabled = true
        }
        self.view.endEditing(true)
        
        let indexPath = NSIndexPath(row: 0, section: 0)
        login_collectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
    }
    
    // MARK:- UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.TableCellId.kLoginCollectionCell, for: indexPath as IndexPath) as! LoginCollectionViewCell
        cell.delegate = self
        let cellOTP = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.TableCellId.kSignUpCollectionCell, for: indexPath as IndexPath) as!SignInOTPCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        if indexPath.row == 0 {
            //           cell.backgroundColor = UIColor.cyan
            cell.btn_eyeOpenClose.addTarget(self, action: #selector(eyeOpenClose(sender:)), for: .touchUpInside)
            cell.btn_forgotPassword.addTarget(self, action: #selector(callForgotPassword(sender:)), for: .touchUpInside)
            return cell
        }
        else
        {
//            cellOTP.txtFld_mobileNumber.addDoneButtonToKeyboard(myAction:  #selector(cellOTP.txtFld_mobileNumber.resignFirstResponder))
            cellOTP.txtFld_mobileNumber.setLeftPaddingPoints(05)
            if Utility.trimmingString(cellOTP.txtFld_mobileNumber.text!).count == 0{
                cellOTP.otpStackView.isHidden = true
            }
            cellOTP.btn_CountrySelection.addTarget(self, action: #selector(Click_Country(sender:)), for: UIControl.Event.touchUpInside)
            cellOTP.resendPinButton.addTarget(self, action: #selector(resendPin(sender:)), for: .touchUpInside)
            cellOTP.delegate = self
            return cellOTP
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: login_collectionView.frame.size.width-1, height: login_collectionView.frame.size.height-1)
    }
    
    // MARK:- Forgot password button tap -----
    @objc func callForgotPassword(sender:UIButton)
    {
        self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kForgotPasswordSegue, sender: self)
    }
    
    // MARK:- Eye open close button tap -----
    @objc func eyeOpenClose(sender:UIButton!) {
        let index = IndexPath(item: 0, section: 0)
        let refCell = login_collectionView.cellForItem(at: index as IndexPath) as! LoginCollectionViewCell
        refCell.txtFld_password.isSecureTextEntry = !refCell.txtFld_password.isSecureTextEntry
        if refCell.txtFld_password.isSecureTextEntry {
            refCell.btn_eyeOpenClose.setImage(UIImage(named: "EyeOff"), for: .normal)
        }
        else
        {
            refCell.btn_eyeOpenClose.setImage(UIImage(named: "EyeOn"), for: .normal)
        }
    }
    
    // MARK:- Resend OTP Button Tap-------
    @objc func resendPin(sender:UIButton!){
        let index = IndexPath(item: 1, section: 0)
        let refCell = login_collectionView.cellForItem(at: index as IndexPath) as! SignInOTPCollectionViewCell
        refCell.resendPinButton.isUserInteractionEnabled = false
        if Utility.IsEmtyString(refCell.lbl_dialCode.text!) || Utility.IsEmtyString(refCell.txtFld_mobileNumber.text!){
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterMobileNumberAndCountryCode, Button_Title: Constants.AppAlertAction.kOKButton, self)
            refCell.resendPinButton.isUserInteractionEnabled = true
        }
        else if !Utility.isValidPhoneNumber(testStr: refCell.txtFld_mobileNumber.text!){
            refCell.txtFld_mobileNumber.resignFirstResponder()
            refCell.resendPinButton.isUserInteractionEnabled = true
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidPhoneNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
        else{
            let code = refCell.lbl_dialCode.text!.replacingOccurrences(of: "+", with: "")
            if Reachibility.isConnectedToNetwork(){
                self.btn_SignIn.isUserInteractionEnabled = true
                refCell.resendPinButton.isUserInteractionEnabled = true
                self.verifyPhoneNumber(phone: refCell.txtFld_mobileNumber.text!, countryCode: code)
            }
            else{
                refCell.resendPinButton.isUserInteractionEnabled = true
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
        }
    }
    
    // MARK:- Country Button Tap ----
    @objc func Click_Country(sender:UIButton!) {
        view_popupContainer.isHidden = false
        view_popup.isHidden = false
    }
    
    // MARK:- Check Email Validation -----
    func checkEmail(_ valid: Bool) {
        self.view.endEditing(true)
        if !valid {
//            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidEmailIdAlert, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // MARK:- Check Password Validation ----
    func checkPassword(_ valid: Bool) {
        self.view.endEditing(true)
        if !valid {
//            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterPasswordAlert, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // MARK:- TextField Delegate Methods -----
    @IBAction func textFiledDidChange(_ textFiled : UITextField){
        
        ///replace ("ab") with textfield.text!
        let filteredArr = tableDataCountry.filter({$0[ApiKeyConstants.kDriverName]!.contains("\(textFiled.text ?? "a")")})
        debugPrint(filteredArr)
        //         filteredArr will contain now ["ab","abc"]
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty
        {
            search = String(textField.text?.dropLast() ?? "")
        }
        else
        {
            search = textField.text!+string
        }
        
        debugPrint(search)
        
        let searchPredicate = NSPredicate(format: "SELF.name CONTAINS[c] %@", search)
        let arr = (tableDataCountry as NSArray).filtered(using: searchPredicate)
        
        debugPrint ("array = \(arr)")
        
        if arr.count > 0
        {
            tableSearchDataCountry.removeAll(keepingCapacity: true)
            tableSearchDataCountry = arr as? [[String : String]] ?? []
        }
        else
        {
            tableSearchDataCountry = tableDataCountry
        }
        tableView_Search.reloadData()
        return true
    }
    
    // MARK:- Mobile Validation -----
    func checkMobile(_ valid: Bool) {
        if valid {
            btn_SignIn.isUserInteractionEnabled = true
            btn_SignIn.alpha = 1.0
        }
        else
        {
            btn_SignIn.isUserInteractionEnabled = false
            btn_SignIn.alpha = 0.7
        }
    }
    
    func OTPdone(_ done:Bool){
        if done {
            btn_SignIn.setTitle("Sign In", for: .normal)
            btn_SignIn.isUserInteractionEnabled = true
        }
    }
    
    // MARK:- Validate Phone Number
    func validatePhoneNumberThroughOTP(phoneNumber:String) {
        let index = IndexPath(item: 1, section: 0)
        let refCell = login_collectionView.cellForItem(at: index as IndexPath) as! SignInOTPCollectionViewCell
        if Utility.IsEmtyString(refCell.lbl_dialCode.text!) || Utility.IsEmtyString(phoneNumber){
            refCell.txtFld_mobileNumber.resignFirstResponder()
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterMobileNumberAndCountryCode, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
        else if !Utility.isValidPhoneNumber(testStr: refCell.txtFld_mobileNumber.text!){
            debugPrint("Phone Number :",refCell.txtFld_mobileNumber.text!)
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidPhoneNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
        else{
            let code = refCell.lbl_dialCode.text!.replacingOccurrences(of: "+", with: "")
            if Reachibility.isConnectedToNetwork(){
                self.verifyPhoneNumber(phone: phoneNumber, countryCode: code)
            }
            else{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
        }
        
    }
    
    // MARK:- SignUp Button Tap ----
    @IBAction func Click_signUp(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kSignUpOptionSegue, sender: nil)
    }
    
    @IBAction func Click_outSide(_ sender: Any) {
        view_popup.isHidden = true
        view_popupContainer.isHidden = true
    }
    
    // MARK:- FB SignIn Button Tap -----
    @IBAction func Click_fbSignIn(_ sender: Any) {
        btn_SignIn.isUserInteractionEnabled = false
        btnFacebook.isUserInteractionEnabled = false
        btnGoogle.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Loading...")
        }
        
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logOut()
        fbLoginManager.logIn(permissions: [ApiKeyConstants.kEmail], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    self.btn_SignIn.isUserInteractionEnabled = true
                    self.btnFacebook.isUserInteractionEnabled = true
                    self.btnGoogle.isUserInteractionEnabled = true
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    return
                }
                if(fbloginresult.grantedPermissions.contains(ApiKeyConstants.kEmail))
                {
                    self.getFBUserData()
                }
            }
            else{
                self.btn_SignIn.isUserInteractionEnabled = true
                self.btnFacebook.isUserInteractionEnabled = true
                self.btnGoogle.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK:- Get Facebook User Data -----
    func getFBUserData(){
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    
                    debugPrint(result as Any)
                    let FbData = JSON(result as Any)
                    debugPrint(FbData)
                    let dic_FB = FbData.dictionaryObject
                    let picture_dic:[String:Any] = dic_FB!["picture"] as? [String : Any] ?? [:]
                    let pictureData_dic:[String:Any] = picture_dic["data"] as? [String : Any] ?? [:]
                    let userImageUrl = pictureData_dic["url"] as? String ?? ""
                    debugPrint("User Image URL :- ",userImageUrl as String)
                    let socialID = dic_FB!["id"] as? String ?? ""
                    let userName = dic_FB![ApiKeyConstants.kDriverName] as? String ?? ""
                    let userMail = (dic_FB![ApiKeyConstants.kEmail] as? String ?? "").lowercased()
                    debugPrint("\(socialID)  \(userName) \(userMail)")
                    //                    self.SocialAPi(socialID, userMail, userName, userImageUrl)
                    
                    self.socialLogin(socialID, social_type: "facebook", email: userMail)
                }
            })
        }
    }
    
    // MARK:- Social Login Api Called ----
    func socialLogin(_ social_id:String,social_type:String, email:String) {
        Utility.getCurrentEnvironment()
        DispatchQueue.main.async
            {
                SVProgressHUD.setContainerView(self.login_collectionView)
                SVProgressHUD.show(withStatus: "Signing In...")
        }
        let deviceToken = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDeviceToken)
        let dic_param:[String:String] = [ApiKeyConstants.kEmail:Utility.trimmingString(email.lowercased()),
                                         ApiKeyConstants.kSocialId:social_id,
                                         ApiKeyConstants.kDeviceType : "iOS",
                                         ApiKeyConstants.kOSVersion : Utility.getDeviceOSVersion(),
                                         ApiKeyConstants.kDeviceName : UIDevice.modelName,
                                         ApiKeyConstants.kVendorName : "Apple",
                                         ApiKeyConstants.kSocialType:social_type,
                                         ApiKeyConstants.kAppVersion : Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
                                         ApiKeyConstants.kDeviceToken : deviceToken?[ApiKeyConstants.kUserDefaults.DeviceToken] as? String ?? ""]
        debugPrint(dic_param)
        Utility.removeAppCookie()
        let socialLogin = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kSocialLogin
        APIWrapper.requestPOSTURL(socialLogin, params: dic_param as [String : AnyObject], headers: [:], success: { (JSONResponse) in
            SVProgressHUD.dismiss()
            let JsonValue = JSONResponse
            let dictResponse = JsonValue.dictionaryObject
            
            self.btn_SignIn.isUserInteractionEnabled = true
            self.btnFacebook.isUserInteractionEnabled = true
            self.btnGoogle.isUserInteractionEnabled = true
            
            if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                if (dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1) {
                    self.processLogin(dictResponse: dictResponse!)
                    /*var userDict:[String : Any] = dictResponse![ApiKeyConstants.kResult] as? [String : Any] ?? [:]
                    let email = userDict[ApiKeyConstants.kEmail] as? String ?? ""
                    self.loginIntoFirebase(email: Utility.trimmingString(email.lowercased()), password: ApiKeyConstants.kFireBasePassword, userDetails: dictResponse!)*/
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            }
            else{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
            SVProgressHUD.dismiss()
        })
        { (error) -> Void in

            SVProgressHUD.dismiss()
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
            debugPrint(error)
        }
    }
    
    // MARK:- Verify Phone Number Api Called -----
    func verifyPhoneNumber(phone:String,countryCode:String)  {
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Getting Code...")
        }
        let dictLoginParams:[String:Any] = [ApiKeyConstants.kCountry_code : countryCode,
                                               ApiKeyConstants.kMobile_number : Utility.trimmingString(phone)]

        let verifyPhoneUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kSendOtpForLogin
        Utility.removeAppCookie()
        APIWrapper.requestPOSTURL(verifyPhoneUrl, params: dictLoginParams as [String : AnyObject], headers: [:], success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                if (dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1) {
                    let index = IndexPath(item: 1, section: 0)
                    let refCell = self.login_collectionView.cellForItem(at: index as IndexPath) as! SignInOTPCollectionViewCell
                    refCell.statusLabel.text = Constants.AppAlertMessage.kVerificationCodeText
                    refCell.otpStackView.isHidden = false
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
            debugPrint("Error :",error)
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // MARK:- Verify OTP api Called ----
    func verifyPhoneNumberWithOtp(phone:String,countryCode:String,securityCode:String)  {
        Utility.getCurrentEnvironment()
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Verifying Code...")
        }
        
        let deviceToken = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDeviceToken)
        let dictLoginParams:[String:Any] = [ApiKeyConstants.kCountry_code : countryCode,
                                            ApiKeyConstants.kMobile_number : Utility.trimmingString(phone),
                                            ApiKeyConstants.kSecurityCode : securityCode,
                                            ApiKeyConstants.kDeviceType : "iOS",
                                            ApiKeyConstants.kOSVersion : Utility.getDeviceOSVersion(),
                                            ApiKeyConstants.kDeviceName : UIDevice.modelName,
                                            ApiKeyConstants.kVendorName : "Apple",
                                            ApiKeyConstants.kAppVersion : Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
                                            ApiKeyConstants.kDeviceToken : deviceToken?[ApiKeyConstants.kUserDefaults.DeviceToken] as? String ?? ""]
                                            
        
        let verifyPhoneUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kVerifyOtpForLogin
        Utility.removeAppCookie()
        APIWrapper.requestPOSTURL(verifyPhoneUrl, params: dictLoginParams as [String : AnyObject], headers: [:], success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                if (dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1) {
                    /*var userDict:[String : Any] = dictResponse![ApiKeyConstants.kResult] as? [String : Any] ?? [:]
                    let email = userDict[ApiKeyConstants.kEmail] as? String ?? ""
                    self.loginIntoFirebase(email: Utility.trimmingString(email.lowercased()), password: ApiKeyConstants.kFireBasePassword, userDetails: dictResponse!)*/
                   self.processLogin(dictResponse: dictResponse!)
                }
                else{
                    self.btn_SignIn.setTitle("Send Code", for: .normal)
                    self.btn_SignIn.isUserInteractionEnabled = false
                    self.btn_SignIn.alpha = 0.7
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            }
            else{
                self.btn_SignIn.setTitle("Send Code", for: .normal)
                self.btn_SignIn.isUserInteractionEnabled = false
                self.btn_SignIn.alpha = 0.7
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
        })
        { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            debugPrint("Error :",error)
            self.btn_SignIn.setTitle("Send Code", for: .normal)
            self.btn_SignIn.isUserInteractionEnabled = false
            self.btn_SignIn.alpha = 0.7
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // MARK:- Login with Email & Password ----
    func EmailLoginPassword(_ email:String,_ password:String) {
        Utility.getCurrentEnvironment()
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Loading...")
        }
        let deviceToken = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDeviceToken)
        let dictLoginParams:[String:String] = [ApiKeyConstants.kEmail : Utility.trimmingString(email.lowercased()),
                                            ApiKeyConstants.kPassword : password,
                                            ApiKeyConstants.kDeviceType : "iOS",
                                            ApiKeyConstants.kOSVersion : Utility.getDeviceOSVersion(),
                                            ApiKeyConstants.kDeviceName : UIDevice.modelName,
                                            ApiKeyConstants.kVendorName : "Apple",
                                            ApiKeyConstants.kAppVersion : Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
                                            ApiKeyConstants.kDeviceToken : deviceToken?[ApiKeyConstants.kUserDefaults.DeviceToken] as? String ?? ""];
        
            debugPrint("Login Params :",dictLoginParams)
        
        let loginUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kLoginWithEmail
        Utility.removeAppCookie()
        APIWrapper.requestPOSTURL(loginUrl, params: dictLoginParams as [String : AnyObject], headers: [:], success: { (JSONResponse) in
                let jsonValue = JSONResponse
                let dictResponse = jsonValue.dictionaryObject
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if (dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1) {
                      self.processLogin(dictResponse: dictResponse!)
                      
//                        self.loginIntoFirebase(email: Utility.trimmingString(email.lowercased()), password: ApiKeyConstants.kFireBasePassword, userDetails: dictResponse!)
                        
                    }
                    else{
                        self.btn_SignIn.isUserInteractionEnabled = true
                        self.btnFacebook.isUserInteractionEnabled = true
                        self.btnGoogle.isUserInteractionEnabled = true
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    }
                }
                else{
                    self.btn_SignIn.isUserInteractionEnabled = true
                    self.btnFacebook.isUserInteractionEnabled = true
                    self.btnGoogle.isUserInteractionEnabled = true
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            })
            { (error) -> Void in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                debugPrint("Error :",error)
                self.btn_SignIn.isUserInteractionEnabled = true
                self.btnFacebook.isUserInteractionEnabled = true
                self.btnGoogle.isUserInteractionEnabled = true
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // MARK:- Go to HomeVc -----
    func goToHomeVC() -> Void {
        
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        
        if driverDetailsDict[ApiKeyConstants.kIsApproved] != nil {
            if driverDetailsDict[ApiKeyConstants.kIsApproved] as? Bool == false {
                let storyBoard = UIStoryboard.init(name: "DriverInfo", bundle: Bundle.main)
                let addNewCarVc = storyBoard.instantiateViewController(withIdentifier: "AddNewCarConditionViewController") as! AddNewCarConditionViewController        
                
                self.show(addNewCarVc, sender: self)
                
            } else {
                if self.signInRef != nil{
                    self.signInRef.removeAllObservers()
                }
                let storyBoard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
                let homeVc = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kHomeStoryboardId) as! HomeViewController
                
                self.show(homeVc, sender: self)
            }
        } else {
            let storyBoard = UIStoryboard.init(name: "DriverInfo", bundle: Bundle.main)
            let addNewCarVc = storyBoard.instantiateViewController(withIdentifier: "AddNewCarConditionViewController") as! AddNewCarConditionViewController
            
            self.show(addNewCarVc, sender: self)
            
        }
    }
    
  /*  //    MARK : Login to Firebase ----
    func loginIntoFirebase(email:String, password:String, userDetails:[String:Any]){
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if error == nil {
                debugPrint("User",user as Any)
                self.processLogin(dictResponse: userDetails)
            }
            else{
                if(error?.localizedDescription == Constants.AppAlertMessage.kFirebaseErrorMessage){
                    self.signUpIntoFirebase(email: email, password: password, userDetails: userDetails)
                }
                else{
                    debugPrint("Error",error?.localizedDescription as Any)
                }
            }
        }
    }
    
    //    MARK : Signup to Firebase ----
    func signUpIntoFirebase(email:String, password:String, userDetails:[String:Any]){
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error == nil {
                debugPrint("SignUp To Firebase")
                self.processLogin(dictResponse: userDetails)
            }
            else{
                debugPrint("Error:",error?.localizedDescription as Any)
            }
        }
    }*/
    
    // MARK:- Process Login Method -----
    func processLogin(dictResponse:[String:Any]) {
//        debugPrint("Login Response :",dictResponse)
        
        Utility.removeAppCookie()
        
        var userDict:[String : Any] = dictResponse[ApiKeyConstants.kResult] as? [String : Any] ?? [:]
        userAuthToken = userDict[ApiKeyConstants.kid] as? String ?? ""
        userID = userDict[ApiKeyConstants.kToken] as? String ?? ""
//        let carsArray = userDict["cars"] as! [[String:Any]]
        debugPrint("User Token",userAuthToken)
        userDict = Utility.recursiveNullRemoveFromDictionary(responseDict: userDict)
        
        if self.signInRef == nil{
            signInRef = Database.database().reference()
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var driverName = userDict[ApiKeyConstants.kFirst_Name] as? String ?? ""
        driverName += " "
        driverName += userDict[ApiKeyConstants.kLast_Name] as? String ?? ""
        
        let mobileNumber : String = String(format: "%@%@", userDict[ApiKeyConstants.kCountry_code] as? String ?? "",userDict[ApiKeyConstants.kMobile_number] as? String ?? "")
        debugPrint(mobileNumber)
        
        let driverDetailsDict : [String : Any] = [ApiKeyConstants.kToken : userDict[ApiKeyConstants.kToken] as? String ?? "" ,ApiKeyConstants.kisOnline : userDict[ApiKeyConstants.kStatus] as? Int ?? 0, ApiKeyConstants.kisVacant : 1, ApiKeyConstants.klattitude : appDelegate.lattitude, ApiKeyConstants.klongitude : appDelegate.longitude ,ApiKeyConstants.kNewRequestId : "",ApiKeyConstants.ktimeStamp : Utility.currentTimeInMiliseconds() ,ApiKeyConstants.kTripId : "",ApiKeyConstants.kDriverName : driverName, ApiKeyConstants.kMobile : mobileNumber, ApiKeyConstants.kImage : userDict[ApiKeyConstants.kImage] as? String ?? "", ApiKeyConstants.kStatus : "",ApiKeyConstants.kZoneDescription : "",ApiKeyConstants.kZoneId : "",ApiKeyConstants.kZoneName : "",ApiKeyConstants.kServiceArea : true]
        
//        debugPrint (driverDetailsDict)
        
        self.btn_SignIn.isUserInteractionEnabled = true
        self.signInRef.child(ApiKeyConstants.kFirebaseTableName).child(userAuthToken).observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists(){
                
                var driverDict = snapshot.value as? [String: Any] ?? [:]
            
                driverDict[ApiKeyConstants.kisOnline] = userDict[ApiKeyConstants.kStatus] as? Int ?? 0
                driverDict[ApiKeyConstants.klattitude] = appDelegate.lattitude
                driverDict[ApiKeyConstants.klongitude] = appDelegate.longitude
                driverDict[ApiKeyConstants.ktimeStamp] = Utility.currentTimeInMiliseconds()
                driverDict[ApiKeyConstants.kToken] = userDict[ApiKeyConstants.kToken] as? String ?? ""
                driverDict[ApiKeyConstants.kServiceArea] = true
                self.signInRef.child(ApiKeyConstants.kFirebaseTableName).child(self.userAuthToken).setValue(driverDict)
//                self.goToHomeVC()//(cars: carsArray)
                
                if appDelegate.appDelRef == nil{
                    appDelegate.appDelRef = Database.database().reference()
                }
//               debugPrint("User Auth Token",userAuthToken)
            appDelegate.appDelRef.child(ApiKeyConstants.kFirebaseTableName).child(self.userAuthToken).child(ApiKeyConstants.kToken).observe(.value, with: { (snapshot) in
                
                    if snapshot.exists(){
                        debugPrint("Token:",snapshot.value!)
                        debugPrint("Login Token:",driverDetailsDict[ApiKeyConstants.kToken] as? String ?? "")
                        //appDelegate.appDelRef.removeObserver(withHandle: self.handle)
                        if Utility.isEqualtoString(driverDetailsDict[ApiKeyConstants.kToken] as? String ?? "", snapshot.value as? String ?? ""){
                            
                            Utility.saveToUserDefaultsWithKeyandDictionary(userDict , key: ApiKeyConstants.kUserDefaults.kDriverDetails)
                            let welcomeMessage = userDict[ApiKeyConstants.kMessage] as? String ?? ""
                            Utility.saveStringInUserDefaults(welcomeMessage, key: ApiKeyConstants.kUserDefaults.kWelcomeMessage)
                            let infoMessage = userDict[ApiKeyConstants.kInfoMessage] as? String ?? ""
                            Utility.saveStringInUserDefaults(infoMessage, key: ApiKeyConstants.kUserDefaults.kInfoMessage)
                            Utility.RegisterInIntercom()
                            self.goToHomeVC()
                        }
                        else{
                            //   Single Sign In
                            debugPrint("Token before logout:",snapshot.value!)
                            self.logout(token: snapshot.value as? String ?? "")
                            //                        self.signInRef.child(ApiKeyConstants.kFirebaseTableName).child(userAuthToken).setValue(driverDict)
                        }
                    }
                
                })
            }
            else {
                self.signInRef.child(ApiKeyConstants.kFirebaseTableName).child(self.userAuthToken).setValue(driverDetailsDict)
               
                if appDelegate.appDelRef == nil{
                    appDelegate.appDelRef = Database.database().reference()
                }
            appDelegate.appDelRef.child(ApiKeyConstants.kFirebaseTableName).child(self.userAuthToken).child(ApiKeyConstants.kToken).observe(.value, with: { (snapshot) in
                    if snapshot.exists(){
                        debugPrint("Token:",snapshot.value!)
                        //appDelegate.appDelRef.removeObserver(withHandle: self.handle)
                        if Utility.isEqualtoString(driverDetailsDict[ApiKeyConstants.kToken] as? String ?? "", snapshot.value as? String ?? ""){
                            //piyali
                            Utility.saveToUserDefaultsWithKeyandDictionary(userDict , key: ApiKeyConstants.kUserDefaults.kDriverDetails)
                            let welcomeMessage = userDict[ApiKeyConstants.kMessage] as? String ?? ""
                            Utility.saveStringInUserDefaults(welcomeMessage, key: ApiKeyConstants.kUserDefaults.kWelcomeMessage)
                            let infoMessage = userDict[ApiKeyConstants.kInfoMessage] as? String ?? ""
                            Utility.saveStringInUserDefaults(infoMessage, key: ApiKeyConstants.kUserDefaults.kInfoMessage)
                            Utility.RegisterInIntercom()
                            self.goToHomeVC()
                        }
                        else{
                            //   Single Sign In
                            self.logout(token: driverDetailsDict[ApiKeyConstants.kToken] as? String ?? "")
                        }
                    }
                })
            }
        })
    }
    
    // MARK:- Logout Method -----
    func logout(token:String) {
        debugPrint("Logout Token=",token)
        //     Logout Api call.
        if(Reachibility.isConnectedToNetwork()){
            
            if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
                let driverDetailsDict : [String : Any] = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                let userAuthToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
                if Utility.isEqualtoString(userAuthToken, self.userID){
                    if self.signInRef != nil{
                        signInRef.removeAllObservers()
                    }
                    
                    let storyBoard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
                    let menuVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSideMenuStoryboardId) as! SideMenuViewController
                    debugPrint("Final log Token=",driverDetailsDict[ApiKeyConstants.kToken] as? String ?? "")
                    menuVC.logoutApiCalled(token: driverDetailsDict[ApiKeyConstants.kToken] as? String ?? "",isForceLogout:true)
                }
            }
            else{
//                goToHomeVC()
            }
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
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

