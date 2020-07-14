
import UIKit
import SVProgressHUD
import Kingfisher
import SwiftyJSON
import Firebase
import FirebaseDatabase
import SafariServices
import AVFoundation
import Reachability
import ActionKit

class SignUpViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SFSafariViewControllerDelegate,UITextViewDelegate {
    
    class SignUpData : Codable {
        let cellType : String!
        var text : String!
        var placeholder : String!
        var id : String!
        var selectedid : String!
        let tag : Int!
    }
    
    let appdelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    fileprivate var signUpRef: DatabaseReference!
    fileprivate var search : String = ""
    fileprivate var isSocial = false
    fileprivate var isResendOTP : Bool = false
    fileprivate var user_image : UIImage? = nil
    fileprivate var localDialCode = ""
    fileprivate var localCountryCode = ""
    fileprivate var count = 0
    fileprivate var userData : [String:String] = [String:String]()
    fileprivate var imagePicker = UIImagePickerController()
    fileprivate var countryDetails = [String : Any]()
    fileprivate var signUpTableData = [SignUpData]()
    fileprivate var globalTextField = UITextField()
    var socialData = [String:Any]()
    
    @IBOutlet var btn_next: UIButton!
    @IBOutlet var collectionView_signUp: UICollectionView!
    @IBOutlet var lbl_stepNumber: UILabel!
    @IBOutlet weak var termsAndConditionsBtn: UIButton!
    @IBOutlet weak var viewTermsAndConditions: UIView!
    
    func checkEmail(_ strted: Bool) {
        // NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        termsAndConditionsBtn.isSelected = false
        isSocial = socialData.keys.count != 0 ? true : false
        
        if(isSocial) {
            self.viewTermsAndConditions.isHidden = false
            btn_next.setTitle("Next", for: .normal)
            
        } else {
            self.viewTermsAndConditions.isHidden = true
            btn_next.setTitle("Send Code", for: .normal)
        }
        
        localDialCode       = appdelegate.dialCode
        localCountryCode    = appdelegate.countryCode
        
        lbl_stepNumber.text = "1"
        
        userData = ["first_name":"","last_name":"",ApiKeyConstants.kDriverName:"","email":"","selectedCountryId":"","selectedStateId":"","city":"","social_id":"","image_url":"","password":"","mobile_number":"","country_code":""]
        
//        configureDatabase()
        
        do {
            let assetData = try Data(contentsOf: Bundle.main.url(forResource: "SignUp", withExtension: ".json")!)
            signUpTableData = try JSONDecoder().decode([SignUpData].self, from: (assetData))
            
            if(isSocial) {
                self.setSocialSignUpDetails()
            }
            self.collectionView_signUp.reloadData()
            
        } catch {
            print(error)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        if self.signUpRef != nil{
            self.signUpRef.removeAllObservers()
        }
    }
    
    deinit {
        if self.signUpRef != nil{
            self.signUpRef.removeAllObservers()
        }
    }
    
//    private func configureDatabase()  {
//        signUpRef = Database.database().reference()
//    }
    
    // MARK:- Textview Delegate
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        openWebPageWithUrl(_url: Constants.legalURL.kPrivacyUrl)
        
        return false
    }
    
