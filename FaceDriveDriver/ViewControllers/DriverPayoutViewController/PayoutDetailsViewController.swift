//
//  PayoutDetailsViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 5/14/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import WeScan
import SVProgressHUD
import AVFoundation
import Reachability
import Alamofire

class PayoutDetailsData : Codable {
    let cellType : String!
    var text : String!
    var placeholder : String!
    var id : String!
    var selectedid : String!
    var imgFront : String!
    var imgBack : String!
    let tag : Int!
    var day  : String!
    var month : String!
    var year : String!
}

class PayoutDetailsViewController: UIViewController {
    fileprivate var bankDocumentsDict = [String:String]()
    fileprivate var payoutDetailTableData = [PayoutDetailsData]()
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var tableviewPayoutDetails: UITableView!
    var dicParams = [String:Any]()
    let imagePicker = UIImagePickerController()
    var selectedDocumnetId = String()
    fileprivate var selectedImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        do {
            let assetData = try Data(contentsOf: Bundle.main.url(forResource: "PayoutDetails", withExtension: ".json")!)
            payoutDetailTableData = try JSONDecoder().decode([PayoutDetailsData].self, from: (assetData))
            self.tableviewPayoutDetails.reloadData()
        } catch {
            print(error)
        }
        // Do any additional setup after loading the view.
    }

    // MARK:- Right Button To textfield
    func setRightButton(textfield: ACFloatingTextfield, buttonTag : Int) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "info"), for: .normal)
        button.frame = CGRect(x: CGFloat(textfield.frame.size.width - 50), y: CGFloat(7), width: CGFloat(50), height: CGFloat(70))
        button.tag = buttonTag
        button.addTarget(self, action: #selector(self.showInfo), for: .touchUpInside)
        textfield.rightView = button
        textfield.rightViewMode = .always
    }
    
    
    // MARK:- Button Action
    
    @objc func showInfo(_ sender: UIButton) {
        debugPrint(sender.tag)
        if (sender.tag == 1){
            bankDocumentsDict = [ApiKeyConstants.kTitle : "Transit Number",ApiKeyConstants.kDocumentsTag : "6"]
        }
        else if (sender.tag == 2){
            bankDocumentsDict = [ApiKeyConstants.kTitle : "Institution Number",ApiKeyConstants.kDocumentsTag : "7"]
        }
        else if (sender.tag == 3){
            bankDocumentsDict = [ApiKeyConstants.kTitle : "Account Number",ApiKeyConstants.kDocumentsTag : "8"]
        }
        else if (sender.tag == 4){
            bankDocumentsDict = [ApiKeyConstants.kTitle : "SIN Number",ApiKeyConstants.kDocumentsTag : "9"]
        }
        
        self.goToDocumentsHelpVC(bankDocs: bankDocumentsDict)
//        let alertController = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kBankDetailsOfCanada, preferredStyle: .alert)
//        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
//            alertController.dismiss(animated: true, completion: nil)
//        }
//        alertController.addAction(OKAction)
//
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .left
//        let messageText = NSAttributedString(
//            string: Constants.AppAlertMessage.kBankDetailsOfCanada,
//            attributes: [
//                NSAttributedString.Key.paragraphStyle: paragraphStyle,
//            ]
//        )
//
//        alertController.setValue(messageText, forKey: "attributedMessage")
//        self.present(alertController, animated: true, completion: nil)
    }
    
    func goToDocumentsHelpVC(bankDocs : [String:String]){
        let storyBoard = UIStoryboard.init(name: "Profile", bundle: Bundle.main)
        let documentsHelpPopup = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kDocumentsHelpStoryBoardId) as! DocumentsHelpViewController
        documentsHelpPopup.documentsHelpDetails = bankDocs
        documentsHelpPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(documentsHelpPopup, animated: true, completion: nil)
    }
    // MARK:- Button Action
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTap(_ sender: Any) {
        self.view.endEditing(true)
        if(self.validateAllFieldsForCarDetails()) {
            if Reachibility.isConnectedToNetwork(){
                addPayoutAccount()
            }
            else{
                Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
        }
    }
    
    @IBAction func uploadCarImageTap(_ sender: UIButton) {
        
        if sender.tag == 0 {
            selectedDocumnetId = "frontImage"
        } else {
            selectedDocumnetId = "backImage"
        }
        
        if sender.currentImage == UIImage(named: ApiKeyConstants.ImageType.kDocsIcon) {
            self.uploadDocuments()
        }
        else{
            let showAlert = UIAlertController.init(title: Constants.AppAlertMessage.kAlertTitle, message: "", preferredStyle: .actionSheet)
            showAlert.view.tintColor = Constants.AppColour.kAppGreenColor
            let view = UIAlertAction.init(title: Constants.AppAlertAction.kViewImage, style: .default) { (action) in
                let indexPath = IndexPath(row: 0, section: 2)
                let docsCell = self.tableviewPayoutDetails.cellForRow(at: indexPath) as! CarImageUploadCell
                
                if sender.tag == 0 {
                    self.selectedImage = docsCell.imgFront.image!
                } else if sender.tag == 1 {
                    self.selectedImage = docsCell.imgRear.image!
                } else if sender.tag == 2 {
                    self.selectedImage = docsCell.imgRight.image!
                } else {
                    self.selectedImage = docsCell.imgLeft.image!
                }
                
                self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kEnlargeSegue, sender: nil)
            }
            let change = UIAlertAction.init(title: Constants.AppAlertAction.kChangeImage, style: .default) { (action) in
                self.uploadDocuments()
            }
            let cancel = UIAlertAction.init(title: Constants.AppAlertAction.kNo, style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            showAlert.addAction(view)
            showAlert.addAction(change)
            showAlert.addAction(cancel)
            self.present(showAlert, animated: true, completion: nil)
        }
    }
    
    //MARK:- Photo Upload
    
    func photoLibrary(){
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func uploadDocuments(){
        let showAlert = UIAlertController.init(title: Constants.AppAlertMessage.kAlertTitle, message: "", preferredStyle: .actionSheet)
        showAlert.view.tintColor = Constants.AppColour.kAppGreenColor
        let camera = UIAlertAction.init(title: Constants.AppAlertAction.kPickFromCamera, style: .default) { (action) in
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if status == .restricted || status == .denied {
                Utility.showAlertForPermissionDenied(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kAllowCameraAccess, self)
            }else{
                //            Open Camera For Scan function
                self.scanDriverDetails()
            }
            
        }
        let galary = UIAlertAction.init(title: Constants.AppAlertAction.kChooseFromGallery, style: .default) { (action) in
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if status == .restricted || status == .denied {
                Utility.showAlertForPermissionDenied(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kAllowGalleryAccess, self)
            }else{
                //            Open Galary function
                self.photoLibrary()
            }
        }
        let cancel = UIAlertAction.init(title: Constants.AppAlertAction.kNo, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        showAlert.addAction(camera)
        showAlert.addAction(galary)
        showAlert.addAction(cancel)
        self.present(showAlert, animated: true, completion: nil)
    }
    
    func scanDriverDetails(){
        let scannerViewController = ImageScannerController()
        scannerViewController.imageScannerDelegate = self
        present(scannerViewController, animated: true)
    }

    
    // MARK:- Field Validation
    func validateAllFieldsForCarDetails() -> Bool {
        var isValid:Bool = true
        
        dicParams["default"] = false
        
        for item in payoutDetailTableData {
            let data: PayoutDetailsData = item
            switch data.id {
            case "acountholdername":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterAccountHolderName, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                }
                /*else if (Utility.isValidCharacterSet(str: data.text)){
                    let acountHolderNameMessage = Constants.AppAlertMessage.kSpecialCharacter + " " + "In Account Holder Name."
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: acountHolderNameMessage, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                }*/
                else {
                    dicParams["account_holder_name"] = data.text as AnyObject
                }
    
            case "transitnumber":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterRoutingNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    let routingNumber = dicParams["routing_number"] as? String ?? ""
                    if (Utility.isEqualtoString(routingNumber, "")){
                        dicParams["routing_number"] = data.text ?? ""
                    }
                    else{
                        var transtionNumber = data.text ?? ""
                        transtionNumber += "-" + routingNumber
                        dicParams["routing_number"] = transtionNumber
                    }
                    
                }
            case "institutionnumber":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterInstitutionNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    var routingNumber = dicParams["routing_number"] as? String ?? ""
                    if (Utility.isEqualtoString(routingNumber, "")){
                        dicParams["routing_number"] = data.text ?? ""
                    }
                    else{
                        let instutionNumber = data.text ?? ""
                        routingNumber += "-" + instutionNumber
                        dicParams["routing_number"] = routingNumber
                    }
                }
                
            case "accountnumber":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterAccountNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams["account_number"] = data.text as AnyObject
                }
                
            case "idnumber":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterIdNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams["id_number"] = data.text as AnyObject
                }
                
            case "firstname":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterFirstName, Button_Title: Constants.AppAlertAction.kOKButton, self)
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
                    dicParams["first_name"] = data.text as AnyObject
                }
                
            case "lastname":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterLastName, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                }
                /*else if (Utility.isValidCharacterSet(str: data.text)){
                    let lastNameMessage = Constants.AppAlertMessage.kSpecialCharacter + " " + "In Last Name."
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: lastNameMessage, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                }*/
                else {
                    dicParams["last_name"] = data.text as AnyObject
                }
                
            case "address":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterAddress, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams["address"] = data.text as AnyObject
                }
                
            case "state":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterStateOrProvince, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams["state"] = data.selectedid as AnyObject
                }
                
            case "city":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterCity, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams["city"] = data.text as AnyObject
                }
                
            case "postalcode":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterPostalCode, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams["postal_code"] = data.text as AnyObject
                }
                
            case "dob":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterDOB, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams["dob_day"] = data.day as AnyObject
                    dicParams["dob_month"] = data.month as AnyObject
                    dicParams["dob_year"] = data.year as AnyObject
                }
                
            default:
                break
            }
        }
        return isValid
    }
    
    //MARK:- Service Call
    
    func addPayoutAccount() {
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        let authToken = "Bearer " + token
        
        let headers: HTTPHeaders = [
            "Authorization"      : authToken,
            "cache-control"      : "no-cache"
        ]
        
        print(self.dicParams)
        
        let url = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kAddPayoutAccount
        
        debugPrint(self.dicParams)
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Adding Account...")
        }
        Utility.removeAppCookie()
        
        APIWrapper.requestPOSTURL(url, params: self.dicParams as [String : AnyObject], headers: headers, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            self.dicParams["routing_number"] = ""
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        self.getDriverProfieDetails()
                        self.navigationController?.popViewController(animated: true)
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
    
    func getDriverProfieDetails() {
        
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        Utility.removeAppCookie()
        let profileDetailsUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kDriverProfile
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show()
        }
        
        APIWrapper.requestPOSTURL(profileDetailsUrl, params: [:], headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        var resultDict : [String : Any] = dictResponse![ApiKeyConstants.kResult] as? [String : Any] ?? [:]
                        resultDict[ApiKeyConstants.kToken] = token
                        resultDict = Utility.recursiveNullRemoveFromDictionary(responseDict: resultDict)
                        debugPrint(resultDict)
                        Utility.saveToUserDefaultsWithKeyandDictionary(resultDict , key: ApiKeyConstants.kUserDefaults.kDriverDetails)
                        
                    } else {
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

// MARK:- Image Picker Delegate

extension PayoutDetailsViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
//        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        // need Api (pending upload document)
        //self.uploadCarDocuments(fieldName: selectedDocumnetId, documentImage: tempImage)
        self.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK:- Scanner Delegate

extension PayoutDetailsViewController : ImageScannerControllerDelegate {
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        debugPrint(results)
        
        // need Api (pending upload document)
        //uploadCarDocuments(fieldName: self.selectedDocumnetId, documentImage: results.scannedImage)
        scanner.dismiss(animated: true)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true, completion: nil)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        debugPrint(error)
    }
}

