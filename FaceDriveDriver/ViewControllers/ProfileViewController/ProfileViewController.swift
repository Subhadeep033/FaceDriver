//
//  ProfileViewController.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 16/02/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Cosmos
import Kingfisher
import SVProgressHUD
import AVFoundation
import Reachability
import Firebase
import FirebaseDatabase

class ProfileViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,verifyAndEditPhoneNumberDelegate,CountryCodeDelegate {
    
    var isFromPageView = Bool()
    let imagePicker = UIImagePickerController()
    var tableDataArray = [[String:Any]]()
    var carDetailsArray = [[String:Any]]()
    var selectedCarDetailsDict = [String:Any]()
    var isEditable = Bool()
    var selectedIndexPath = IndexPath()
    var isCarEdit = Bool()
    var isFromImagePicker = Bool()
    fileprivate var previousMobileNumber = String()
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var btnEdit_bottom: UIButton!
    @IBOutlet weak var btnChangePassword: UIButton!
    
    
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var profileImageBaseView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var changeProfileImageBtn: UIButton!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var profileDetailsTableView: UITableView!
    
    @IBOutlet weak var editButtonYConstraints: NSLayoutConstraint!
    @IBOutlet weak var backButtonYConstraints: NSLayoutConstraint!
    @IBOutlet weak var navigationHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var constBottomHeight: NSLayoutConstraint!
    