    // MARK:- Setup SignUp Data
    func setSocialSignUpDetails() {
        
        _ = signUpTableData.map({
            switch $0.id {
            case "firstname" :
                
                if ($0.text.isNullString()){
                    $0.text = self.socialData[ApiKeyConstants.kFirstName] as? String
                    userData["first_name"] = $0.text
                    break
                }
                
                break;
            case "lastname":
                
                if ($0.text.isNullString()){
                    $0.text = self.socialData[ApiKeyConstants.kLastName] as? String
                    userData["last_name"] = $0.text
                }
                
                break;
            case "email" :
                
                if ($0.text.isNullString()){
                    $0.text = self.socialData[ApiKeyConstants.kEmail] as? String
                    userData["email"] = $0.text
                }
                
                break;
            default:
                break
            }
        })
    }
    
    
    // MARK:- Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            //            Print("Error: \(info)")
            print("Error")
            return
        }
        
        user_image = selectedImage.fixOrientation()
        
        if isSocial
        {
            let index = IndexPath(item: 0, section: 0)
            let refCell = collectionView_signUp.cellForItem(at: index as IndexPath) as! SignUpFormCollectionViewCell
            refCell.img_profilePic.image = user_image
            refCell.img_profilePic.layer.cornerRadius = refCell.img_profilePic.frame.height / 2
            refCell.img_profilePic.clipsToBounds = true
        }
        else
        {
            let index = IndexPath(item: 2, section: 0)
            let refCell = collectionView_signUp.cellForItem(at: index as IndexPath) as! SignUpFormCollectionViewCell
            refCell.img_profilePic.image = user_image
            refCell.img_profilePic.layer.cornerRadius = refCell.img_profilePic.frame.height / 2
            refCell.img_profilePic.clipsToBounds = true
        }
        
        //        pickedImageProduct = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    //    MARK:- Safari Services Delegate ----
    func openWebPageWithUrl(_url : String) {
        let safariVC = SFSafariViewController(url: NSURL(string: _url)! as URL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK:- Privacy Policy Button Tap -----
    @IBAction func privacyPolicyButtonTap(_ sender: Any) {
        openWebPageWithUrl(_url: Constants.legalURL.kPrivacyUrl)
    }
    
    // MARK:- Terms & Conditions Button Tap -----
    @IBAction func termsConditionsButtonTap(_ sender: Any) {
        termsAndConditionsBtn.isSelected = !termsAndConditionsBtn.isSelected
        if termsAndConditionsBtn.isSelected {
            termsAndConditionsBtn.setImage(UIImage(named: "checkBoxSelect"), for: .normal)
        }
        else{
            termsAndConditionsBtn.setImage(UIImage(named: "checkBoxDeselect"), for: .normal)
        }
    }
    
    // MARK:- Camera Click Button Tap ------
    @objc func Click_camra(sender:UIButton!)
    {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        let actionSheetController: UIAlertController = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertAction.kChooseProfilePicture, preferredStyle: .actionSheet)
        actionSheetController.view.tintColor = Constants.AppColour.kAppGreenColor
        
        
        let ChooseLibrary: UIAlertAction = UIAlertAction(title: Constants.AppAlertAction.kPickFromCamera, style: .default) { action -> Void in
            //Just dismiss the action sheet
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if status == .restricted || status == .denied {
                Utility.showAlertForPermissionDenied(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kAllowCameraAccess, self)
            }else{
                //            Open Camera function
                if UIImagePickerController.isSourceTypeAvailable(.camera){
                    print("Button capture")
                    self.imagePicker.sourceType = .camera;
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            }
        }
        
        actionSheetController.addAction(ChooseLibrary)
        let ChoosePhoto: UIAlertAction = UIAlertAction(title: Constants.AppAlertAction.kChooseFromGallery, style: .default) { action -> Void in
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if status == .restricted || status == .denied {
                Utility.showAlertForPermissionDenied(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kAllowGalleryAccess, self)
            }else{
                if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                    print("Button capture")
                    self.imagePicker.sourceType = .savedPhotosAlbum;
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            }
        }
        actionSheetController.addAction(ChoosePhoto)
        let cancelAction: UIAlertAction = UIAlertAction(title: Constants.AppAlertAction.kCancel, style: .default) { action -> Void in
            //Just dismiss the action sheet
            self.dismiss(animated: true)
        }
        actionSheetController.addAction(cancelAction)
        
        self.present(actionSheetController, animated: true, completion: nil)
        
        
    }
    
    // MARK:- Resend Code Button Tap----
    @objc func Click_ResendCode(sender:UIButton!) {
        
        isResendOTP = true
        RequestOTP(userData["mobile_number"] ?? "",
                   userData["country_code"] ?? "1")
    }
    
    // MARK:-Edit Number Button Tap ----
    @objc func Click_EditNumber(sender:UIButton!) {
        
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.collectionView_signUp)
        let indexPath = self.collectionView_signUp.indexPathForItem(at: buttonPosition)
        let cell = self.collectionView_signUp.cellForItem(at: indexPath!) as? OTPsignUpFormCollectionViewCell
        
        cell?.clearTextFields()
        
        self.count = (count == 0) ? 0 : (self.count - 1)
                
        if !isSocial {
            let indexPath = NSIndexPath(row: 0, section: 0)
            collectionView_signUp.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
            btn_next.setTitle("Send Code", for: .normal)
            lbl_stepNumber.text = "1"
        } else {
            btn_next.setTitle("Send Code", for: .normal)
            let indexPath = NSIndexPath(row: 1, section: 0)
            collectionView_signUp.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
            lbl_stepNumber.text = "2"
        }
    }
    
    // MARK:- Next Button Tap----
    @IBAction func Click_Next(_ sender: UIButton) {
        self.view.endEditing(true)
        if count == 0 {
            
            if !isSocial
            {
                self.viewTermsAndConditions.isHidden = true
//                NotificationCenter.default.removeObserver(self)
                let index = IndexPath(item: 0, section: 0)
                let refCell = collectionView_signUp.cellForItem(at: index as IndexPath) as! MobileNumberSignUpCollectionViewCell
                if Utility.IsEmtyString(refCell.txtFld_mobileNumber.text!.removingWhitespaces()) || !Utility.isValidPhoneNumber(testStr: refCell.txtFld_mobileNumber.text!.removingWhitespaces())
                {
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidPhoneNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
                else {
                    
                    userData["mobile_number"] = refCell.txtFld_mobileNumber.text?.removingWhitespaces()
                    
                    if Utility.IsEmtyString(localDialCode)
                    {
                        userData["country_code"] = appdelegate.dialCode
                        RequestOTP(refCell.txtFld_mobileNumber.text?.removingWhitespaces() ?? "",appdelegate.dialCode)
                    }
                    else
                    {
                        userData["country_code"] = localDialCode
                        RequestOTP(refCell.txtFld_mobileNumber.text?.removingWhitespaces() ?? "",localDialCode)
                    }
                }
            }
            else
            {
                if(self.validateAllFieldsForCarDetails()) {
                    
                    btn_next.setTitle("Send Code", for: .normal)
                    lbl_stepNumber.text = "2"
                    let indexPath = NSIndexPath(row: 1, section: 0)
                    collectionView_signUp.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
                    count += 1
                    self.viewTermsAndConditions.isHidden = true
                    
                }
            }
            
        }
        else if count == 1
        {
            
            if !isSocial
            {
//                NotificationCenter.default.removeObserver(self)
                let index = IndexPath(item: 1, section: 0)
                let refCell = collectionView_signUp.cellForItem(at: index as IndexPath) as! OTPsignUpFormCollectionViewCell
                refCell.lbl_mobileNumber.text = "+\(userData["country_code"] ?? "")-\(userData["mobile_number"] ?? "")"
                if Utility.IsEmtyString(refCell.txtFld_OTP_one.text) || Utility.IsEmtyString(refCell.txtFld_OTP_two.text) || Utility.IsEmtyString(refCell.txtFld_OTP_Three.text) || Utility.IsEmtyString(refCell.txtFld_OTP_four.text) || Utility.IsEmtyString(refCell.txtFld_OTP_fifth.text) ||
                    Utility.IsEmtyString(refCell.txtFld_OTP_sixth.text)
                {
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidOTP, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
                else
                {
                    //change
                    verifyingPhoneNumber(userData["mobile_number"] ?? "", "\(refCell.txtFld_OTP_one.text ?? "")\(refCell.txtFld_OTP_two.text ?? "")\(refCell.txtFld_OTP_Three.text ?? "")\(refCell.txtFld_OTP_four.text ?? "")\(refCell.txtFld_OTP_fifth.text ?? "")\(refCell.txtFld_OTP_sixth.text ?? "")", userData["country_code"]!)
                }
            }
            else
            {
                self.viewTermsAndConditions.isHidden = true
//                NotificationCenter.default.removeObserver(self)
                let index = IndexPath(item: 1, section: 0)
                let refCell = collectionView_signUp.cellForItem(at: index as IndexPath) as! MobileNumberSignUpCollectionViewCell
                if Utility.IsEmtyString(refCell.txtFld_mobileNumber.text?.removingWhitespaces()) || !Utility.isValidPhoneNumber(testStr: refCell.txtFld_mobileNumber.text!.removingWhitespaces())
                {
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidPhoneNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
                else{
                    
                    userData["mobile_number"] = refCell.txtFld_mobileNumber.text?.removingWhitespaces()
                    
                    if Utility.IsEmtyString(localDialCode)
                    {
                        //change
                        userData["country_code"] = appdelegate.dialCode
                        RequestOTP(refCell.txtFld_mobileNumber.text?.removingWhitespaces() ?? "",appdelegate.dialCode)
                        
                    }
                    else
                    {
                        //change
                        userData["country_code"] = localDialCode
                        RequestOTP(refCell.txtFld_mobileNumber.text?.removingWhitespaces() ?? "",localDialCode)
                        
                    }
                }
            }
            
        }
        else if count == 2
        {
            if !isSocial
            {
                self.viewTermsAndConditions.isHidden = false
                if(self.validateAllFieldsForCarDetails()) {
                    
                    userRegistration(self.userData["first_name"] ?? "", self.userData["last_name"] ?? "", self.userData["email"] ?? "", self.userData["password"] ?? "", userData["country_code"] ?? "", userData["mobile_number"] ?? "", selectedCountryId: userData["selectedCountryId"] ?? "", selectedStateId: userData["selectedStateId"] ?? "", city: userData["city"] ?? "")
                    
                }
            }
            else
            {
                self.viewTermsAndConditions.isHidden = true
//                NotificationCenter.default.removeObserver(self)
                let index = IndexPath(item: 2, section: 0)
                let refCell = collectionView_signUp.cellForItem(at: index as IndexPath) as! OTPsignUpFormCollectionViewCell
                
                refCell.lbl_mobileNumber.text = "+\(userData["country_code"] ?? "")-\(userData["mobile_number"] ?? "")"
                if Utility.IsEmtyString(refCell.txtFld_OTP_one.text) || Utility.IsEmtyString(refCell.txtFld_OTP_two.text) || Utility.IsEmtyString(refCell.txtFld_OTP_Three.text) || Utility.IsEmtyString(refCell.txtFld_OTP_four.text) || Utility.IsEmtyString(refCell.txtFld_OTP_fifth.text) ||
                    Utility.IsEmtyString(refCell.txtFld_OTP_sixth.text)
                {
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidOTP, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
                else
                {
                    //change
                    verifyingPhoneNumber(userData["mobile_number"] ?? "", "\(refCell.txtFld_OTP_one.text ?? "")\(refCell.txtFld_OTP_two.text ?? "")\(refCell.txtFld_OTP_Three.text ?? "")\(refCell.txtFld_OTP_four.text ?? "")\(refCell.txtFld_OTP_fifth.text ?? "")\(refCell.txtFld_OTP_sixth.text ?? "")", userData["country_code"]!)
                }
                
                let indexPath = NSIndexPath(row: 2, section: 0)
                collectionView_signUp.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
                sender.setTitle("Sign Up", for: .normal)
//                self.viewTermsAndConditions.isHidden = false
                
                
            }
        }
        
        
    }
    
    // MARK:- Field Validation -----
    func validateAllFieldsForCarDetails() -> Bool {
        var isValid:Bool = true
        
        for item in signUpTableData {
            let data: SignUpData = item
            switch data.id {
            case "firstname":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterFirstName, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                }
                /*else if (Utility.isValidCharacterSet(str: data.text)){
                    let firstNameMessage = Constants.AppAlertMessage.kSpecialCharacter + " " + "In First Name."
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: firstNameMessage, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                }*/
                else {
                    self.userData["first_name"] = data.text
                }
                
            case "lastname":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterLastName, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                }
                /*else if (Utility.isValidCharacterSet(str: data.text)){
                    let lastNameMessage = Constants.AppAlertMessage.kSpecialCharacter + " " + "In Last Name."
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message:lastNameMessage, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                }*/
                else {
                    self.userData["last_name"] = data.text
                }
                
            case "email":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterEmailIdAlert, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    if Utility.isValidEmail(testStr: Utility.trimmingString(data.text)){
                        self.userData["email"] = data.text
                        //isValid = true
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidEmailIdAlert, Button_Title: Constants.AppAlertAction.kOKButton, self)
                        isValid = false
                        break
                    }
                    
                    
                }
            case "password":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterPasswordAlert, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    if (data.text.count > 5 ){
                        self.userData["password"] = data.text
                        //isValid = true
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidPasswordAlert, Button_Title: Constants.AppAlertAction.kOKButton, self)
                        isValid = false
                        break
                    }
                }
            case "country":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterCountry, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    self.userData["selectedCountryId"] = data.selectedid
                }
            case "state":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterStateOrProvince, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    self.userData["selectedStateId"] = data.selectedid
                }
            case "city":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterCity, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    self.userData["city"] = data.text
                }
            default:
                break
            }
        }
        
        if(isValid) {
            
            if user_image == UIImage(named: "profileImagePlaceholder") || user_image == nil{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kDriverProfileImage, Button_Title: Constants.AppAlertAction.kOKButton, self)
                isValid = false
            }
            else{
                if termsAndConditionsBtn.isSelected {
                    isValid = true
                } else {
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kDriverRegistrationTermsAndConditions, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                }
            }
        } else {
            isValid = false
        }
        
        return isValid
    }
    
    // MARK:- Handle UI AFter Registration-----
    func processLogin(dictResponse:[String:Any]) {
        debugPrint("Login Response :",dictResponse)
        var userDict:[String : Any] = dictResponse
        let userAuthToken = userDict[ApiKeyConstants.kid] as? String ?? ""
        
        debugPrint("User Details",userDict)
        userDict = Utility.recursiveNullRemoveFromDictionary(responseDict: userDict)
        Utility.saveToUserDefaultsWithKeyandDictionary(userDict , key: ApiKeyConstants.kUserDefaults.kDriverDetails)
        let welcomeMessage = userDict[ApiKeyConstants.kMessage] as? String ?? ""
        Utility.saveStringInUserDefaults(welcomeMessage, key: ApiKeyConstants.kUserDefaults.kWelcomeMessage)
        let infoMessage = userDict[ApiKeyConstants.kInfoMessage] as? String ?? ""
        Utility.saveStringInUserDefaults(infoMessage, key: ApiKeyConstants.kUserDefaults.kInfoMessage)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.createLocalNotifications(title: Constants.NotificationConstant.kNotificationTitle, subTitle: Constants.NotificationConstant.kSignUpSubTitle, message: Constants.NotificationConstant.kSignUpBody, notificationIdentifier: Constants.NotificationConstant.kSignUpNotificationID)
        var driverName = userDict[ApiKeyConstants.kFirst_Name] as? String ?? ""
        driverName += " "
        driverName += userDict[ApiKeyConstants.kLast_Name] as? String ?? ""
        
        let mobileNumber : String = String(format: "%@%@", userDict[ApiKeyConstants.kCountry_code] as? String ?? "",userDict[ApiKeyConstants.kMobile_number] as? String ?? "")
        debugPrint(mobileNumber)
        
        let driverDetailsDict : [String : Any] = [ApiKeyConstants.kToken : userDict[ApiKeyConstants.kToken] as? String ?? "" ,ApiKeyConstants.kisOnline : userDict[ApiKeyConstants.kStatus] as? Int ?? 0, ApiKeyConstants.kisVacant : 1, ApiKeyConstants.klattitude : appDelegate.lattitude, ApiKeyConstants.klongitude : appDelegate.longitude ,ApiKeyConstants.kNewRequestId : "",ApiKeyConstants.ktimeStamp : Utility.currentTimeInMiliseconds() ,ApiKeyConstants.kTripId : "",ApiKeyConstants.kDriverName : driverName, ApiKeyConstants.kMobile : mobileNumber, ApiKeyConstants.kImage : userDict[ApiKeyConstants.kImage] as? String ?? "", ApiKeyConstants.kStatus : "",ApiKeyConstants.kZoneDescription : "",ApiKeyConstants.kZoneId : "",ApiKeyConstants.kZoneName : "",ApiKeyConstants.kServiceArea : true]
        debugPrint (driverDetailsDict)
        
        if self.signUpRef == nil{
            signUpRef = Database.database().reference()
        }
        
        self.signUpRef.child(ApiKeyConstants.kFirebaseTableName).child(userAuthToken).observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists(){
                
                var driverDict = snapshot.value as? [String: Any] ?? [:]
//                var earlierDict = driverDict
                debugPrint("User:",driverDict)
            
                driverDict[ApiKeyConstants.kisOnline] = userDict[ApiKeyConstants.kStatus] as? Int ?? 0
                driverDict[ApiKeyConstants.klattitude] = appDelegate.lattitude
                driverDict[ApiKeyConstants.klongitude] = appDelegate.longitude
                driverDict[ApiKeyConstants.ktimeStamp] = Utility.currentTimeInMiliseconds()
                driverDict[ApiKeyConstants.kToken] = userDict[ApiKeyConstants.kToken] as? String ?? ""
                driverDict[ApiKeyConstants.kServiceArea] = true
                self.signUpRef.child(ApiKeyConstants.kFirebaseTableName).child(userAuthToken).setValue(driverDict)
               
                if appDelegate.appDelRef == nil{
                    appDelegate.appDelRef = Database.database().reference()
                }
            appDelegate.appDelRef.child(ApiKeyConstants.kFirebaseTableName).child(userAuthToken).child(ApiKeyConstants.kToken).observe(.value, with: { (snapshot) in
                    if snapshot.exists(){
                        debugPrint("Token:",snapshot.value as? String ?? "")
                        if Utility.isEqualtoString(driverDetailsDict[ApiKeyConstants.kToken] as? String ?? "", snapshot.value as? String ?? ""){
                            Utility.RegisterInIntercom()
                            self.goToHomeVC()
                        }
                        else{
                            //   Single Sign In
                            self.logout()
                        }
                    }
                
                })
            }
            else{
                self.signUpRef.child(ApiKeyConstants.kFirebaseTableName).child(userAuthToken).setValue(driverDetailsDict)
                //                self.goToHomeVC()
                if appDelegate.appDelRef == nil{
                    appDelegate.appDelRef = Database.database().reference()
                }
            appDelegate.appDelRef.child(ApiKeyConstants.kFirebaseTableName).child(userAuthToken).child(ApiKeyConstants.kToken).observe(.value, with: { (snapshot) in
                    if snapshot.exists(){
                        debugPrint("Token:",snapshot.value as? String ?? "")
                        if Utility.isEqualtoString(driverDetailsDict[ApiKeyConstants.kToken] as? String ?? "", snapshot.value as? String ?? ""){
                            Utility.RegisterInIntercom()
                            self.goToHomeVC()
                        }
                        else{
                            //   Single Sign In
                            self.logout()
                        }
                    }
                })
            }
        })
    }
    
    // MARK:- Go To HomeVC ------
    func goToHomeVC() -> Void {
        
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        if driverDetailsDict[ApiKeyConstants.kIsApproved] != nil {
            if driverDetailsDict[ApiKeyConstants.kIsApproved] as? Bool == false {
                let storyBoard = UIStoryboard.init(name: "DriverInfo", bundle: Bundle.main)
                let addNewCarVc = storyBoard.instantiateViewController(withIdentifier: "AddNewCarConditionViewController") as! AddNewCarConditionViewController
                
                self.show(addNewCarVc, sender: self)
                
            } else {
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
    
    
    //MARK:- Service Call ------
    func userRegistration(_ first_name : String, _ last_name : String, _ email : String , _ password : String, _ country_code : String, _ mobile_number : String , selectedCountryId : String, selectedStateId : String, city : String) {
        
        Utility.getCurrentEnvironment()
        
        let deviceToken = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDeviceToken)
        
        let CheckedMobileNumber = Utility.trimmingString(mobile_number)
        let dic_regParam:[String:String] = [ApiKeyConstants.kFirst_Name: first_name,
                                               ApiKeyConstants.kLast_Name:last_name,
                                               ApiKeyConstants.kEmail :email,
                                               ApiKeyConstants.kPassword:password,
                                               ApiKeyConstants.kCountry_code:country_code,
                                               ApiKeyConstants.kMobile_number:CheckedMobileNumber,
                                               ApiKeyConstants.kCity:city,
                                               ApiKeyConstants.kCountry:selectedCountryId,
                                               ApiKeyConstants.kState:selectedStateId,
                                               ApiKeyConstants.kDeviceType : "iOS",
                                               ApiKeyConstants.kOSVersion : Utility.getDeviceOSVersion(),
                                               ApiKeyConstants.kDeviceName : UIDevice.modelName,
                                               ApiKeyConstants.kVendorName : "Apple",
                                               "flag_code" : self.appdelegate.countryCode,
                                               ApiKeyConstants.kAppVersion : Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
                                               ApiKeyConstants.kDeviceToken : deviceToken?[ApiKeyConstants.kUserDefaults.DeviceToken] as? String ?? ""]
        
        //let imageData = user_image?.jpegData(compressionQuality: 0.75)
        let imageData = Utility.resizeImage(image: user_image ?? UIImage(), width: 500)
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Registering...")
        }
        
        let url:String = String(format:"%@%@",ApiConstants.kBaseUrl.baseUrl,ApiConstants.kApisEndPoint.kDriverSignUp)
        
        Utility.removeAppCookie()
        
        APIWrapper.requestMultipartWith(url, imageData: imageData, parameters: dic_regParam as [String:AnyObject], headers: [:], success: { (JSONResponse) in
            let JsonValue = JSONResponse
            let dicValue = JsonValue.dictionaryObject
            print(dicValue!)
            
            SVProgressHUD.dismiss()
            
            if(dicValue![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                if(dicValue![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                    
                    let dicResult:[String:Any] = dicValue?["result"] as? [String : Any] ?? [:]
                    self.processLogin(dictResponse: dicResult)
//                    self.signUpIntoFirebase(email: dicResult[ApiKeyConstants.kEmail] as? String ?? "", password: ApiKeyConstants.kFireBasePassword, userDetails: dicResult)
                    
                } else {
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dicValue![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            } else{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
            
        }) { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // MARK:- Social SignUp Methods----
    func socialSignUpApiLogin(_ first_name:String,_ last_name : String, user_email : String, user_password : String, country_code : String, mobile_number : String, profile_image_url : String, social_type : String, social_id : String , selectedCountryId : String, selectedStateId : String, city : String) {
        Utility.getCurrentEnvironment()
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Registering...")
        }
        let CheckedMobileNumber = Utility.trimmingString(mobile_number)
        let deviceToken = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDeviceToken)
        let dic_param:[String:String] = [ApiKeyConstants.kFirst_Name : first_name,
                                         ApiKeyConstants.kLast_Name : last_name,
                                         ApiKeyConstants.kEmail : Utility.trimmingString(user_email.lowercased()),
                                         ApiKeyConstants.kCountry_code : country_code,
                                         ApiKeyConstants.kMobile_number : CheckedMobileNumber ,
                                         ApiKeyConstants.kCity : city,
                                         ApiKeyConstants.kPassword : user_password,
                                         ApiKeyConstants.kCountry:selectedCountryId,
                                         ApiKeyConstants.kState:selectedStateId,
                                         ApiKeyConstants.kSocialType : social_type,
                                         ApiKeyConstants.kSocialId : social_id,
                                         ApiKeyConstants.kDeviceType : "iOS",
                                         ApiKeyConstants.kOSVersion : Utility.getDeviceOSVersion(),
                                         ApiKeyConstants.kDeviceName : UIDevice.modelName,
                                         ApiKeyConstants.kVendorName : "Apple",
                                         "flag_code" : appdelegate.countryCode,
                                         ApiKeyConstants.kAppVersion : Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
                                         ApiKeyConstants.kDeviceToken : deviceToken?[ApiKeyConstants.kUserDefaults.DeviceToken] as? String ?? ""]
        print(dic_param)
        
        let url:String = String(format:"%@%@",ApiConstants.kBaseUrl.baseUrl,ApiConstants.kApisEndPoint.kSocialRegistration)
        let jpegdata = Utility.resizeImage(image: user_image ?? UIImage(), width: 500)
        Utility.removeAppCookie()
        APIWrapper.requestMultipartWith(url, imageData: jpegdata, parameters: dic_param as [String:AnyObject], headers: nil, success: { (JSONResponse) in
            SVProgressHUD.dismiss()
            let JsonValue = JSONResponse
            let dicValue = JsonValue.dictionaryObject
            //            print(dicValue!["status"] as Any)
            let status_value:Int = dicValue!["status"] as? Int ?? 0
            if Bool(truncating: status_value as NSNumber)
            {
                let dicResult:[String:Any] = dicValue?["result"] as? [String : Any] ?? [:]
                self.processLogin(dictResponse: dicResult)
//                self.signUpIntoFirebase(email: dicResult[ApiKeyConstants.kEmail] as? String ?? "", password: ApiKeyConstants.kFireBasePassword, userDetails: dicResult)
            }
            else
            {
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dicValue![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
            
            SVProgressHUD.dismiss()
        }) { (error) -> Void in
            
            SVProgressHUD.dismiss()
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
            print(error)
        }
    }
    
    // MARK:- Verify Phone NUmber Method-----
    func verifyingPhoneNumber(_ mobileNumber:String,_ securityCode:String,_ countryCode:String) {
        
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Verifying...")
        }
        
        let CheckedMobileNumber = Utility.trimmingString(mobileNumber)
        let dic_param:[String:String] = [ApiKeyConstants.kCountry_code:countryCode,
                                         ApiKeyConstants.kMobile_number:CheckedMobileNumber,
                                         ApiKeyConstants.kSecurityCode:securityCode
        ]
        print(dic_param)
        let url:String = String(format:"%@%@",ApiConstants.kBaseUrl.baseUrl,ApiConstants.kApisEndPoint.kVerifyOtpForSignUp)
        
        APIWrapper.requestPOSTURL(url, params: dic_param as [String : AnyObject] , headers: [:], success: { (JSONResponse) in
            
            SVProgressHUD.dismiss()
            let JsonValue = JSONResponse
            let dicValue = JsonValue.dictionaryObject
            //            print(dicValue!["status"] as Any)
            let status_value:Int = dicValue!["status"] as? Int ?? 0
            if Bool(truncating: status_value as NSNumber)
            {
                if !self.isSocial
                {
                    self.lbl_stepNumber.text = "3"
                    let indexPath = NSIndexPath(row: 2, section: 0)
                    self.collectionView_signUp.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
                    self.btn_next.setTitle("Sign Up", for: .normal)
                    
                    self.count += 1
                    self.viewTermsAndConditions.isHidden = false
                }
                else
                {
                    self.lbl_stepNumber.text = "3"
                    self.count += 1
                    self.socialSignUpApiLogin(self.userData["first_name"] ?? "" , self.userData["last_name"] ?? "", user_email: self.userData["email"] ?? "" , user_password: self.userData["password"] ?? "", country_code:self.userData["country_code"] ?? "" , mobile_number: self.userData["mobile_number"] ?? "", profile_image_url: self.socialData[ApiKeyConstants.kImage] as? String ?? "", social_type: self.socialData[ApiKeyConstants.kSocialLoginType] as? String ?? "", social_id: self.socialData[ApiKeyConstants.kSocialId] as? String ?? "", selectedCountryId : self.userData["selectedCountryId"] ?? "", selectedStateId : self.userData["selectedStateId"] ?? "", city : self.userData["city"] ?? "")
                }
                
            }
            else
            {
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dicValue?["message"] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton,self)
            }
            SVProgressHUD.dismiss()
        }) { (error) -> Void in
            
            SVProgressHUD.dismiss()
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton,self)
            print(error)
        }
    }
    
    // MARK:- Requesting OTP ----
    func RequestOTP(_ mobileNUmber:String,_ countryCode:String) {
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Sending Code...")
        }
        let CheckedMobileNumber = Utility.trimmingString(mobileNUmber)
        let dic_param:[String:String] = [ApiKeyConstants.kCountry_code:countryCode,
                                         ApiKeyConstants.kMobile_number:CheckedMobileNumber
        ]
        print(dic_param)
        let url:String = String(format:"%@%@",ApiConstants.kBaseUrl.baseUrl,ApiConstants.kApisEndPoint.kGetOtpForMobileVerificationSignUp)
        APIWrapper.requestPOSTURL(url, params: dic_param as [String : AnyObject] , headers: [:], success: { (JSONResponse) in
            SVProgressHUD.dismiss()
            let JsonValue = JSONResponse
            let dicValue = JsonValue.dictionaryObject
            //            print(dicValue!["status"] as Any)
            let status_value:Int = dicValue!["status"] as? Int ?? 0
            if Bool(truncating: status_value as NSNumber)
            {
                SVProgressHUD.dismiss()
                print(dicValue ?? "")
                
                if !(self.isResendOTP) {
                    if self.isSocial
                    {
                        self.lbl_stepNumber.text = "3"
                        let indexPath = NSIndexPath(row: 2, section: 0)
                        
                        self.collectionView_signUp.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
                        self.btn_next.setTitle("Sign Up", for: .normal)
                        self.count += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: {
                            let refCell = self.collectionView_signUp.cellForItem(at: indexPath as IndexPath) as! OTPsignUpFormCollectionViewCell
                            refCell.lbl_mobileNumber.text = "+\(self.userData["country_code"] ?? "")-\(self.userData["mobile_number"] ?? "")"
                        })
                    }
                    else
                    {
                        let indexPath = NSIndexPath(row: 1, section: 0)
                        
                        self.btn_next.setTitle("Next", for: .normal)
                        self.collectionView_signUp.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
                        self.count += 1
                        self.lbl_stepNumber.text = "2"
                        //change
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: {
                         let refCell = self.collectionView_signUp.cellForItem(at: indexPath as IndexPath) as! OTPsignUpFormCollectionViewCell
                         refCell.lbl_mobileNumber.text = "+\(self.userData["country_code"] ?? "")-\(self.userData["mobile_number"] ?? "")"
                         })
                    }
                } else {
                    self.isResendOTP = false
                }
            }
            else
            {
                if dicValue?["message"] != nil
                {
                    
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dicValue?["message"] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton,self)
                }
                
            }
            
        }) { (error) -> Void in
            
            SVProgressHUD.dismiss()
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton,self)
            print(error)
        }
    }
    
    // MARK:- Logout Api ----
    func logout() {
        //     Logout Api call.
        if(Reachibility.isConnectedToNetwork()){
            if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
                let driverDetailsDict : [String : Any] = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                if self.signUpRef != nil{
                    signUpRef.removeAllObservers()
                }
//                let userAuthToken = driverDetailsDict[ApiKeyConstants.kid] as? String ?? ""
                //let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let storyBoard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
                let menuVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSideMenuStoryboardId) as! SideMenuViewController
                menuVC.logoutApiCalled(token: driverDetailsDict[ApiKeyConstants.kToken] as? String ?? "",isForceLogout:true)
            }
            else{
                //                goToHomeVC()
            }
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // MARK:- Click SignIn Button Tap -----
      @IBAction func Click_SignIn(_ sender: Any) {
        Utility.goBackToSignInVC(self)
     }
     
     
   /* //    MARK : Signup to Firebase ----
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
   /*  func socialAPIcall(_ first_name:String,_ last_name:String,_ email:String,_ password:String,_ country_code:String,_ mobile_number:String,profile_image_url:String) {
     
     }*/
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
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