// MARK:- UITableViewDelegate

extension PayoutDetailsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell: CarDetailsPopupCell
        cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarDetailsPopupCellId, for: indexPath) as! CarDetailsPopupCell
        
        let data = payoutDetailTableData[indexPath.row]
        
        if(data.cellType == "2") {
            if(data.tag == 0) {
                
                let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                let countryPopupVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSelectCarPopupViewStoryBoardId) as! SelectCarPopupViewController
                countryPopupVC.tagNumber = 5
                countryPopupVC.headerTitle = "State/Province"
                
                countryPopupVC.callback                 = { details in
                    if(details.count > 0) {
                        data.selectedid = details["iso2"] as? String // cahnge
                        data.text = details[ApiKeyConstants.kDriverName] as? String
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
                
                countryPopupVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                self.present(countryPopupVC, animated: true, completion: nil)
                
            } else {
                let date_Picker = ActionSheetDatePicker(title: "", datePickerMode: UIDatePicker.Mode.date, selectedDate:Date(), doneBlock: {
                    picker, selectedDate, index in
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM, yyyy"
                    
                    data.text = dateFormatter.string(from: selectedDate as! Date)
                    cell.txtFldInfo.text = dateFormatter.string(from: selectedDate as! Date)
                    
                    //day
                    let dateFormatter1 = DateFormatter()
                    dateFormatter1.dateFormat = "dd"
                    data.day = dateFormatter1.string(from: selectedDate as! Date)
                    
                    //month
                    let dateFormatter2 = DateFormatter()
                    dateFormatter2.dateFormat = "MM"
                    data.month = dateFormatter2.string(from: selectedDate as! Date)
                   
                    //year
                    let dateFormatter3 = DateFormatter()
                    dateFormatter3.dateFormat = "yyyy"
                    data.year = dateFormatter3.string(from: selectedDate as! Date)
                    
                    tableView.reloadRows(at: [indexPath], with: .none)
                   
                }, cancel: { ActionStringCancelBlock in return }, origin: cell)
                
                date_Picker?.maximumDate = Date()
                date_Picker?.show()
            }
        }
        
    }
}

