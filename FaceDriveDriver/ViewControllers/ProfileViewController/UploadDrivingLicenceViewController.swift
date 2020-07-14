//
//  UploadDrivingLicenceViewController.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 30/01/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import WeScan
import SVProgressHUD
import AVFoundation
import Reachability
import Alamofire

class DocumentsUploadCell : UITableViewCell{
    
    @IBOutlet weak var drivingLicenceImageView: UIImageView!
    @IBOutlet weak var drivingLicenceButton: UIButton!
    @IBOutlet weak var underLineImageView: UIImageView!
    @IBOutlet weak var drivingLicenceLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
}

class UploadDrivingLicenceViewController: UIViewController,ImageScannerControllerDelegate,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    fileprivate var documentsTypeDict = [String:String]()
    var isFromPageView = Bool()
    var isDriverDocuments = Bool()
    //var carId = String()
    @IBOutlet weak var navigationTitleLabel: UILabel!
    //    var carDetails = [String:Any]()
    var personalDetails = [[String:Any]]()
    @IBOutlet weak var documentsUploadTableView: UITableView!
    let imagePicker = UIImagePickerController()
    fileprivate var isDrivingLicenceFrontSideTap = Bool()
    fileprivate var isDrivingLicenceBackSideTap = Bool()
    fileprivate var selectedImage = UIImage()
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var nextViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var nextButtonView: UIView!
    @IBOutlet weak var documentsLabelYConstraints: NSLayoutConstraint!
    @IBOutlet weak var navigationHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var backButtonYConstraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        if(isFromPageView) {
            self.navigationHeightConstraints.constant = 44.0
            nextButtonView.isHidden = false
            nextButtonHeightConstraints.constant = 60.0
            nextViewHeightConstraints.constant = 70.0
        }
        else{
            nextButtonView.isHidden = true
            nextButtonHeightConstraints.constant = 0
            nextViewHeightConstraints.constant = 0
        }
//        debugPrint("Car Details = ",carDetails)
        debugPrint("Personal = ",personalDetails)
        
        navigationTitleLabel.text = "Driver Documents"
        
        // Do any additional setup after loading the view.
        documentsUploadTableView.reloadData()
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
            pageController.scrollToIndex(index: 3, animated: true)
            NotificationCenter.default.post(name: NSNotification.Name("loadProfile"), object: nil)
        }
    }
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func scanDriverDetails(){
        let scannerViewController = ImageScannerController()
        scannerViewController.imageScannerDelegate = self
        present(scannerViewController, animated: true)
    }
}

extension UploadDrivingLicenceViewController{
    //    MARK : WeScan Delegate Methods ----
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        debugPrint(results)
        
        if self.isDrivingLicenceFrontSideTap {
           let indexPath = IndexPath(row: 0, section: 0)
           let cell = documentsUploadTableView.cellForRow(at: indexPath) as! DocumentsUploadCell
            cell.drivingLicenceLabel.contentMode = UIView.ContentMode.scaleAspectFit
            cell.drivingLicenceButton.setImage(UIImage(named: ""), for: .normal)
            cell.drivingLicenceImageView.contentMode = UIView.ContentMode.scaleAspectFit
            cell.drivingLicenceImageView.image = results.scannedImage
             uploadDriverDocuments(fieldName: "licenseImage", documentImage: results.scannedImage)
        }
        else if self.isDrivingLicenceBackSideTap {
            let indexPath = IndexPath(row: 1, section: 0)
            let cell = documentsUploadTableView.cellForRow(at: indexPath) as! DocumentsUploadCell
            cell.drivingLicenceLabel.contentMode = UIView.ContentMode.scaleAspectFit
            cell.drivingLicenceButton.setImage(UIImage(named: ""), for: .normal)
            cell.drivingLicenceImageView.contentMode = UIView.ContentMode.scaleAspectFit
            cell.drivingLicenceImageView.image = results.scannedImage
            uploadDriverDocuments(fieldName: "licenseBackImage", documentImage: results.scannedImage)
        }else {
            let indexPath = IndexPath(row: 2, section: 0)
            let cell = documentsUploadTableView.cellForRow(at: indexPath) as! DocumentsUploadCell
            cell.drivingLicenceLabel.contentMode = UIView.ContentMode.scaleAspectFit
            cell.drivingLicenceButton.setImage(UIImage(named: ""), for: .normal)
            cell.drivingLicenceImageView.contentMode = UIView.ContentMode.scaleAspectFit
            cell.drivingLicenceImageView.image = results.scannedImage
            uploadDriverDocuments(fieldName: "proofOfWorkImage", documentImage: results.scannedImage)
        }
        