// MARK:- Tableview Delegate And Datasource

extension SignUpViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = signUpTableData[indexPath.row]
        
        if(data.cellType == "2") {
            
            let cell: CarDetailsPopupCell  = tableView.cellForRow(at: indexPath) as! CarDetailsPopupCell
            self.globalTextField.resignFirstResponder()
            
            let country = self.signUpTableData[4]
            
            if(data.tag > 0) {
                
                if country.text != "" && country.selectedid != "" {
                    let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                    let uploadDocumentVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kCountryStatePopupViewStoryBoardId) as! CountryStatePopupViewController
                    uploadDocumentVC.isCountrySelected = false
                    uploadDocumentVC.stateId = countryDetails["states"] as? [[String : Any]] ?? []
                    
                    uploadDocumentVC.callback                 = { details in
                        if(details.count > 0) {
                            data.selectedid = details["state_id"] as? String
                            data.text = details[ApiKeyConstants.kDriverName] as? String
                            cell.txtFldInfo.text = details[ApiKeyConstants.kDriverName]?.capitalized
                        }
                    }
                    
                    uploadDocumentVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    self.present(uploadDocumentVC, animated: true, completion: nil)
                    
                } else {
                    
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterCountry, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            } else {
                
                
                let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                let uploadDocumentVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kCountryStatePopupViewStoryBoardId) as! CountryStatePopupViewController
                uploadDocumentVC.isCountrySelected = true
                uploadDocumentVC.stateId = [[:]]
                
                uploadDocumentVC.callback                 = { details in
                    if(details.count > 0) {
                        self.countryDetails = details
                        data.selectedid = details["country_id"] as? String
                        data.text = details[ApiKeyConstants.kDriverName] as? String
                        cell.txtFldInfo.text = details[ApiKeyConstants.kDriverName]?.capitalized
                        
                        let state = self.signUpTableData[5]
                        
                        if(state.text != "") {
                            state.text = ""
                            state.selectedid = ""
                            let indexpath = NSIndexPath(row: 5, section: 0)
                            tableView.reloadRows(at: [indexpath as IndexPath], with: UITableView.RowAnimation.none)
                        }
                    }
                }
                
                uploadDocumentVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                self.present(uploadDocumentVC, animated: true, completion: nil)
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return signUpTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = signUpTableData[indexPath.row]
        
        if(data.cellType == "2") {
            
            let cell: CarDetailsPopupCell
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarDetailsPopupCellId, for: indexPath) as! CarDetailsPopupCell
            //cell.setUpTextFieldDelegate()
            
            cell.txtFldInfo.placeholder = data.placeholder
            cell.txtFldInfo.text = data.text
            
            cell.completionBlockShouldChange = { (textField, candidateString ) in
                
                return false
            }
            cell.completionBlock = { (textField, textFieldDelegateType) in
                DispatchQueue.main.async {
                    switch textFieldDelegateType {
                    case .textFieldDidBeginEditing:
                        break;
                    case .textFieldShouldBeginEditing:
                        textField.resignFirstResponder()
                        break;
                    case.textFieldDidEndEditing:
                        textField.resignFirstResponder()
                        break;
                    case.textFieldShouldReturn:
                        textField.resignFirstResponder()
                        break;
                    default:
                        break;
                    }
                }
                return true
            }
            
            cell.selectionStyle = .none
            return cell
            
        } else {
            
            let cell: CarDetailsTextFieldCell
            
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarDetailsTextCellId, for: indexPath) as! CarDetailsTextFieldCell
            
            cell.setUpTextFieldDelegate()
            
            cell.txtFldInfo.placeholder = data.placeholder
            cell.txtFldInfo.text = data.text
            cell.setupTextFieldKeyboardType(id: data.id)
            
            if(data.id == "password") {
                
                let rightButton  = UIButton(type: .custom)
                rightButton.frame = CGRect(x:0, y:0, width:50, height:50)
                if let image = UIImage(named: "EyeOff") {
                    rightButton.setImage(image, for: .normal)
                }
                if let image = UIImage(named: "EyeOn") {
                    rightButton.setImage(image, for: .selected)
                }
                
                cell.txtFldInfo.rightViewMode = .always
                cell.txtFldInfo.rightView = rightButton
                cell.txtFldInfo.isSecureTextEntry = true
                
                rightButton.removeControlEvent(.touchUpInside);
                rightButton.addControlEvent(.touchUpInside) {
                    if(rightButton.isSelected) {
                        cell.txtFldInfo.isSecureTextEntry = true
                    } else {
                        cell.txtFldInfo.isSecureTextEntry = false
                    }
                    rightButton.isSelected = !rightButton.isSelected
                }
            }
            
            cell.completionBlockShouldChange = { (textField, candidateString ) in
                data.text = candidateString
                return true
            }
            cell.completionBlock = { (textField, textFieldDelegateType) in
                DispatchQueue.main.async {
                    switch textFieldDelegateType {
                    case .textFieldShouldBeginEditing:
                        self.globalTextField = textField
                        textField.becomeFirstResponder()
                        break;
                    case.textFieldDidEndEditing:
                        textField.resignFirstResponder()
                        break;
                    default:
                        break;
                    }
                }
                return true
            }
            
            cell.selectionStyle = .none
            return cell
            
        }
    }
}