// MARK:- UITableViewDataSource

extension PayoutDetailsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return payoutDetailTableData.count - 1
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
            let data = payoutDetailTableData[indexPath.row]
            
            if(data.cellType == "1")  {
                
                let cell: CarDetailsTextFieldCell
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarDetailsTextCellId, for: indexPath) as! CarDetailsTextFieldCell
                
                cell.setUpTextFieldDelegate()
                
                cell.txtFldInfo.placeholder = data.placeholder
                cell.txtFldInfo.text = data.text
                
                cell.completionBlockShouldChange = { (textField, candidateString ) in
                    
                    data.text = candidateString
                    return true
                }
                cell.completionBlock = { (textField, textFieldDelegateType) in
                    DispatchQueue.main.async {
                        switch textFieldDelegateType {
                        case .textFieldShouldBeginEditing:
                            textField.becomeFirstResponder()
                            break;
                        case.textFieldShouldReturn:
                            textField.resignFirstResponder()
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
                
            } else if (data.cellType == "2") {
                
                let cell: CarDetailsPopupCell
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarDetailsPopupCellId, for: indexPath) as! CarDetailsPopupCell
                
                cell.setUpTextFieldDelegate()
                
                cell.txtFldInfo.isUserInteractionEnabled = false
                cell.txtFldInfo.placeholder = data.placeholder
                cell.txtFldInfo.text = data.text
                
                cell.completionBlockShouldChange = { (textField, candidateString ) in
                    
                    data.text = candidateString
                    return true
                }
                cell.completionBlock = { (textField, textFieldDelegateType) in
                    DispatchQueue.main.async {
                        switch textFieldDelegateType {
                        case .textFieldShouldBeginEditing:
                            textField.resignFirstResponder()
                            break;
                        case.textFieldShouldReturn:
                            textField.resignFirstResponder()
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
            else if (data.cellType == "4") {
                
                let cell: CarDetailsInfoCell
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarDetailsInfoCellId, for: indexPath) as! CarDetailsInfoCell
                
                cell.setUpTextFieldDelegate()
                self.setRightButton(textfield: cell.txtFldInfo, buttonTag: Int(indexPath.row))
                cell.txtFldInfo.placeholder = data.placeholder
                cell.txtFldInfo.text = data.text
                
                
                cell.completionBlockShouldChange = { (textField, candidateString ) in
                    
                    data.text = candidateString
                    return true
                }
                cell.completionBlock = { (textField, textFieldDelegateType) in
                    DispatchQueue.main.async {
                        switch textFieldDelegateType {
                        case .textFieldShouldBeginEditing:
                            textField.becomeFirstResponder()
                            break;
                        case.textFieldShouldReturn:
                            textField.resignFirstResponder()
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
            else {
                let cell: CarImageUploadCell
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarImageUploadCellId, for: indexPath) as! CarImageUploadCell
                
                cell.btnFront.tag = 0
                cell.btnRear.tag = 1
                cell.btnRight.tag = 2
                cell.btnLeft.tag = 3
                
                cell.btnFront.addTarget(self, action: #selector(uploadCarImageTap(_:)), for: .touchUpInside)
                cell.btnRear.addTarget(self, action: #selector(uploadCarImageTap(_:)), for: .touchUpInside)
                
                if(data.imgFront != nil) {
                    let url = URL(string: data.imgFront)
                    if data.imgFront.count == 0 {
                        cell.btnFront.setImage(UIImage(named: ApiKeyConstants.ImageType.kFront_Image), for: .normal)
                    }else{
                        cell.imgFront.kf.indicatorType = .activity
                        cell.imgFront.kf.setImage(with: url, placeholder: UIImage(named: ""), options: nil, progressBlock: nil) { (result) in
                            cell.imgFront.contentMode = .scaleAspectFit
                            cell.btnFront.setImage(UIImage(named: ""), for: .normal)
                        }
                    }
                } else {
                    cell.btnFront.setImage(UIImage(named: ApiKeyConstants.ImageType.kFront_Image), for: .normal)
                }
                
                if(data.imgBack != nil) {
                    let url = URL(string: data.imgBack)
                    if data.imgBack.count == 0 {
                        cell.btnRear.setImage(UIImage(named: ApiKeyConstants.ImageType.kRear_Image), for: .normal)
                    }else{
                        cell.imgRear.kf.indicatorType = .activity
                        cell.imgRear.kf.setImage(with: url, placeholder: UIImage(named: ""), options: nil, progressBlock: nil) { (result) in
                            cell.imgRear.contentMode = .scaleAspectFit
                            cell.btnRear.setImage(UIImage(named: ""), for: .normal)
                        }
                    }
                } else {
                    cell.btnRear.setImage(UIImage(named: ApiKeyConstants.ImageType.kRear_Image), for: .normal)
                }
                
                cell.selectionStyle = .none
                return cell
            }
    }
}