        scanner.dismiss(animated: true)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true, completion: nil)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        debugPrint(error)
    }
    
    //    MARK : TableView Datasource & Delegate Methods ----
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 0.28
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let documentUploadCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kDocumentsCellId) as! DocumentsUploadCell
        documentUploadCell.drivingLicenceLabel.font = UIFont(name: "Roboto-Medium", size: 17.0)
        documentUploadCell.drivingLicenceLabel.textColor = Constants.AppColour.kAppBlackColor
        documentUploadCell.drivingLicenceButton.tag = indexPath.row
        documentUploadCell.drivingLicenceImageView.tag = indexPath.row
        documentUploadCell.drivingLicenceLabel.contentMode = UIView.ContentMode.scaleAspectFit
        documentUploadCell.drivingLicenceButton.addTarget(self, action: #selector(documentsUploadButtonTap(sender:)), for: .touchUpInside)
        documentUploadCell.infoButton.tag = indexPath.row
        documentUploadCell.infoButton.addTarget(self, action: #selector(infoButtonTap(sender:)), for: .touchUpInside)
        
        if indexPath.row == 0{
                documentUploadCell.drivingLicenceLabel.text = "Upload Driving License(Front Side)"
                var urlStr = String()
                if personalDetails.count > 0{
                    for image in 0..<personalDetails.count{
                        if personalDetails[image][ApiKeyConstants.kType] as? String ?? "" == "licenseImage"{
                            urlStr = personalDetails[image][ApiKeyConstants.kImage] as? String ?? ""
                            break
                        } else {
                            urlStr = ""
                        }
                    }
                }
                else{
                    urlStr = ""
                }
                let url = URL(string: urlStr )
                if urlStr.count == 0{
                    documentUploadCell.drivingLicenceButton.setImage(UIImage(named: ApiKeyConstants.ImageType.kDocsIcon), for: .normal)
                }else{
                    documentUploadCell.drivingLicenceImageView.kf.indicatorType = .activity
                    let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                    let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""

                    let token = "Bearer " + authToken
                    let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]

                    Alamofire.request(url!, method: .get, headers: dictHeaderParams).responseJSON { (responseObject) -> Void in
                        debugPrint(responseObject)
                        if responseObject.data != nil{
                            documentUploadCell.drivingLicenceImageView.image = UIImage(data: responseObject.data!)
                            documentUploadCell.drivingLicenceImageView.contentMode = .scaleAspectFit
                            documentUploadCell.drivingLicenceButton.setImage(UIImage(named: ""), for: .normal)
                        }
                        else{
                            documentUploadCell.drivingLicenceImageView.image = UIImage(named: "")
                            documentUploadCell.drivingLicenceButton.setImage(UIImage(named: ""), for: .normal)
                        }
                    }
                }
        }
        else if indexPath.row == 1{
            documentUploadCell.drivingLicenceLabel.text = "Upload Driving License(Back Side)"
            var urlStr = String()
            if personalDetails.count > 0{
                for image in 0..<personalDetails.count{
                    if personalDetails[image][ApiKeyConstants.kType] as? String ?? "" == "licenseBackImage"{
                        urlStr = personalDetails[image][ApiKeyConstants.kImage] as? String ?? ""
                        break
                    } else {
                        urlStr = ""
                    }
                }
            }
            else{
                urlStr = ""
            }
            let url = URL(string: urlStr )
            if urlStr.count == 0{
                documentUploadCell.drivingLicenceButton.setImage(UIImage(named: ApiKeyConstants.ImageType.kDocsIcon), for: .normal)
            }else{
                documentUploadCell.drivingLicenceImageView.kf.indicatorType = .activity
                let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
                
                let token = "Bearer " + authToken
                let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
                
                Alamofire.request(url!, method: .get, headers: dictHeaderParams).responseJSON { (responseObject) -> Void in
                    debugPrint(responseObject)
                    if responseObject.data != nil{
                        documentUploadCell.drivingLicenceImageView.image = UIImage(data: responseObject.data!)
                        documentUploadCell.drivingLicenceImageView.contentMode = .scaleAspectFit
                        documentUploadCell.drivingLicenceButton.setImage(UIImage(named: ""), for: .normal)
                    }
                    else{
                        documentUploadCell.drivingLicenceImageView.image = UIImage(named: "")
                        documentUploadCell.drivingLicenceButton.setImage(UIImage(named: ""), for: .normal)
                    }
                }
            }
        }
        else {
                documentUploadCell.drivingLicenceLabel.text = "Upload Second ID"
                var urlStr = String()
                if personalDetails.count > 0{
                    for image in 0..<personalDetails.count{
                        if personalDetails[image][ApiKeyConstants.kType] as? String ?? "" == "proofOfWorkImage"{
                            urlStr = personalDetails[image][ApiKeyConstants.kImage] as? String ?? ""
                            break
                        } else {
                            urlStr = ""
                        }
                    }
                }
                else{
                    urlStr = ""
                }
                let url = URL(string: urlStr )
                if urlStr.count == 0{
                    documentUploadCell.drivingLicenceButton.setImage(UIImage(named: ApiKeyConstants.ImageType.kDocsIcon), for: .normal)
                }else{
                    documentUploadCell.drivingLicenceImageView.kf.indicatorType = .activity
                    let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                    let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
                    
                    let token = "Bearer " + authToken
                    let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
                    
                    Alamofire.request(url!, method: .get, headers: dictHeaderParams).responseJSON { (responseObject) -> Void in
                        debugPrint(responseObject)
                        if responseObject.data != nil{
                            documentUploadCell.drivingLicenceImageView.image = UIImage(data: responseObject.data!)
                            documentUploadCell.drivingLicenceImageView.contentMode = .scaleAspectFit
                            documentUploadCell.drivingLicenceButton.setImage(UIImage(named: ""), for: .normal)
                        }
                        else{
                            documentUploadCell.drivingLicenceImageView.image = UIImage(named: "")
                            documentUploadCell.drivingLicenceButton.setImage(UIImage(named: ""), for: .normal)
                        }
                    }
                }
        }
        
        return documentUploadCell
    }
    
    //    MARK : TableCell Button Action Methods ----
    @objc func infoButtonTap(sender:UIButton!) {
        if (sender.tag == 0) || (sender.tag == 1){
            if (sender.tag == 0){
                documentsTypeDict = [ApiKeyConstants.kTitle : "Driver’s License",ApiKeyConstants.kDocumentsTag : "0"]
            }
            else if (sender.tag == 1){
                documentsTypeDict = [ApiKeyConstants.kTitle : "Driver’s License",ApiKeyConstants.kDocumentsTag : "1"]
            }
            
            //self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kDocumentsHelpSegue, sender: nil)
        }
        else{
            documentsTypeDict = [ApiKeyConstants.kTitle : "Second ID",ApiKeyConstants.kDocumentsTag : "2"]
            //self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kDocumentsHelpSegue, sender: nil)
        }
        self.goToDocumentsHelpVC(carDocs: documentsTypeDict)
    }
    
    func goToDocumentsHelpVC (carDocs: [String:String]){
        let storyBoard = UIStoryboard.init(name: "Profile", bundle: Bundle.main)
        let documentsHelpPopup = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kDocumentsHelpStoryBoardId) as! DocumentsHelpViewController
        documentsHelpPopup.documentsHelpDetails = carDocs
        documentsHelpPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(documentsHelpPopup, animated: true, completion: nil)
    }
    
    @objc func documentsUploadButtonTap(sender:UIButton!) {
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        if sender.tag == 0 {
            self.isDrivingLicenceFrontSideTap = true
            self.isDrivingLicenceBackSideTap = false
        }
        else if sender.tag == 1 {
            self.isDrivingLicenceBackSideTap = true
            self.isDrivingLicenceFrontSideTap = false
        }
        else{
            self.isDrivingLicenceFrontSideTap = false
            self.isDrivingLicenceBackSideTap = false
        }
        
        if sender.currentImage == UIImage(named: ApiKeyConstants.ImageType.kDocsIcon) && driverDetailsDict[ApiKeyConstants.kIsApproved] as? Int == 0 {
            /*if isDriverDocuments && sender.tag == 1{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: "Working Progress.", Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
            else{*/
                self.uploadDocuments()
//            }
            
        }
        else if sender.currentImage != UIImage(named: ApiKeyConstants.ImageType.kDocsIcon){
            let showAlert = UIAlertController.init(title: Constants.AppAlertMessage.kAlertTitle, message: "", preferredStyle: .actionSheet)
            showAlert.view.tintColor = Constants.AppColour.kAppGreenColor
            let view = UIAlertAction.init(title: Constants.AppAlertAction.kViewImage, style: .default) { (action) in
                let indexPath = IndexPath(row: sender.tag, section: 0)
                let docsCell = self.documentsUploadTableView.cellForRow(at: indexPath) as! DocumentsUploadCell
                self.selectedImage = docsCell.drivingLicenceImageView.image ?? UIImage()
                self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kEnlargeSegue, sender: nil)
            }
            showAlert.view.tintColor = Constants.AppColour.kAppGreenColor
            let change = UIAlertAction.init(title: Constants.AppAlertAction.kChangeImage, style: .default) { (action) in
                self.uploadDocuments()
            }
            let cancel = UIAlertAction.init(title: Constants.AppAlertAction.kNo, style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            showAlert.addAction(view)
            if driverDetailsDict[ApiKeyConstants.kIsApproved] as? Int == 0 {
                showAlert.addAction(change)
            }
            showAlert.addAction(cancel)
            self.present(showAlert, animated: true, completion: nil)
        }
    }
    
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
    
    //     MARK : UIImagePicker Controller Delegate ------
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let fixedOrientationImage = tempImage.fixOrientation()
        if self.isDrivingLicenceFrontSideTap{
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = documentsUploadTableView.cellForRow(at: indexPath) as! DocumentsUploadCell
            cell.drivingLicenceLabel.contentMode = UIView.ContentMode.scaleAspectFit
            cell.drivingLicenceButton.setImage(UIImage(named: ""), for: .normal)
            cell.drivingLicenceImageView.contentMode = UIView.ContentMode.scaleAspectFit
            cell.drivingLicenceImageView.image = tempImage
            
            uploadDriverDocuments(fieldName: "licenseImage", documentImage: fixedOrientationImage)
        }
        else if self.isDrivingLicenceBackSideTap{
            let indexPath = IndexPath(row: 1, section: 0)
            let cell = documentsUploadTableView.cellForRow(at: indexPath) as! DocumentsUploadCell
            cell.drivingLicenceLabel.contentMode = UIView.ContentMode.scaleAspectFit
            cell.drivingLicenceButton.setImage(UIImage(named: ""), for: .normal)
            cell.drivingLicenceImageView.contentMode = UIView.ContentMode.scaleAspectFit
            cell.drivingLicenceImageView.image = tempImage
            
            uploadDriverDocuments(fieldName: "licenseBackImage", documentImage: fixedOrientationImage)
        }else {
            let indexPath = IndexPath(row: 2, section: 0)
            let cell = documentsUploadTableView.cellForRow(at: indexPath) as! DocumentsUploadCell
            cell.drivingLicenceLabel.contentMode = UIView.ContentMode.scaleAspectFit
            cell.drivingLicenceButton.setImage(UIImage(named: ""), for: .normal)
            cell.drivingLicenceImageView.contentMode = UIView.ContentMode.scaleAspectFit
            cell.drivingLicenceImageView.image = tempImage
            
            uploadDriverDocuments(fieldName: "proofOfWorkImage", documentImage: fixedOrientationImage)
        }

        self.dismiss(animated: true, completion: nil)
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.StoryboardSegueConstants.kEnlargeSegue{
            let enlargeViewControllerObj = segue.destination as! EnlargeImageViewController
            enlargeViewControllerObj.enlargeImage = selectedImage
        }
    }
    
    //MARK :- Upload Driver Documents ----
    
    func uploadDriverDocuments(fieldName : String, documentImage : UIImage){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        let bodyParams:[String:String] = [ApiKeyConstants.kField_Name:fieldName]
        Utility.removeAppCookie()
        let profileUpdateUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kUploadDriverDocuments
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Updating Driver Details...")
        }
        let jpegdata = Utility.resizeImage(image: documentImage, width: 1000)
        APIWrapper.requestMultipartWith(profileUpdateUrl, imageData: jpegdata, parameters: bodyParams, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        debugPrint(dictResponse!)
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