//MARK:- CollectionView Delegate And datasource

extension SignUpViewController: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout  {  //
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cellSignUpFormCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SignUpFormCollectionViewCell", for: indexPath as IndexPath) as! SignUpFormCollectionViewCell
        let cellOTPsignUpFormCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OTPsignUpFormCollectionViewCell", for: indexPath as IndexPath) as! OTPsignUpFormCollectionViewCell
        let cellMobileNumberSignUpCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MobileNumberSignUpCollectionViewCell", for: indexPath as IndexPath) as! MobileNumberSignUpCollectionViewCell
        
//        var timerForShowScrollIndicator: Timer?
//
//        func showScrollIndicatorsInContacts() {
//            UIView.animate(withDuration: 0.001) {
//                cellSignUpFormCollectionViewCell.table_Signup.flashScrollIndicators()
//            }
//        }
//
//        func startTimerForShowScrollIndicator() {
//            timerForShowScrollIndicator = Timer.scheduledTimer(timeInterval: 0.3, target: cellSignUpFormCollectionViewCell, selector: #selector(showScrollIndicatorsInContacts()), userInfo: nil, repeats: true)
//        }
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        if indexPath.item == 0 {
            if isSocial
            {
                cellSignUpFormCollectionViewCell.table_Signup.delegate = self
                cellSignUpFormCollectionViewCell.table_Signup.dataSource = self
                cellSignUpFormCollectionViewCell.table_Signup.flashScrollIndicators()
                cellSignUpFormCollectionViewCell.table_Signup.reloadData()
                
                cellSignUpFormCollectionViewCell.btn_camera.addTarget(self, action: #selector(Click_camra(sender:)), for: .touchUpInside)
                
                /*cellSignUpFormCollectionViewCell.delegate = self
                 cellSignUpFormCollectionViewCell.eyeOffOn.addTarget(self, action: #selector(eyeOpenClose(sender:)), for: .touchUpInside)
                 
                 cellSignUpFormCollectionViewCell.txtFld_FirstName.text = socialData["first_name"] as? String
                 cellSignUpFormCollectionViewCell.txtFld_LastName.text = socialData["last_name"] as? String
                 cellSignUpFormCollectionViewCell.txtFld_email.text = socialData["email"] as? String
                 cellSignUpFormCollectionViewCell.txtFld_email.becomeFirstResponder()*/
                
                cellSignUpFormCollectionViewCell.img_profilePic.kf.indicatorType = .activity
                
                if(isSocial) {
                    let profileImage = socialData[ApiKeyConstants.kImage] as? String
                    let AvatarUrl = URL(string: String(format:profileImage ?? ""))!
                    cellSignUpFormCollectionViewCell.img_profilePic.kf.setImage(with: AvatarUrl, placeholder: UIImage(named: "profileImagePlaceholder"), options: nil, progressBlock: nil) { (result) in
                        self.user_image = (cellSignUpFormCollectionViewCell.img_profilePic.image ?? nil)!
                    }
                }
                
                return cellSignUpFormCollectionViewCell
                
            } else
            {
                //cellMobileNumberSignUpCollectionViewCell.txtFld_mobileNumber.addDoneButtonToKeyboard(myAction:  #selector(cellMobileNumberSignUpCollectionViewCell.txtFld_mobileNumber.resignFirstResponder))
                
                cellMobileNumberSignUpCollectionViewCell.lbl_countryCode.text = "+\(appdelegate.dialCode)"
                cellMobileNumberSignUpCollectionViewCell.img_countryFlag.image = UIImage.init(named: "\(appdelegate.countryCode).png")
                // cellMobileNumberSignUpCollectionViewCell.btn_dialCode.addTarget(self, action: #selector(Click_Country(sender:)), for: UIControl.Event.touchUpInside)
                return cellMobileNumberSignUpCollectionViewCell
                
            }
        } else if indexPath.row == 1 {
            if isSocial
            {
                // cellMobileNumberSignUpCollectionViewCell.txtFld_mobileNumber.addDoneButtonToKeyboard(myAction:  #selector(cellMobileNumberSignUpCollectionViewCell.txtFld_mobileNumber.resignFirstResponder))
                cellMobileNumberSignUpCollectionViewCell.lbl_countryCode.text = "+\(appdelegate.dialCode)"
                cellMobileNumberSignUpCollectionViewCell.img_countryFlag.image = UIImage.init(named: "\(appdelegate.countryCode).png")
                //cellMobileNumberSignUpCollectionViewCell.btn_dialCode.addTarget(self, action: #selector(Click_Country(sender:)), for: UIControl.Event.touchUpInside)
                return cellMobileNumberSignUpCollectionViewCell
            }
            else
            {
                cellOTPsignUpFormCollectionViewCell.lbl_mobileNumber.text = "+\(userData["country_code"] ?? "\(appdelegate.dialCode)")-\(userData["mobile_number"] ?? "9830997689")" //userData["mobile_number"]
                cellOTPsignUpFormCollectionViewCell.btn_EditNumber.addTarget(self, action: #selector(Click_EditNumber(sender:)), for: UIControl.Event.touchUpInside)
                
                cellOTPsignUpFormCollectionViewCell.btn_ResendCode.addTarget(self, action: #selector(Click_ResendCode(sender:)), for: UIControl.Event.touchUpInside)
                
                return cellOTPsignUpFormCollectionViewCell
            }
            //            cell.backgroundColor = UIColor.red
        }
        else
        {
            if isSocial
            {
                cellOTPsignUpFormCollectionViewCell.lbl_mobileNumber.text = "+\(userData["country_code"] ?? "1")-\(userData["mobile_number"] ?? "")"
                //                cellOTPsignUpFormCollectionViewCell.lbl_dialCode.text = "+\(appdelegate.dialCode)"
                //                cellOTPsignUpFormCollectionViewCell.img_flg.image = UIImage.init(named: "\(appdelegate.countryCode).png")
                cellOTPsignUpFormCollectionViewCell.btn_EditNumber.addTarget(self, action: #selector(Click_EditNumber(sender:)), for: UIControl.Event.touchUpInside)
                
                cellOTPsignUpFormCollectionViewCell.btn_ResendCode.addTarget(self, action: #selector(Click_ResendCode(sender:)), for: UIControl.Event.touchUpInside)
                return cellOTPsignUpFormCollectionViewCell
            }
            else
            {
                cellSignUpFormCollectionViewCell.table_Signup.delegate = self
                cellSignUpFormCollectionViewCell.table_Signup.dataSource = self
                //self.scheduledTimerWithTimeInterval()
                cellSignUpFormCollectionViewCell.table_Signup.flashScrollIndicators()
                cellSignUpFormCollectionViewCell.table_Signup.reloadData()
                
                cellSignUpFormCollectionViewCell.btn_camera.addTarget(self, action: #selector(Click_camra(sender:)), for: .touchUpInside)
                //cellSignUpFormCollectionViewCell.delegate = self
                // cellSignUpFormCollectionViewCell.eyeOffOn.addTarget(self, action: #selector(eyeOpenClose(sender:)), for: .touchUpInside)
                
                if(isSocial) {
                    let profileImage = socialData[ApiKeyConstants.kImage] as? String
                    let AvatarUrl = URL(string: String(format:profileImage ?? ""))!
                    cellSignUpFormCollectionViewCell.img_profilePic.kf.setImage(with: AvatarUrl, placeholder: UIImage(named: "profileImagePlaceholder"), options: nil, progressBlock: nil) { (result) in
                        self.user_image = (cellSignUpFormCollectionViewCell.img_profilePic.image ?? nil)!
                    }
                }
                
                cellSignUpFormCollectionViewCell.img_profilePic.kf.indicatorType = .activity
                
                return cellSignUpFormCollectionViewCell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if !isSocial {
            if indexPath.row == 0{
                return CGSize(width: collectionView_signUp.frame.size.width-1, height: 161)
            }
            else if indexPath.row == 1
            {
                return CGSize(width: collectionView_signUp.frame.size.width-1, height: 226)
            }
            else{
                return CGSize(width: collectionView_signUp.frame.size.width-1, height: 394)
            }
        }
        else
        {
            if indexPath.row == 0{
                return CGSize(width: collectionView_signUp.frame.size.width-1, height: 394)
            }
            else if indexPath.row == 1
            {
                return CGSize(width: collectionView_signUp.frame.size.width-1, height: 161)
            }
            else{
                return CGSize(width: collectionView_signUp.frame.size.width-1, height: 226)
            }
        }
        
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        _ = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        NSLog("counting..")
    }
}