    @IBOutlet weak var nextButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //navigationHeightConstraints.constant = Utility.getHeightOfIphoneToSetNavigationBarHeight()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        if(isFromPageView) {
            self.navigationHeightConstraints.constant = 44.0
            self.constBottomHeight.constant = 70.0
            btnChangePassword.isHidden = true
            nextButton.isHidden = false
            ratingView.isHidden = true
            ratingLabel.isHidden = true
            
        } else {
            self.constBottomHeight.constant = 70.0
            btnChangePassword.isHidden = false
            nextButton.isHidden = true
            ratingView.isHidden = false
            ratingLabel.isHidden = false
        }
        
        profileDetailsTableView.estimatedRowHeight = 100.0
        profileDetailsTableView.rowHeight = UITableView.automaticDimension
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromImagePicker == false{
            //getDriverProfieDetails()
            self.initializeUI()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(isFromPageView) {
            self.checkPTCStatus()
        }
    }
    
    func checkPTCStatus(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let ptcStatus = driverDetailsDict[ApiKeyConstants.kUserDefaults.kPTCStatus] as? String ?? ""
        
        switch ptcStatus {
            
        case ApiKeyConstants.PTCStatus.kForReview:
            self.view.isUserInteractionEnabled = false
            break;
            
        case ApiKeyConstants.PTCStatus.kEConsentSent:
            self.view.isUserInteractionEnabled = false
            break;
            
        case ApiKeyConstants.PTCStatus.kAbstractReady:
            self.view.isUserInteractionEnabled = false
            break;
            
        case ApiKeyConstants.PTCStatus.kFingerPrintsRequired:
            self.view.isUserInteractionEnabled = false
            break;
            
        case ApiKeyConstants.PTCStatus.kAbstractRejected:
            self.view.isUserInteractionEnabled = false
            break;
            
        case ApiKeyConstants.PTCStatus.kPTCPending,ApiKeyConstants.PTCStatus.kPTCSubmissionReady:
            self.view.isUserInteractionEnabled = false
            break;
            
        case ApiKeyConstants.PTCStatus.kOrientationReady:
            self.view.isUserInteractionEnabled = false
            break;
            
        case ApiKeyConstants.PTCStatus.kHamiltonWaitingList:
            self.view.isUserInteractionEnabled = false
            break;
            
        default:
            self.view.isUserInteractionEnabled = true
            break;
        }
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        if (isFromPageView){
            let pageController = self.parent as! PageViewController
            pageController.scrollToIndex(index: 4, animated: true)
            NotificationCenter.default.post(name: NSNotification.Name("loadStatus"), object: nil)
        }
    }
    
    @IBAction func editButtonTap(_ sender: Any) {
        
        if isEditable {
            //     Save Action
            if tableDataArray[3][ApiKeyConstants.kIsMobileVerified] as? Bool == false {
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kVerifyMobileNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
            else{
                self.view.endEditing(true)
                let paramDict:[String:Any] = [ApiKeyConstants.kFirst_Name : tableDataArray[0][ApiKeyConstants.kFirstName] as? String ?? "",ApiKeyConstants.kLast_Name : tableDataArray[1][ApiKeyConstants.kLastName] as? String ?? "",ApiKeyConstants.kEmail : Utility.trimmingString((tableDataArray[2][ApiKeyConstants.kEmail] as? String ?? "").lowercased()),ApiKeyConstants.kCountry_code : Utility.trimmingString(tableDataArray[3][ApiKeyConstants.kCountryCode] as? String ?? ""),ApiKeyConstants.kMobile_number : Utility.trimmingString(tableDataArray[3][ApiKeyConstants.kMobileNumber] as? String ?? "")]
                if Utility.isValidPhoneNumber(testStr: Utility.trimmingString(tableDataArray[3][ApiKeyConstants.kMobileNumber] as? String ?? "")){
                    self.updateProfileApiCalled(paramDict: paramDict)
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidPhoneNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            }
        }
        else{
            isEditable = true
            editBtn.setTitle("Save", for: .normal)
            editBtn.titleLabel?.font = UIFont(name: "Roboto-Light", size: 17)
            editBtn.setTitleColor(UIColor.white, for: .normal)
            changeProfileImageBtn.isHidden = false
            cameraImageView.isHidden = false
            if (Reachibility.isConnectedToNetwork()){
                self.uploadApiResponseTime()
            }
            else{
                Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
            profileDetailsTableView.reloadData()
        }
    }
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeProfileImageTap(_ sender: Any) {
        self.showImagePickerPopup()
    }
    
    @IBAction func changePasswordTap(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kChangePasswordSegue, sender: nil)
    }
    
    //    MARK: Popup Delegate Methods ----
    func verifyPhoneNumber(isVerified: Bool) {
        if isVerified {
            let indexPath = IndexPath(row: 3, section: 0)
            let mobileCell : ProfileTableCell = profileDetailsTableView.cellForRow(at: indexPath) as! ProfileTableCell
            mobileCell.btnVerified.setTitle("Verified", for: .normal)
            mobileCell.btnVerified.setImage(UIImage(named: "stepComplete"), for: .normal)
            mobileCell.btnVerified.setTitleColor(Constants.AppColour.kAppGreenColor, for: .normal)
            tableDataArray[3][ApiKeyConstants.kIsMobileVerified] = true
            mobileCell.btnVerified.isUserInteractionEnabled = false
//            profileDetailsTableView.reloadData()
        }
        else{
            let indexPath = IndexPath(row: 3, section: 0)
            let mobileCell : ProfileTableCell = profileDetailsTableView.cellForRow(at: indexPath) as! ProfileTableCell
            mobileCell.btnVerified.setTitle("VERIFY", for: .normal)
            mobileCell.btnVerified.setImage(UIImage(named: "stepIncomplete"), for: .normal)
            mobileCell.btnVerified.setTitleColor(Constants.AppColour.kAppRedColor, for: .normal)
            tableDataArray[3][ApiKeyConstants.kIsMobileVerified] = false
            mobileCell.btnVerified.isUserInteractionEnabled = true
//            profileDetailsTableView.reloadData()
        }
    }
    
    func editPhoneNumber(isEdited: Bool) {
        if isEdited{
            let indexPath = IndexPath(row: 3, section: 0)
            let mobileCell : ProfileTableCell = profileDetailsTableView.cellForRow(at: indexPath) as! ProfileTableCell
            mobileCell.dataTextField.becomeFirstResponder()
        }
    }
    
    
    func initializeUI(){
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        profileImageBaseView.layer.cornerRadius = profileImageBaseView.frame.height/2
        profileImageBaseView.layer.borderColor = Constants.AppColour.kAppBorderColor.cgColor
        profileImageBaseView.layer.borderWidth = 1.0
        profileImageBaseView.clipsToBounds = true
        changeProfileImageBtn.isHidden = true
        cameraImageView.isHidden = true
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        debugPrint(driverDetailsDict)
        let urlString = driverDetailsDict[ApiKeyConstants.kImage] as? String ?? ""
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "profileImagePlaceholder"), options: nil, progressBlock: nil) { (result) in
            
        }
        //        profileImageView.kf.setImage(with: url)
        self.ratingLabel.text = NSString(format: "%.2f", driverDetailsDict[ApiKeyConstants.kRating] as? Double ?? 0.0) as String
        self.ratingView.rating = driverDetailsDict[ApiKeyConstants.kRating] as? Double ?? 0.0
        
        tableDataArray = [[ApiKeyConstants.kFirstName : Utility.trimmingString(driverDetailsDict[ApiKeyConstants.kFirst_Name] as? String ?? "")],[ApiKeyConstants.kLastName : Utility.trimmingString(driverDetailsDict[ApiKeyConstants.kLast_Name] as? String ?? "")],[ApiKeyConstants.kEmail : Utility.trimmingString((driverDetailsDict[ApiKeyConstants.kEmail] as? String ?? "").lowercased()),ApiKeyConstants.kIsEmailVerified : driverDetailsDict["email_verified"] as? Bool ?? false],[ApiKeyConstants.kMobileNumber : Utility.trimmingString(driverDetailsDict[ApiKeyConstants.kMobile_number] as? String ?? ""),ApiKeyConstants.kIsMobileVerified : driverDetailsDict["phone_verified"] as? Bool ?? false,ApiKeyConstants.kCountryCode : Utility.trimmingString(driverDetailsDict[ApiKeyConstants.kCountry_code] as? String ?? ""),"flag_code":(driverDetailsDict["flag_code"] as? String ?? "").uppercased()]]
        debugPrint("Count=",tableDataArray.count)
        
        profileDetailsTableView.reloadData()
        
    }
    
    //    MARK : ImagePicker Popup -----
    func showImagePickerPopup(){
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        let imagePopup = UIAlertController.init(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertAction.kChangeProfilePicture, preferredStyle: .actionSheet)
        imagePopup.view.tintColor = Constants.AppColour.kAppGreenColor
        let cameraAction = UIAlertAction.init(title: Constants.AppAlertAction.kPickFromCamera, style: .default) { (action) in
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if status == .restricted || status == .denied {
                Utility.showAlertForPermissionDenied(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kAllowCameraAccess, self)
            }else{
                //            Open Camera function
                self.openCamera()
            }
        }
        
        let galaryAction = UIAlertAction.init(title: Constants.AppAlertAction.kChooseFromGallery, style: .default) { (action) in
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if status == .restricted || status == .denied {
                Utility.showAlertForPermissionDenied(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kAllowGalleryAccess, self)
            }else{
                //            Open Galary function
                self.photoLibrary()
            }
        }
        //piyali change
        let cancelAction = UIAlertAction.init(title: Constants.AppAlertAction.kCancel, style: .default) { (action) in
            imagePopup.dismiss(animated: true, completion: nil)
        }
        imagePopup.addAction(cameraAction)
        imagePopup.addAction(galaryAction)
        imagePopup.addAction(cancelAction)
        
        self.present(imagePopup, animated: true, completion: nil)
    }
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func photoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
}

extension ProfileViewController {
    
    //    MARK : Tableview Delegate & DataSource -------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch indexPath.row {
        case 0:
            
            let cell: CarDetailsTextFieldCell
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarDetailsTextCellId, for: indexPath) as! CarDetailsTextFieldCell
            
            cell.setUpTextFieldDelegate()
            if(isEditable) {
                cell.txtFldInfo.isUserInteractionEnabled = true
                _ = cell.txtFldInfo.becomeFirstResponder()
            } else {
                cell.txtFldInfo.isUserInteractionEnabled = false
            }
            
            cell.txtFldInfo.placeholder = "First Name"
            cell.txtFldInfo.text = Utility.trimmingString((tableDataArray[indexPath.row][ApiKeyConstants.kFirstName] as? String)?.capitalized ?? "")
            cell.txtFldInfo.tag = indexPath.row
            
            cell.completionBlockShouldChange = { (textField, candidateString ) in
                
                self.tableDataArray[0][ApiKeyConstants.kFirstName] = Utility.trimmingString(textField.text ?? "")
                return true
            }
            cell.completionBlock = { (textField, textFieldDelegateType) in
                DispatchQueue.main.async {
                    switch textFieldDelegateType {
                    case .textFieldShouldBeginEditing:
                        textField.becomeFirstResponder()
                        break;
                    case.textFieldDidEndEditing:
                        if Utility.IsEmtyString(textField.text){
                            textField.becomeFirstResponder()
                            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterFirstName, Button_Title: Constants.AppAlertAction.kOKButton, self)
                        }
                        /*else if (Utility.isValidCharacterSet(str: textField.text!)){
                            let firstNameMessage = Constants.AppAlertMessage.kSpecialCharacter + " " + "In First Name."
                            Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: firstNameMessage, Button_Title: Constants.AppAlertAction.kOKButton, self)
                        }*/
                        else{
                            self.tableDataArray[0][ApiKeyConstants.kFirstName] = Utility.trimmingString(textField.text ?? "")
                        }
                        break;
                    default:
                        break;
                    }
                }
                return true
            }
            
            return cell
            
        case 1:
            
            let cell: CarDetailsTextFieldCell
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarDetailsTextCellId, for: indexPath) as! CarDetailsTextFieldCell
            
            cell.setUpTextFieldDelegate()
            
            if(isEditable) {
                cell.txtFldInfo.isUserInteractionEnabled = true
                
            } else {
                cell.txtFldInfo.isUserInteractionEnabled = false
            }
            
            cell.txtFldInfo.placeholder = "Last Name"
            cell.txtFldInfo.text = Utility.trimmingString((tableDataArray[indexPath.row][ApiKeyConstants.kLastName] as? String)?.capitalized ?? "")
            cell.txtFldInfo.tag = indexPath.row
            
            cell.completionBlockShouldChange = { (textField, candidateString ) in
                
                self.tableDataArray[1][ApiKeyConstants.kLastName] = Utility.trimmingString(textField.text ?? "")
                return true
            }
            cell.completionBlock = { (textField, textFieldDelegateType) in
                DispatchQueue.main.async {
                    switch textFieldDelegateType {
                    case .textFieldShouldBeginEditing:
                        textField.becomeFirstResponder()
                        break;
                    case.textFieldDidEndEditing:
                        
                        if Utility.IsEmtyString(textField.text){
                            textField.becomeFirstResponder()
                            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterLastName, Button_Title: Constants.AppAlertAction.kOKButton, self)
                        }
                        /*else if (Utility.isValidCharacterSet(str: textField.text!)){
                            let lastNameMessage = Constants.AppAlertMessage.kSpecialCharacter + " " + "In Last Name."
                            Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: lastNameMessage, Button_Title: Constants.AppAlertAction.kOKButton, self)
                        }*/
                        else{
                            self.tableDataArray[1][ApiKeyConstants.kLastName] = Utility.trimmingString(textField.text ?? "")
                        }
                        break;
                        
                    default:
                        break;
                    }
                }
                return true
            }
            
            return cell
            
        case 2:
            
            let profileCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kProfileCellID) as! ProfileTableCell
            
            if isEditable {
                profileCell.dataTextField.isUserInteractionEnabled = true
            }
            else{
                profileCell.dataTextField.isUserInteractionEnabled = false
            }
            
            profileCell.flagImage.isHidden = true
            profileCell.headerLabel.text = ApiKeyConstants.kEmail.capitalized
            profileCell.verifiedBtnWidthConstraints.constant = 80
            profileCell.lineViewHorizontalSpacingConstraints.constant = 0
            profileCell.countryCodeBtnWidthConstraints.constant = 0
            profileCell.downArrowImageview.isHidden = true
            profileCell.dataTextField.tag = indexPath.row
            profileCell.dataTextField.keyboardType = .emailAddress
            profileCell.dataTextField.text = Utility.trimmingString((tableDataArray[indexPath.row][ApiKeyConstants.kEmail] as? String)?.lowercased() ?? "")
            profileCell.btnVerified.addTarget(self, action: #selector(verifyBtnTap(sender:)), for: .touchUpInside)
            profileCell.btnVerified.tag = indexPath.row
            profileCell.dataTextField.tag = indexPath.row
            profileCell.dataTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            if tableDataArray[indexPath.row][ApiKeyConstants.kIsEmailVerified] as? Bool ?? false{
                profileCell.btnVerified.setTitle("Verified", for: .normal)
                profileCell.btnVerified.setTitleColor(Constants.AppColour.kAppGreenColor, for: .normal)
                profileCell.btnVerified.setImage(UIImage(named: "stepComplete"), for: .normal)
            }
            else{
                profileCell.btnVerified.setTitle("VERIFY", for: .normal)
                profileCell.btnVerified.setTitleColor(Constants.AppColour.kAppRedColor, for: .normal)
                profileCell.btnVerified.setImage(UIImage(named: "stepIncomplete"), for: .normal)
            }
            return profileCell
            
        case 3:
            
            let profileCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kProfileCellID) as! ProfileTableCell
            
            if isEditable {
                profileCell.dataTextField.isUserInteractionEnabled = true
            }
            else{
                profileCell.dataTextField.isUserInteractionEnabled = false
            }
            profileCell.flagImage.isHidden = false
            profileCell.headerLabel.text = "Mobile Number"
            profileCell.verifiedBtnWidthConstraints.constant = 80
            profileCell.lineViewHorizontalSpacingConstraints.constant = 4
            profileCell.countryCodeBtnWidthConstraints.constant = 95
            profileCell.dataTextField.tag = indexPath.row
            profileCell.dataTextField.keyboardType = .numberPad
            profileCell.dataTextField.text = Utility.trimmingString(tableDataArray[indexPath.row][ApiKeyConstants.kMobileNumber] as? String ?? "")
            profileCell.downArrowImageview.isHidden = false
            
            //                    profileCell.flagImage.image = UIImage.init(named: "\(appDelegate.countryCode).png")
            profileCell.countryCodeBtn.setTitle("+\(tableDataArray[indexPath.row][ApiKeyConstants.kCountryCode] as? String ?? "")", for: .normal)
            let countryFlagImage = "\(tableDataArray[indexPath.row]["flag_code"] as? String ?? "").png"
            profileCell.flagImage.image = UIImage(named: countryFlagImage )
            profileCell.countryCodeBtn.addTarget(self, action: #selector(countrCodePopupsShow(sender:)), for: .touchUpInside)
            profileCell.btnVerified.addTarget(self, action: #selector(verifyBtnTap(sender:)), for: .touchUpInside)
            profileCell.btnVerified.tag = indexPath.row
            profileCell.dataTextField.tag = indexPath.row
            profileCell.dataTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            if tableDataArray[indexPath.row][ApiKeyConstants.kIsMobileVerified] as? Bool ?? false {
                profileCell.btnVerified.setTitle("Verified", for: .normal)
                profileCell.btnVerified.setTitleColor(Constants.AppColour.kAppGreenColor, for: .normal)
                profileCell.btnVerified.setImage(UIImage(named: "stepComplete"), for: .normal)
            }
            else{
                profileCell.btnVerified.setTitle("VERIFY", for: .normal)
                profileCell.btnVerified.setTitleColor(Constants.AppColour.kAppRedColor, for: .normal)
                profileCell.btnVerified.setImage(UIImage(named: "stepIncomplete"), for: .normal)
            }
            return profileCell
            
        default:
            return UITableViewCell.init()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    @objc func addCarButtonTap(sender:UIButton!){
        debugPrint("Add Car")
        isCarEdit = false
        self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kCarDetailsSegue, sender: nil)
    }
    
    //     MARK : TextField Delegates -------
    
    @objc func textFieldDidChange(textField: UITextField){
        debugPrint("Text Field Tag = ",textField.tag)
        if textField.tag == 3{
            self.verifyPhoneNumber(isVerified: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        /*let indexPath = IndexPath(row: 0, section: 0)
         profileDetailsTableView.scrollToRow(at: indexPath, at: .top, animated: true)*/
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        /* let indexPath = IndexPath(row: 2, section: 0)
         profileDetailsTableView.scrollToRow(at: indexPath, at: .top, animated: true)*/
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //let indexPath = IndexPath(row: 0, section: 0)
        //profileDetailsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        if textField.tag == 2 {
            if Utility.IsEmtyString(textField.text){
                textField.becomeFirstResponder()
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterEmailIdAlert, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
            else
            {
                if Utility.isValidEmail(testStr: Utility.trimmingString(textField.text!)){
                    let indexPath = IndexPath(row: textField.tag, section: 0)
                    let emailCell : ProfileTableCell = profileDetailsTableView.cellForRow(at: indexPath) as! ProfileTableCell
                    if(Utility.isEqualtoString(Utility.trimmingString((tableDataArray[2][ApiKeyConstants.kEmail] as? String ?? "").lowercased()), Utility.trimmingString(textField.text!.lowercased()))){
                        
                        emailCell.btnVerified.setTitle("Verified", for: .normal)
                        emailCell.btnVerified.setImage(UIImage(named: "stepComplete"), for: .normal)
                        emailCell.btnVerified.setTitleColor(Constants.AppColour.kAppGreenColor, for: .normal)
                        emailCell.btnVerified.isUserInteractionEnabled = false
                        tableDataArray[2][ApiKeyConstants.kEmail] = Utility.trimmingString(textField.text?.lowercased() ?? "")
                        tableDataArray[2][ApiKeyConstants.kIsEmailVerified] = true
                        profileDetailsTableView.reloadData()
                    }
                    else{
                        emailCell.btnVerified.setTitle("VERIFY", for: .normal)
                        emailCell.btnVerified.setImage(UIImage(named: "stepIncomplete"), for: .normal)
                        emailCell.btnVerified.setTitleColor(Constants.AppColour.kAppRedColor, for: .normal)
                        tableDataArray[2][ApiKeyConstants.kEmail] = Utility.trimmingString(textField.text?.lowercased() ?? "")
//                        var driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
//                        driverDetailsDict["email_verified"] = false
//                        Utility.saveToUserDefaultsWithKeyandDictionary(driverDetailsDict , key: ApiKeyConstants.kUserDefaults.kDriverDetails)
                        tableDataArray[2][ApiKeyConstants.kIsEmailVerified] = false
                        emailCell.btnVerified.isUserInteractionEnabled = true
                        profileDetailsTableView.reloadData()
                    }
                }
                else{
                    textField.becomeFirstResponder()
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterEmailIdAlert, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            }
        }
        else {
            if Utility.IsEmtyString(textField.text){
                textField.becomeFirstResponder()
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterMobileNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
            else{
                let indexPath = IndexPath(row: textField.tag, section: 0)
                let mobileCell : ProfileTableCell = profileDetailsTableView.cellForRow(at: indexPath) as! ProfileTableCell
                debugPrint(tableDataArray[3][ApiKeyConstants.kMobileNumber] as? String ?? "", textField.text!)
                if(Utility.isEqualtoString(Utility.trimmingString(tableDataArray[3][ApiKeyConstants.kMobileNumber] as? String ?? ""), Utility.trimmingString(textField.text!))) && (tableDataArray[3][ApiKeyConstants.kIsMobileVerified] as? Bool == true){
                    
                    mobileCell.btnVerified.setTitle("Verified", for: .normal)
                    mobileCell.btnVerified.setImage(UIImage(named: "stepComplete"), for: .normal)
                    mobileCell.btnVerified.setTitleColor(Constants.AppColour.kAppGreenColor, for: .normal)
                    mobileCell.btnVerified.isUserInteractionEnabled = false
                }
                else{
                    mobileCell.btnVerified.setTitle("VERIFY", for: .normal)
                    mobileCell.btnVerified.setImage(UIImage(named: "stepIncomplete"), for: .normal)
                    mobileCell.btnVerified.setTitleColor(Constants.AppColour.kAppRedColor, for: .normal)
                    previousMobileNumber = tableDataArray[3][ApiKeyConstants.kMobileNumber] as? String ?? ""
                    tableDataArray[3][ApiKeyConstants.kMobileNumber] = Utility.trimmingString(textField.text!)
                    tableDataArray[3][ApiKeyConstants.kIsMobileVerified] = false
//                    var driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
//                    driverDetailsDict["phone_verified"] = false
//                    Utility.saveToUserDefaultsWithKeyandDictionary(driverDetailsDict , key: ApiKeyConstants.kUserDefaults.kDriverDetails)
                    mobileCell.btnVerified.isUserInteractionEnabled = true
                    profileDetailsTableView.reloadData()
                }
                
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let indexPath = IndexPath(row: textField.tag, section: 0)
//        let mobileCell : ProfileTableCell = profileDetailsTableView.cellForRow(at: indexPath) as! ProfileTableCell
        if textField.tag == 3 {
            let maxLength = 10
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.keyboardType == .numberPad || textField.keyboardType == .phonePad {
            setDoneOnKeyboard(sender: textField)
            return true
        }
        return true
    }
    
    
    func setDoneOnKeyboard(sender:UITextField) {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        sender.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        let indexPath = IndexPath(row: 0, section: 0)
        profileDetailsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        self.view.endEditing(true)
        profileDetailsTableView.reloadData()
    }
    
    //     MARK : UIImagePicker Controller Delegate ------
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        profileImageView.image  = tempImage.fixOrientation()
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        isFromImagePicker = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func verifyBtnTap(sender:UIButton!) {
        if sender.titleLabel?.text == "Verified"{
            sender.isUserInteractionEnabled = false
        }
        else{
            
            if sender.tag == 2{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEmailVerification, Button_Title: Constants.AppAlertAction.kOKButton, self)
                let indexPath = IndexPath(row: sender.tag, section: 0)
                let emailCell : ProfileTableCell = profileDetailsTableView.cellForRow(at: indexPath) as! ProfileTableCell
                emailCell.btnVerified.setTitle("Verified", for: .normal)
                emailCell.btnVerified.setImage(UIImage(named: "stepComplete"), for: .normal)
                emailCell.btnVerified.setTitleColor(Constants.AppColour.kAppGreenColor, for: .normal)
                emailCell.btnVerified.isUserInteractionEnabled = false
                tableDataArray[2][ApiKeyConstants.kEmail] = Utility.trimmingString(emailCell.dataTextField.text?.lowercased() ?? "")
                tableDataArray[2][ApiKeyConstants.kIsEmailVerified] = true
                profileDetailsTableView.reloadData()
            }
            else{
                sender.isUserInteractionEnabled = true
//                let verifyPhoneObj = VerifyPhoneNumberPopups.instanceFromNib()
//                verifyPhoneObj.verifyEditPhoneNumberDelegateObject = self
                let indexPath = IndexPath(row: sender.tag, section: 0)
                let mobileCell : ProfileTableCell = profileDetailsTableView.cellForRow(at: indexPath) as! ProfileTableCell
                let codeCountry = mobileCell.countryCodeBtn.titleLabel?.text!.replacingOccurrences(of: "+", with: "") ?? ""
                if Utility.isValidPhoneNumber(testStr: mobileCell.dataTextField.text!){
                    
                    if !Utility.isEqualtoString(mobileCell.dataTextField.text!, previousMobileNumber){
                        
                        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                        let verifyPopups = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kVerifyPhoneNumberPopupsViewStoryBoardId) as! VerifyPhoneNumberPopupsViewController
                        
                        verifyPopups.isFromUpdate = true
                        verifyPopups.isFromSignUp = false
                        verifyPopups.countryCode = codeCountry
                        verifyPopups.phoneNumber = mobileCell.dataTextField.text ?? ""
                        
                        verifyPopups.callback = {details in
                            self.verifyPhoneNumber(isVerified: details)
                        }
                        verifyPopups.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                        self.present(verifyPopups, animated: true, completion: nil)
                    }
                    else{
                        mobileCell.btnVerified.setTitle("Verified", for: .normal)
                        mobileCell.btnVerified.setImage(UIImage(named: "stepComplete"), for: .normal)
                        mobileCell.btnVerified.setTitleColor(Constants.AppColour.kAppGreenColor, for: .normal)
                        tableDataArray[3][ApiKeyConstants.kMobileNumber] = previousMobileNumber
                        tableDataArray[3][ApiKeyConstants.kIsMobileVerified] = true
                        mobileCell.btnVerified.isUserInteractionEnabled = false
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSameMobileNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    }
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kValidPhoneNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            }
        }
    }
    
    @objc func countrCodePopupsShow(sender:UIButton!){
        let countryPopUps = CountryCodePopups.instanceFromNib()
        countryPopUps.countryCodeObjDelegate = self
        countryPopUps.setupCountryCodePopups()
    }
    
    func selectedCountryCode(countryDetails: [String : Any]) {
        let indexPath = IndexPath(row: 3, section: 0)
        let mobileCell : ProfileTableCell = profileDetailsTableView.cellForRow(at: indexPath) as! ProfileTableCell
        let flagImage = "\(countryDetails["code"]!).png"
        
        mobileCell.flagImage.image = UIImage(named: flagImage)
        mobileCell.flagImage.isHidden = false
        mobileCell.countryCodeBtn.setTitle("+\(countryDetails["dial_code"] ?? "")", for: .normal)
        tableDataArray[3][ApiKeyConstants.kCountryCode] = "\(countryDetails["dial_code"] ?? "")"
        //        countryFlagImageView.image = UIImage(named: flagImage)
        
        //        countryCodeLabel.text = "+\(countryDetails["dial_code"] ?? "")"
    }
    
    // MARK:- Update Profile Api Called-----
    func updateProfileApiCalled(paramDict : [String:Any]!){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        debugPrint(paramDict)
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        debugPrint(dictHeaderParams)
        Utility.removeAppCookie()
        let profileUpdateUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kUpdateProfile
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Updating Driver Details...")
        }
        let jpegdata = Utility.resizeImage(image: profileImageView!.image!, width: 500)
        APIWrapper.requestMultipartWith(profileUpdateUrl, imageData: jpegdata, parameters: paramDict, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        self.isFromImagePicker = false
                        var resultDict : [String : Any] = dictResponse![ApiKeyConstants.kResult] as? [String : Any] ?? [:]
                        resultDict[ApiKeyConstants.kToken] = token
                        resultDict["cars"] = driverDetailsDict["cars"] as? [[String:Any]] ?? []
                        resultDict = Utility.recursiveNullRemoveFromDictionary(responseDict: resultDict)
                        debugPrint("Update Profile = ",resultDict)
                        Utility.saveToUserDefaultsWithKeyandDictionary(resultDict , key: ApiKeyConstants.kUserDefaults.kDriverDetails)
                        Utility.updateInterComUser()
                        self.updateProfileDataIntoFirebase(updatedProfileDict: resultDict)
                        self.isEditable = false
                        self.editBtn.setTitle("Edit", for: .normal)
                        self.editBtn.titleLabel?.font = UIFont(name: "Roboto-Light", size: 17)
                        self.editBtn.setTitleColor(UIColor.white, for: .normal)
                        self.changeProfileImageBtn.isHidden = true
                        self.cameraImageView.isHidden = true
                        self.profileDetailsTableView.reloadData()
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
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // MARK:- Profile Data Update Method-----
    func updateProfileDataIntoFirebase(updatedProfileDict : [String:Any]){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        
        if appDelegate.appDelHomeVcRef == nil{
            appDelegate.appDelHomeVcRef = Database.database().reference()
        }
        
        var driverName = updatedProfileDict[ApiKeyConstants.kFirst_Name] as? String ?? ""
        driverName += " "
        driverName += updatedProfileDict[ApiKeyConstants.kLast_Name] as? String ?? ""
        
        let mobileNumber : String = String(format: "%@%@", updatedProfileDict[ApiKeyConstants.kCountry_code] as? String ?? "",updatedProfileDict[ApiKeyConstants.kMobile_number] as? String ?? "")
        
        let values = [ApiKeyConstants.kDriverName : driverName, ApiKeyConstants.kMobile : mobileNumber, ApiKeyConstants.kImage : updatedProfileDict[ApiKeyConstants.kImage] as? String ?? ""]
        self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").updateChildValues(values)
    }
    
    // MARK:- Upload Api Response Time-----
    func uploadApiResponseTime(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        debugPrint(dictHeaderParams)
        Utility.removeAppCookie()
        let apiLogsUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kApiLogs
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Loading...")
        }
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kApiResponse) != nil)
        {
            appdelegate.arrApiResponse = UserDefaults.standard.array(forKey: ApiKeyConstants.kUserDefaults.kApiResponse)! as! [[String : AnyObject]]
        }
        else{
            appdelegate.arrApiResponse = [[:]]
        }
        let paramDict : [String:AnyObject] = ["logs" : appdelegate.arrApiResponse as AnyObject]
        APIWrapper.requestPOSTURL(apiLogsUrl, params: paramDict, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        Utility.removeFromUserDefaultsWithKeyandDictionary(ApiKeyConstants.kUserDefaults.kApiResponse)
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
        }) { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == Constants.StoryboardSegueConstants.kCarDetailsSegue){
            let carDetailsVCObj = segue.destination as! CarDetailsViewController
            carDetailsVCObj.isFromAddCar = !isCarEdit
            if isCarEdit{
                carDetailsVCObj.addedCarID = selectedCarDetailsDict[ApiKeyConstants.k_id] as? String ?? ""
                carDetailsVCObj.carDetails = selectedCarDetailsDict
            }
        }
        else if segue.identifier == Constants.StoryboardSegueConstants.kDocumentsUploadSegue{
            let documentObj = segue.destination as! UploadDrivingLicenceViewController
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            documentObj.isDriverDocuments = true
            let documents : [[String:Any]] = driverDetailsDict["personal_docs"] as? [[String : Any]] ?? []
            
            if documents.count > 0{
                documentObj.personalDetails = driverDetailsDict["personal_docs"] as? [[String : Any]] ?? []
            }
            else{
                documentObj.personalDetails = []
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
