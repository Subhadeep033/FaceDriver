//
//  CarDetailsViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 08/03/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import WeScan
import SVProgressHUD
import AVFoundation
import ActionSheetPicker_3_0
import Reachability
import Alamofire

class CarDetailsData : Codable {
    let cellType : String!
    var text : String!
    var placeholder : String!
    var id : String!
    var selectedid : String!
    var selectedids : Array<String>!
    let tag : Int!
}

class CarDocumentData : Codable {
    let cellType : String!
    let placeholder : String!
    let id : String!
    var imgurl : String!
}

class CarImageData : Codable {
    
    let cellType : String!
    let placeholder : String!
    let id : String!
    var imgFront : String!
    var imgBack : String!
    var imgRight : String!
    var imgLeft : String!
}


class CarDetailsViewController: UIViewController,UIScrollViewDelegate {
    
    fileprivate var documentsDetails = [String:String]()
    var isPTCStatus = Bool()
    var isFromPageView = Bool()
    var isFromAddCar = Bool()
    var addedCarID = String()
    var carDetails = [String : Any]()
    var isEditable = Bool()
    var yearArray = [Int]()
    var isShowDocumantSection : Bool = false
    
    @IBOutlet weak var indicatorView: UIView!
    var selectedDocumnetId = String()
    var selectedCellType = String()
    var regionArr = [[String : Any]]()
    
    @IBOutlet weak var scrollToEndButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var navigationHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var viewSave: UIView!
    @IBOutlet weak var viewRemoveAndEdit: UIView!
    
    @IBOutlet weak var constRemoveAndEditHeight: NSLayoutConstraint!
    @IBOutlet weak var constSaveHeight: NSLayoutConstraint!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    fileprivate var carDetailTableData = [CarDetailsData]()
    fileprivate var carDocumentTableData = [CarDocumentData]()
    fileprivate var carImageTableData = [CarImageData]()
    fileprivate var selectedImage = UIImage()
    @IBOutlet weak var tableviewCarDetails: UITableView!
    var dicParams = [String:Any]()
    let imagePicker = UIImagePickerController()
    var selectedIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        if (isFromPageView) {
            self.navigationHeightConstraints.constant = 44.0
            self.removeBtn.isHidden = true
            self.nextButton.isHidden = false
        }
        self.initialLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        indicatorView.isHidden = true
        if(isFromPageView) {
            self.checkPTCStatus()
        }
    }
    
    func disableUI(){
        isPTCStatus = true
        isEditable = false
        viewSave.isHidden = true
        viewRemoveAndEdit.isHidden = true
        scrollToEndButton.isHidden = false
        self.constSaveHeight.constant = 0.0
        self.constRemoveAndEditHeight.constant = 0.0
    }
    
    func checkPTCStatus(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let ptcStatus = driverDetailsDict[ApiKeyConstants.kUserDefaults.kPTCStatus] as? String ?? ""
        
        switch ptcStatus {
        case ApiKeyConstants.PTCStatus.kForReview:
            self.disableUI()
            break;
            
        case ApiKeyConstants.PTCStatus.kEConsentSent:
            self.disableUI()
            break;
            
        case ApiKeyConstants.PTCStatus.kAbstractReady:
            self.disableUI()
            break;
            
        case ApiKeyConstants.PTCStatus.kFingerPrintsRequired:
            self.disableUI()
            break;
            
        case ApiKeyConstants.PTCStatus.kAbstractRejected:
            self.disableUI()
            break;
            
        case ApiKeyConstants.PTCStatus.kPTCPending,ApiKeyConstants.PTCStatus.kPTCSubmissionReady:
            self.disableUI()
            break;
            
        case ApiKeyConstants.PTCStatus.kOrientationReady:
            self.disableUI()
            break;
            
        case ApiKeyConstants.PTCStatus.kHamiltonWaitingList:
            self.disableUI()
            break;
            
        default:
            isPTCStatus = false
            break;
        }
    }
    
    
    func initialLoad(){
        btnEdit.setTitle("Edit", for: .normal)
        selectedDocumnetId = ""
        
        tableviewCarDetails.delegate = self
        tableviewCarDetails.estimatedRowHeight = 100.0
        tableviewCarDetails.rowHeight = UITableView.automaticDimension
        
        do {
            let assetData = try Data(contentsOf: Bundle.main.url(forResource: "CarDetails", withExtension: ".json")!)
            carDetailTableData = try JSONDecoder().decode([CarDetailsData].self, from: (assetData))
            
            do {
                let assetData = try Data(contentsOf: Bundle.main.url(forResource: "CarDocument", withExtension: ".json")!)
                carDocumentTableData = try JSONDecoder().decode([CarDocumentData].self, from: (assetData))
                
                do {
                    let assetData = try Data(contentsOf: Bundle.main.url(forResource: "CarImage", withExtension: ".json")!)
                    carImageTableData = try JSONDecoder().decode([CarImageData].self, from: (assetData))
                    
                    if isFromAddCar {
                        self.addedCarID = ""
                        isEditable = true
                        isShowDocumantSection = false
                        viewSave.isHidden = false
                        viewRemoveAndEdit.isHidden = true
                        scrollToEndButton.isHidden = true
                        self.view.layoutIfNeeded()
                        self.view.setNeedsUpdateConstraints()
                    } else {
                        self.setCarDetails()
                        isShowDocumantSection = true
                        
                        self.addedCarID = (carDetails[ApiKeyConstants.k_id] as? String ?? "")
                        if carDetails[ApiKeyConstants.kIsApproved] as? Int == 1 {
                            isEditable = false
                            viewSave.isHidden = true
                            viewRemoveAndEdit.isHidden = true
                            scrollToEndButton.isHidden = false
                            self.constSaveHeight.constant = 0.0
                            self.constRemoveAndEditHeight.constant = 0.0
                        } else {
                            isEditable = false
                            viewSave.isHidden = true
                            viewRemoveAndEdit.isHidden = false
                            scrollToEndButton.isHidden = false
                            if (isFromPageView) {
                                
                                self.removeBtn.isHidden = true
                                self.nextButton.isHidden = false
                            }
                            self.constSaveHeight.constant = 70.0
                            self.constRemoveAndEditHeight.constant = 70.0
                            btnEdit.setTitle("Edit", for: .normal)
                        }
                        
                        self.view.layoutIfNeeded()
                        self.view.setNeedsUpdateConstraints()
                    }
                    self.tableviewCarDetails.reloadData()
                } catch {
                    print(error)
                }
                
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    //MARK:- Reset Car Data ----
    func resetCarData() {
        do {
            let assetData = try Data(contentsOf: Bundle.main.url(forResource: "CarDetails", withExtension: ".json")!)
            carDetailTableData = try JSONDecoder().decode([CarDetailsData].self, from: (assetData))
            
            do {
                let assetData = try Data(contentsOf: Bundle.main.url(forResource: "CarDocument", withExtension: ".json")!)
                carDocumentTableData = try JSONDecoder().decode([CarDocumentData].self, from: (assetData))
                
                do {
                    let assetData = try Data(contentsOf: Bundle.main.url(forResource: "CarImage", withExtension: ".json")!)
                    carImageTableData = try JSONDecoder().decode([CarImageData].self, from: (assetData))
                    
                    self.addedCarID = ""
                    isEditable = true
                    isShowDocumantSection = false
                    viewSave.isHidden = false
                    viewRemoveAndEdit.isHidden = true
                    
                    self.view.layoutIfNeeded()
                    self.view.setNeedsUpdateConstraints()
                    
                    self.tableviewCarDetails.reloadData()
                } catch {
                    print(error)
                }
                
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    //MARK:- Set Car Details ------
    func setCarDetails() {
        let arrCarDocuments = carDetails["documents"] as? [[String : Any]] ?? []
        
        if(arrCarDocuments.count > 0) {
            self.isShowDocumantSection = true
            _ = carDocumentTableData.map({
                switch $0.id {
                case ApiKeyConstants.ImageType.kInsuranceImage :
                    
                    let dict = (arrCarDocuments.filter{($0[ApiKeyConstants.kType] as? String ?? "") == ApiKeyConstants.ImageType.kInsuranceImage}).first
                    $0.imgurl = dict?[ApiKeyConstants.kImage] as? String
                    
                    break;
                case ApiKeyConstants.ImageType.kRegistrationImage:
                    
                    let dict = (arrCarDocuments.filter{($0[ApiKeyConstants.kType] as? String ?? "") == ApiKeyConstants.ImageType.kRegistrationImage}).first
                    $0.imgurl = dict?[ApiKeyConstants.kImage] as? String
                    
                    break;
                case ApiKeyConstants.ImageType.kInspectionImage :
                    
                    let dict = (arrCarDocuments.filter{($0[ApiKeyConstants.kType] as? String ?? "") == ApiKeyConstants.ImageType.kInspectionImage}).first
                    $0.imgurl = dict?[ApiKeyConstants.kImage] as? String
                    
                    break;
                default:
                    break
                }
            })
            
            _ = carImageTableData.map({
                switch $0.id {
                case "carImage" :

                    $0.imgFront = ((arrCarDocuments.filter{($0[ApiKeyConstants.kType] as? String ?? "") == ApiKeyConstants.ImageType.kFrontImage}).first)?[ApiKeyConstants.kImage] as? String
                    $0.imgBack = ((arrCarDocuments.filter{($0[ApiKeyConstants.kType] as? String ?? "") == ApiKeyConstants.ImageType.kBackImage}).first)?[ApiKeyConstants.kImage] as? String
                    $0.imgRight = ((arrCarDocuments.filter{($0[ApiKeyConstants.kType] as? String ?? "") == ApiKeyConstants.ImageType.kRightImage}).first)?[ApiKeyConstants.kImage] as? String
                    $0.imgLeft = ((arrCarDocuments.filter{($0[ApiKeyConstants.kType] as? String ?? "") == ApiKeyConstants.ImageType.kLeftImage}).first)?[ApiKeyConstants.kImage] as? String
                    
                    break;
                
                default:
                    break
                }
            })
            
        }
        
        
        for item in carDetailTableData {
            let data: CarDetailsData = item
            switch data.id {
            case "Select Car Manufacturer":
                if (data.text.isNullString()){
                    data.text = carDetails[ApiKeyConstants.CarDetails.kManufacturer] as? String
                    data.selectedid = carDetails[ApiKeyConstants.CarDetails.kManufacturerId] as? String
                    dicParams[ApiKeyConstants.CarDetails.kManufacturer] = data.text as AnyObject
                    dicParams[ApiKeyConstants.CarDetails.kManufacturer_Id] = data.selectedid as AnyObject
                    break
                }
            case "Select Car Model":
                if (data.text.isNullString()){
                    data.text = carDetails[ApiKeyConstants.CarDetails.kModel] as? String
                    data.selectedid = carDetails[ApiKeyConstants.CarDetails.kModelId] as? String
                    dicParams[ApiKeyConstants.CarDetails.kModel] = data.text as AnyObject
                    dicParams[ApiKeyConstants.CarDetails.kModel_Id] = data.selectedid as AnyObject
                    break
                }
                
            case "Select Car Type":
                if (data.selectedid.isNullString()){
                    data.selectedid = carDetails[ApiKeyConstants.CarDetails.kType_id] as? String ?? ""
                    data.text = carDetails[ApiKeyConstants.kType] as? String
                    dicParams[ApiKeyConstants.kType] = data.selectedid as AnyObject
                    break
                }
            case "Select Energy Type":
                if (data.selectedid.isNullString()){
                    data.selectedid = carDetails[ApiKeyConstants.CarDetails.kEnergy_Id] as? String ?? ""
                    data.text = carDetails[ApiKeyConstants.CarDetails.kEnergy] as? String ?? ""
                    dicParams[ApiKeyConstants.CarDetails.kEnergyType] = data.selectedid as AnyObject
                    break
                }
                
            case "Enter Car VIN Number":
                if (data.text.isNullString()){
                    data.text = carDetails[ApiKeyConstants.CarDetails.kRegistrationNo] as? String
                    dicParams[ApiKeyConstants.CarDetails.kRegistration_No] = data.text as AnyObject
                    break
                }
            case "Select Year of Vehicle":
                if (data.text.isNullString()){
                    data.text = "\(carDetails[ApiKeyConstants.CarDetails.kYearOfVehicle] ?? "")"
                    dicParams[ApiKeyConstants.CarDetails.kYear_of_vehicle] = data.text as AnyObject
                    break
                }
            case "Number of Passenger seats":
                if (data.text.isNullString()){
                    data.text = "\(carDetails[ApiKeyConstants.CarDetails.kSeat] ?? "")"
                    dicParams[ApiKeyConstants.CarDetails.kSeat] = data.text as AnyObject
                    break
                }
            case "Select Region":
                
                self.regionArr = (carDetails[ApiKeyConstants.kRegion] as? [[String : Any]])!
                
                //let regionArr = carDetails[ApiKeyConstants.kRegion]
                //let region = regionArr[0]
                
                if (data.selectedids.count == 0){
                    let arrIds : Array = self.regionArr.map { $0[ApiKeyConstants.k_id] } as Array
                    data.selectedids = arrIds as? Array<String>
                    
                    let arrNames : Array<String> = (self.regionArr.map { $0[ApiKeyConstants.kDriverName] }) as! Array<String>
                    data.text = arrNames.joined(separator:",")
                    dicParams[ApiKeyConstants.CarDetails.kRegion_id] = data.selectedids as AnyObject
                    
                    break
                }
            case "Enter Car License Number":
                if (data.text.isNullString()){
                    data.text = carDetails[ApiKeyConstants.CarDetails.kLicensePlateNo] as? String
                    dicParams[ApiKeyConstants.CarDetails.kLicense_plate_no] = data.text as AnyObject
                    break
                }
            case "Type Car Colour":
                if (data.text.isNullString()){
                    data.text = carDetails[ApiKeyConstants.CarDetails.kColor] as? String
                    dicParams[ApiKeyConstants.CarDetails.kColor] = data.text as AnyObject
                    break
                }
//            case "Select Date of Registration":
//                if (data.text.isNullString()){
//                    let regtimestamp = carDetails["registrationDate"] as? Double
//                    data.text = Utility.convertTimeStampToDate(timeStamp: regtimestamp!)
//                    let replacedStr = data.text.replacingOccurrences(of: "/", with: "-")
//                    dicParams[ApiKeyConstants.CarDetails.kRegistrationDate] = replacedStr
//
//                    break
//                }
            default:
                break
            }
        }
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        if (isFromPageView){
            let pageController = self.parent as! PageViewController
            pageController.scrollToIndex(index: 2, animated: true)
            NotificationCenter.default.post(name: NSNotification.Name("loadDocuments"), object: nil)
        }
    }
    // MARK:- Button Action
    @IBAction func scrollToEndButtonTap(_ sender: Any) {
        DispatchQueue.main.async {
            if(self.isShowDocumantSection){
                let indexPath = IndexPath(row: self.carImageTableData.count-1, section: 2)
                self.tableviewCarDetails.scrollToRow(at: indexPath, at: .bottom, animated: true)
                self.scrollToEndButton.isHidden = true
            }
            else{
                let point = CGPoint(x: 0, y: self.tableviewCarDetails.contentSize.height + self.tableviewCarDetails.contentInset.bottom - self.tableviewCarDetails.frame.height)
                if point.y >= 0{
                    self.tableviewCarDetails.setContentOffset(point, animated: true)
                }
            }
        }
    }
    
    @IBAction func removeButtonTap(_ sender: Any) {
        if Reachibility.isConnectedToNetwork(){
            let removeCarAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kRemoveCarAlert, preferredStyle: .alert)
            removeCarAlert.view.tintColor = Constants.AppColour.kAppGreenColor
            let OkAction = UIAlertAction(title: Constants.AppAlertAction.kYESButton, style: .default) { (alert) in
                self.removeCarApiCalled()
            }
            let cancelAction = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default) { (alert) in
                removeCarAlert.dismiss(animated: true, completion: nil)
            }
            removeCarAlert.addAction(cancelAction)
            removeCarAlert.addAction(OkAction)
            self.present(removeCarAlert, animated: true, completion: nil)
            
        }
        else{
            Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    @IBAction func editButtonTap(_ sender: UIButton) {
        
        if(sender.title(for: .normal) == "Edit") {
            isEditable = true
            btnEdit.setTitle("Save", for: .normal)
            self.tableviewCarDetails.reloadData()
            
            let topIndex = IndexPath(row: 0, section: 0)
            tableviewCarDetails.scrollToRow(at: topIndex, at: .top, animated: true)
            
        } else {
                if(self.validateAllFieldsForCarDetails()) {
                if Reachibility.isConnectedToNetwork(){
                    addCarApiCalled()
                }
                else{
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            }
        }
        
    }
    
    //MARK:- Button Action -----
    @IBAction func uploadCarDocumentsTap(_ sender: UIButton) {
        if sender.tag == 0 {
            selectedDocumnetId = ApiKeyConstants.ImageType.kInsuranceImage
        } else if sender.tag == 1 {
            selectedDocumnetId = ApiKeyConstants.ImageType.kRegistrationImage
        } else {
            selectedDocumnetId = ApiKeyConstants.ImageType.kInspectionImage
        }
        selectedIndexPath = IndexPath(row: sender.tag, section: 1)
        selectedCellType = "CarDocumentCell"
        
        if sender.currentImage == UIImage(named: ApiKeyConstants.ImageType.kDocsIcon) && carDetails[ApiKeyConstants.kIsApproved] as? Int == 0 && isPTCStatus == false && self.indicatorView.isHidden{
            self.uploadDocuments()
        }
        else if sender.currentImage != UIImage(named: ApiKeyConstants.ImageType.kDocsIcon) && isPTCStatus == false && self.indicatorView.isHidden{
            let showAlert = UIAlertController.init(title: Constants.AppAlertMessage.kAlertTitle, message: "", preferredStyle: .actionSheet)
            showAlert.view.tintColor = Constants.AppColour.kAppGreenColor
            let view = UIAlertAction.init(title: Constants.AppAlertAction.kViewImage, style: .default) { (action) in
                let indexPath = IndexPath(row: sender.tag+1, section: 1)
                let docsCell = self.tableviewCarDetails.cellForRow(at: indexPath) as! CarDetailsDocumantCell
                self.selectedImage = docsCell.imgDrivingLicence.image!
                self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kEnlargeSegue, sender: nil)
            }
            let change = UIAlertAction.init(title: Constants.AppAlertAction.kChangeImage, style: .default) { (action) in
//                let indexPath = IndexPath(row: sender.tag+1, section: 1)
//                let docsCell = self.tableviewCarDetails.cellForRow(at: indexPath) as! CarDetailsDocumantCell
//                docsCell.btnDrivingLicence.isUserInteractionEnabled = false
                self.uploadDocuments()
            }
            let cancel = UIAlertAction.init(title: Constants.AppAlertAction.kNo, style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            showAlert.addAction(view)
            if carDetails[ApiKeyConstants.kIsApproved] as? Int == 0 {
                showAlert.addAction(change)
            }
            showAlert.addAction(cancel)
            self.present(showAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func infoButtonTap(_ sender: UIButton) {
        if sender.tag == 0 {
            documentsDetails = [ApiKeyConstants.kTitle : "Vehicle Insurance",ApiKeyConstants.kDocumentsTag : "3"]
        } else if sender.tag == 1 {
            documentsDetails = [ApiKeyConstants.kTitle : "Vehicle Registration",ApiKeyConstants.kDocumentsTag : "4"]
        } else {
            documentsDetails = [ApiKeyConstants.kTitle : "Vehicle Inspection",ApiKeyConstants.kDocumentsTag : "5"]
        }
        self.goToDocumentsHelpVC(carDocs: documentsDetails)
    }
    
    func goToDocumentsHelpVC (carDocs: [String:String]){
        let storyBoard = UIStoryboard.init(name: "Profile", bundle: Bundle.main)
        let documentsHelpPopup = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kDocumentsHelpStoryBoardId) as! DocumentsHelpViewController
        documentsHelpPopup.documentsHelpDetails = carDocs
        documentsHelpPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(documentsHelpPopup, animated: true, completion: nil)
    }
    
    @IBAction func uploadCarImageTap(_ sender: UIButton) {
        
        switch sender.tag {
            case 0:
                selectedDocumnetId = ApiKeyConstants.ImageType.kFrontImage
                break
            case 1:
                selectedDocumnetId = ApiKeyConstants.ImageType.kBackImage
                break
            case 2:
                selectedDocumnetId = ApiKeyConstants.ImageType.kRightImage
                break
            default:
                selectedDocumnetId = ApiKeyConstants.ImageType.kLeftImage
                break
        }
    
        selectedCellType = "CarImageCell"

        if (sender.currentImage == UIImage(named: ApiKeyConstants.ImageType.kRight_Image) || sender.currentImage == UIImage(named: ApiKeyConstants.ImageType.kRear_Image) || sender.currentImage == UIImage(named: ApiKeyConstants.ImageType.kLeft_Image) || sender.currentImage == UIImage(named: ApiKeyConstants.ImageType.kFront_Image)) && carDetails[ApiKeyConstants.kIsApproved] as? Int == 0 && isPTCStatus == false && self.indicatorView.isHidden{
            self.uploadDocuments()
        }
        else if sender.currentImage != UIImage(named: ApiKeyConstants.ImageType.kRight_Image) && sender.currentImage != UIImage(named: ApiKeyConstants.ImageType.kRear_Image) && sender.currentImage != UIImage(named: ApiKeyConstants.ImageType.kLeft_Image) && sender.currentImage != UIImage(named: ApiKeyConstants.ImageType.kFront_Image) && isPTCStatus == false && self.indicatorView.isHidden{
            
            let showAlert = UIAlertController.init(title: Constants.AppAlertMessage.kAlertTitle, message: "", preferredStyle: .actionSheet)
            showAlert.view.tintColor = Constants.AppColour.kAppGreenColor
            let view = UIAlertAction.init(title: Constants.AppAlertAction.kViewImage, style: .default) { (action) in
                let indexPath = IndexPath(row: 0, section: 2)
                let docsCell = self.tableviewCarDetails.cellForRow(at: indexPath) as! CarImageUploadCell
                
                switch sender.tag {
                case 0:
                    self.selectedImage = docsCell.imgFront.image ?? UIImage()
                    break
                case 1:
                    self.selectedImage = docsCell.imgRear.image ?? UIImage()
                    break
                case 2:
                    self.selectedImage = docsCell.imgRight.image ?? UIImage()
                    break
                default:
                    self.selectedImage = docsCell.imgLeft.image ?? UIImage()
                    break
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
            if carDetails[ApiKeyConstants.kIsApproved] as? Int == 0 {
                showAlert.addAction(change)
            }
            showAlert.addAction(cancel)
            self.present(showAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTap(_ sender: Any) {
        self.view.endEditing(true)
        if(self.validateAllFieldsForCarDetails()) {
            if Reachibility.isConnectedToNetwork(){
                addCarApiCalled()
            }
            else{
                Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
        }
    }
    
    // MARK:- Field Validation
    func validateAllFieldsForCarDetails() -> Bool {
        var isValid:Bool = true
        
        dicParams[ApiKeyConstants.kid] = self.addedCarID
        for item in carDetailTableData {
            let data: CarDetailsData = item
            switch data.id {
            case "Select Car Manufacturer":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterCarManufacturer, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams[ApiKeyConstants.CarDetails.kManufacturer] = data.text as AnyObject
                    dicParams[ApiKeyConstants.CarDetails.kManufacturer_Id] = data.selectedid as AnyObject
                }
                
            case "Select Car Model":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterCarModel, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams[ApiKeyConstants.CarDetails.kModel] = data.text as AnyObject
                    dicParams[ApiKeyConstants.CarDetails.kModel_Id] = data.selectedid as AnyObject
                }
                
            case "Select Car Type":
                if (data.selectedid.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterCarType, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams[ApiKeyConstants.kType] = data.selectedid as AnyObject
                }
            case "Select Energy Type":
                if (data.selectedid.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterEnergyType, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams[ApiKeyConstants.CarDetails.kEnergyType] = data.selectedid as AnyObject
                }
            case "Enter Car VIN Number":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterRegistraionNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams[ApiKeyConstants.CarDetails.kRegistration_No] = data.text as AnyObject
                }
            case "Select Year of Vehicle":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterYearOfVehicle, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams[ApiKeyConstants.CarDetails.kYear_of_vehicle] = data.text as AnyObject
                }
            case "Number of Passenger seats":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kSelectPassengerSeat, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams[ApiKeyConstants.CarDetails.kSeat] = data.text as AnyObject
                }
            case "Select Region":
                if (data.selectedids.count == 0){
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kSelectRegion, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams[ApiKeyConstants.CarDetails.kRegion_id] = data.selectedids as AnyObject
                }
            case "Enter Car License Number":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterCarLiecenseNumber, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                } else {
                    dicParams[ApiKeyConstants.CarDetails.kLicense_plate_no] = data.text as AnyObject
                }
            case "Type Car Colour":
                if (data.text.isNullString()){
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEnterCarColor, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                }
                /*else if (Utility.isValidCharacterSet(str: data.text)){
                    let carColourMessage = Constants.AppAlertMessage.kSpecialCharacter + " " + "In Car Colour."
                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: carColourMessage, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    isValid = false
                    break
                }*/
                else {
                    dicParams[ApiKeyConstants.CarDetails.kColor] = data.text as AnyObject
                }
//            case "Select Date of Registration":
//                if (data.text.isNullString()){
//                    Utility.ShowAlert(title:Constants.AppAlertMessage.kAlertTitle , message: Constants.AppAlertMessage.kEnterRegistrationOfVehicle, Button_Title: Constants.AppAlertAction.kOKButton, self)
//                    isValid = false
//                    break
//                } else {
//                    let replacedStr = data.text.replacingOccurrences(of: "/", with: "-")
//                    dicParams[ApiKeyConstants.CarDetails.kRegistrationDate] = replacedStr
//                }
            default:
                break
            }
        }
        return isValid
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
    
    func openCamera(){
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = .camera
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
                if (self.selectedCellType == "CarImageCell"){
                    self.openCamera()
                }
                else
                {
                    self.scanDriverDetails()
                }
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
    
    //MARK:- Navigation ---
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.StoryboardSegueConstants.kEnlargeSegue{
            let enlargeViewControllerObj = segue.destination as! EnlargeImageViewController
            enlargeViewControllerObj.enlargeImage = selectedImage
        }
    }
    
    // MARK:- ScrollView Delegate Methods-----
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)  {

            let offset = scrollView.contentOffset
            let bounds = scrollView.bounds
            let size = scrollView.contentSize
            let inset = scrollView.contentInset
            let y = offset.y + bounds.size.height - inset.bottom
            let h = size.height
            let reload_distance:CGFloat = 20.0
            if y > (h - reload_distance){
                scrollToEndButton.isHidden = true
            }
            else{
                scrollToEndButton.isHidden = false
            }
    }
    
    // MARK:- Service Call
    
    public func getDriverProfieDetails() {
        
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        Utility.removeAppCookie()
        let profileDetailsUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kDriverProfile
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Getting Driver Details...")
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
                        self.resetCarData()
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
    
    func uploadCarDocuments(fieldName : String, documentImage : UIImage) {
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        let bodyParams:[String:String] = [ApiKeyConstants.kField_Name:fieldName,ApiKeyConstants.CarDetails.kCar_Id : self.addedCarID]
        Utility.removeAppCookie()
        let addCarUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kAddCarDocuments
        self.view.isUserInteractionEnabled = false
        self.indicatorView.isHidden = false
        self.view.bringSubviewToFront(self.indicatorView)
//        DispatchQueue.main.async {
//            SVProgressHUD.setContainerView(self.view)
//            SVProgressHUD.show(withStatus: "Updating Car Details...")
//        }
        //let jpegdata = documentImage.jpegData(compressionQuality: 0.75)
        let jpegdata = Utility.resizeImage(image: documentImage, width: 1000)
        APIWrapper.requestMultipartWith(addCarUrl, imageData: jpegdata, parameters: bodyParams, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        
                        let resultDict : [String : Any] = dictResponse![ApiKeyConstants.kResult] as? [String : Any] ?? [:]
                        
//                        self.enableDisableImageUpload(enableDisable: true)
                        if(self.selectedCellType == "CarDocumentCell") {
                            _ = self.carDocumentTableData.map({
                                if($0.id == (resultDict[ApiKeyConstants.kField_Name] as? String)) {
                                    $0.imgurl = resultDict[ApiKeyConstants.kImage] as? String
                                }
//                                let indexPosition = IndexPath(row: indexPathRow, section: 0)
//                                debugPrint(self.selectedIndexPath)
//                                self.tableviewCarDetails.reloadRows(at: [self.selectedIndexPath], with: .none)
                                self.tableviewCarDetails.reloadSections(NSIndexSet(index: 1) as IndexSet, with: UITableView.RowAnimation.none)
                            })
                        } else {
                            
                            _ = self.carImageTableData.map({
                                
                                    if ((resultDict[ApiKeyConstants.kField_Name] as? String) == ApiKeyConstants.ImageType.kFrontImage) {
                                        $0.imgFront = resultDict[ApiKeyConstants.kImage] as? String
                                    } else if ((resultDict[ApiKeyConstants.kField_Name] as? String) == ApiKeyConstants.ImageType.kBackImage) {
                                        $0.imgBack = resultDict[ApiKeyConstants.kImage] as? String
                                    } else if ((resultDict[ApiKeyConstants.kField_Name] as? String) == ApiKeyConstants.ImageType.kRightImage) {
                                        $0.imgRight = resultDict[ApiKeyConstants.kImage] as? String
                                    } else {
                                        $0.imgLeft = resultDict[ApiKeyConstants.kImage] as? String
                                    }
                                    
                            })
                            
                            self.tableviewCarDetails.reloadSections(NSIndexSet(index: 2) as IndexSet, with: UITableView.RowAnimation.none)
                        }
                    }
                    else{
                        DispatchQueue.main.async {
//                            SVProgressHUD.dismiss()
//                            self.enableDisableImageUpload(enableDisable: true)
                            self.view.isUserInteractionEnabled = true
                            self.indicatorView.isHidden = true
                        }
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    }
                }
                else{
                    DispatchQueue.main.async {
//                        SVProgressHUD.dismiss()
//                        self.enableDisableImageUpload(enableDisable: true)
                        self.view.isUserInteractionEnabled = true
                        self.indicatorView.isHidden = true
                    }
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            }
            else{
                DispatchQueue.main.async {
//                    SVProgressHUD.dismiss()
//                    self.enableDisableImageUpload(enableDisable: true)
                    self.view.isUserInteractionEnabled = true
                    self.indicatorView.isHidden = true
                }
                Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
        })
        { (error) -> Void in
            DispatchQueue.main.async {
//                SVProgressHUD.dismiss()
//                self.enableDisableImageUpload(enableDisable: true)
                self.view.isUserInteractionEnabled = true
                self.indicatorView.isHidden = true
            }
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    func addCarApiCalled() {
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let token = "Bearer " + authToken
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
        let addCarUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kAddNewCar
        
        debugPrint(self.dicParams)
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Adding Car...")
        }
        Utility.removeAppCookie()
//        manufacturer_id
        APIWrapper.requestPUTURL(addCarUrl, params: self.dicParams as [String : AnyObject], headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        let dict = dictResponse![ApiKeyConstants.kResult] as? [String:Any] ?? [:]
                        self.carDetails = dict
                        self.addedCarID = dict[ApiKeyConstants.k_id] as? String ?? ""
                        
                        self.scrollToEndButton.isHidden = false
                        self.viewSave.isHidden = true
                        self.viewRemoveAndEdit.isHidden = false
                        self.isShowDocumantSection = true
                        
                        self.isEditable = false
                        self.isShowDocumantSection = true
                        self.btnEdit.setTitle("Edit", for: .normal)
                        self.tableviewCarDetails.reloadData()
                        
                        let indexPath = NSIndexPath(row: 1, section: 1)
                        self.tableviewCarDetails.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                        
                        //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
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
    
    func removeCarApiCalled() {
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        
        let token = "Bearer " + authToken
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
        let removeCarUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kRemoveCar
        
        let dictParams = [ApiKeyConstants.CarDetails.kCar_Id : addedCarID] as [String : Any]
        debugPrint(dictParams)
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Removing Car...")
        }
        Utility.removeAppCookie()
        APIWrapper.requestPUTURL(removeCarUrl, params: dictParams as [String : AnyObject], headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        let removeCarAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: (dictResponse![ApiKeyConstants.kMessage] as? String)?.capitalized, preferredStyle: .alert)
                        removeCarAlert.view.tintColor = Constants.AppColour.kAppGreenColor
                        let ok = UIAlertAction(title: Constants.AppAlertAction.kOKButton, style: .default) { (action) in
                            
                            if(self.isFromPageView) {
                                self.getDriverProfieDetails()
                            } else {
                                self.navigationController?.popViewController(animated: true)
                            }
                            let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                            let carPopup = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSelectRegionPopupViewStoryBoardId) as! SelectRegionPopupViewController
                            carPopup.selectedDataSet.removeAll()
                            carPopup.idSet.removeAll()
                            self.regionArr.removeAll()
                        }
                        removeCarAlert.addAction(ok)
                        
                        self.present(removeCarAlert, animated: true, completion: nil)
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
            debugPrint("Error :",error)
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
}



// MARK:- Image Picker Delegate

extension CarDetailsViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let fixedOrientationImage = tempImage.fixOrientation()
        self.view.isUserInteractionEnabled = false
        self.indicatorView.isHidden = false
        self.view.bringSubviewToFront(self.indicatorView)
        uploadCarDocuments(fieldName: selectedDocumnetId, documentImage: fixedOrientationImage)
        self.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
//                                SVProgressHUD.dismiss()
                                self.view.isUserInteractionEnabled = true
                                self.indicatorView.isHidden = true
//                                self.enableDisableImageUpload(enableDisable: true)
                            }
        self.tableviewCarDetails.reloadData()
    }
}

// MARK:- Scanner Delegate

extension CarDetailsViewController : ImageScannerControllerDelegate {
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        debugPrint(results)
        let fixedOrientationImage = results.scannedImage.fixOrientation()
        self.view.isUserInteractionEnabled = false
        self.indicatorView.isHidden = false
        self.view.bringSubviewToFront(self.indicatorView)
        uploadCarDocuments(fieldName: self.selectedDocumnetId, documentImage: fixedOrientationImage)
        scanner.dismiss(animated: true)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
//                                SVProgressHUD.dismiss()
                                self.view.isUserInteractionEnabled = true
                                self.indicatorView.isHidden = true
//                                self.enableDisableImageUpload(enableDisable: true)
                            }
        self.tableviewCarDetails.reloadData()
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        debugPrint(error)
    }
    
    
    
}
// MARK:- UITAbleview Delegate

extension CarDetailsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(self.isEditable) {
            
            if(indexPath.section == 0) {
                let data = carDetailTableData[indexPath.row]
                
                if(data.cellType == "1") {
                    
                    if(data.tag == 3) {
                        let carManufractureData = self.carDetailTableData[1]
                        
                        if carManufractureData.text != "" || carManufractureData.selectedid != "" {
                            
                            let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                            let carPopup = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSelectCarPopupViewStoryBoardId) as! SelectCarPopupViewController
                            carPopup.tagNumber = data.tag
                            carPopup.headerTitle = data.id
                            carPopup.manufacturerID = carManufractureData.selectedid
                            
                            carPopup.callback                 = { details in
                                
                                if(details.count > 0) {
                                    
                                    // cell.txtFldInfo.text = details[ApiKeyConstants.kDriverName]?.capitalized
                                    data.text = details[ApiKeyConstants.kDriverName] as? String
                                    data.selectedid = details[ApiKeyConstants.kid] as? String
                                }
                                
                                self.tableviewCarDetails.reloadData()
                            }
                            carPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                            self.present(carPopup, animated: true, completion: nil)
                            
                        } else {
                            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kCarManuFacturer, Button_Title: Constants.AppAlertAction.kOKButton, self)
                        }
                    } else if(data.tag == 1) {
                        
                        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                        let carPopup = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSelectRegionPopupViewStoryBoardId) as! SelectRegionPopupViewController
                        carPopup.headerTitle = data.id
                        
                        if(self.isEditable) || (self.isFromAddCar){
                            if(self.regionArr.count > 0) {
                                carPopup.isEdit = true
                                let ids = self.regionArr.map { $0[ApiKeyConstants.k_id] as? String ?? ""}
                                carPopup.idSet = Set(ids)
                            }
                        }
                        
                        carPopup.callback                 = { details in
                            
                            var arrayRegion = [[String : Any]]()
                            var arr = [String]()
                            var stringName = ""
                            for items in details {
                                arr.append(items[ApiKeyConstants.k_id] as? String ?? "")
                                if(stringName == "") {
                                    stringName = items[ApiKeyConstants.kDriverName] as? String ?? ""
                                } else {
                                    stringName +=  ", " + (items[ApiKeyConstants.kDriverName] as? String ?? "")
                                    
                                }
                                arrayRegion.append(items)
                                
                            }
                            
                            data.text = stringName
                            data.selectedids = arr
                            self.regionArr = arrayRegion
                            
                            self.tableviewCarDetails.reloadData()
                        }
                        carPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                        self.present(carPopup, animated: true, completion: nil)
                        
                        
                    }
                    else if (data.tag == 4){
                        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                        let carPopup = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSelectCarPopupViewStoryBoardId) as! SelectCarPopupViewController
                        carPopup.tagNumber = data.tag
                        carPopup.headerTitle = data.id
                        carPopup.manufacturerID = ""
                        
                        carPopup.callback                 = { details in
                            data.text = details[ApiKeyConstants.kDriverName] as? String
                            data.selectedid = details[ApiKeyConstants.k_id] as? String
                            self.tableviewCarDetails.reloadData()
                        }
                        
                        carPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                        self.present(carPopup, animated: true, completion: nil)
                    }
                    else {
                        
                        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                        let carPopup = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSelectCarPopupViewStoryBoardId) as! SelectCarPopupViewController
                        carPopup.tagNumber = data.tag
                        carPopup.headerTitle = data.id
                        carPopup.manufacturerID = ""
                        
                        carPopup.callback                 = { details in
                            if(details.count > 0) {
                                if(data.tag == 0) {
                                    data.selectedid = details[ApiKeyConstants.CarDetails.kCar_Type_Id] as? String
                                    data.text = details[ApiKeyConstants.CarDetails.kCar_Type] as? String
                                    let carTypeIndexPath = NSIndexPath(row: 3, section: 0)
                                    tableView.reloadRows(at: [carTypeIndexPath as IndexPath], with: UITableView.RowAnimation.none)
                                    
                                    let passengerseat = self.carDetailTableData[6]
                                    passengerseat.text = "\(details[ApiKeyConstants.CarDetails.kCapacity] as AnyObject)"
                                    
                                    let passengerSeatIndexPath = NSIndexPath(row: 6, section: 0)
                                    tableView.reloadRows(at: [passengerSeatIndexPath as IndexPath], with: UITableView.RowAnimation.none)
                                    
                                } else if(data.tag == 2) {
                                    
                                    let carModelData = self.carDetailTableData[2]
                                    
                                    data.text = details[ApiKeyConstants.kDriverName] as? String
                                    data.selectedid = details[ApiKeyConstants.kid] as? String
                                    
                                    carModelData.text = ""
                                    carModelData.selectedid = ""
                                    
                                    self.tableviewCarDetails.reloadData()
                                }
                            }
                        }
                        
                        carPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                        self.present(carPopup, animated: true, completion: nil)
                    }
                }
                else if (data.cellType == "3") {
                    
                    let cell = tableView.cellForRow(at: indexPath) as? CarDetailsPopupCell
                    
                    var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    calendar.timeZone = TimeZone(identifier: "UTC")!
                    
                    let currentYear = calendar.component(.year, from: Date())
                    let startYear = currentYear - 7
                    for year in startYear..<currentYear + 2{
                        self.yearArray.append(year)
                    }
                    
                    ActionSheetStringPicker.show(withTitle: "", rows: self.yearArray, initialSelection: 0, doneBlock: {
                        picker, selectedRow, selectedString in
                        data.text = String(describing: selectedString!)
                        cell?.txtFldInfo.text = String(describing: selectedString!)
                    }, cancel: { ActionStringCancelBlock in return }, origin: cell)
                }
                else if (data.cellType == "4") {
                    
                    let cell = tableView.cellForRow(at: indexPath) as? CarDetailsPopupCell
                    
                    let datePicker = ActionSheetDatePicker(title: "", datePickerMode: .date, selectedDate: Date(), doneBlock: { picker, value, index in
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd/MM/yyyy"
                        let localDateString = formatter.string(from: value as! Date)
                        print(localDateString )
                        cell?.txtFldInfo.text = localDateString
                        formatter.dateFormat = "dd-MM-yyyy"
                        let dateStr = formatter.string(from: value as! Date)
                        data.text = dateStr
                        
                        return
                    }, cancel: { ActionStringCancelBlock in return }, origin: cell)
                    datePicker?.maximumDate = Date()
                    datePicker?.show()
                }
            }
        }
    }
    
}

// MARK:- UITableViewDataSource

extension CarDetailsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if(isShowDocumantSection){
            return 3
        } else {
           return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return carDetailTableData.count
        } else if (section == 1) {
            return carDocumentTableData.count + 1
        } else {
            return carImageTableData.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let data = carDetailTableData[indexPath.row]
            
            if(data.cellType == "1") {
                
                let cell: CarDetailsPopupCell
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarDetailsPopupCellId, for: indexPath) as! CarDetailsPopupCell
                cell.setUpTextFieldDelegate()
                
                cell.txtFldInfo.placeholder = data.placeholder
                if ((Utility.isEqualtoString(cell.txtFldInfo.placeholder ?? "", "Select Car Model")) || (Utility.isEqualtoString(cell.txtFldInfo.placeholder ?? "", "Select Car Type")) || (Utility.isEqualtoString(cell.txtFldInfo.placeholder ?? "", "Select Car Manufacturer")) || (Utility.isEqualtoString(cell.txtFldInfo.placeholder ?? "", "Select Energy Type"))){
                    cell.txtFldInfo.text = data.text
                }
                else{
                    cell.txtFldInfo.text = data.text.capitalized
                }
                cell.completionBlockShouldChange = { (textField, candidateString ) in
                    return false
                }
                cell.completionBlock = { (textField, textFieldDelegateType) in
                    DispatchQueue.main.async {
                        switch textFieldDelegateType {
                        case .textFieldDidBeginEditing:
                            textField.resignFirstResponder()
                            break;
                        case .textFieldShouldBeginEditing:
                            textField.resignFirstResponder()
                            break;
                        case.textFieldDidEndEditing:
                            textField.resignFirstResponder()
                        default:
                            break;
                        }
                    }
                    return true
                }
                
                cell.selectionStyle = .none
                return cell
                
            } else if (data.cellType == "2") {
                
                let cell: CarDetailsTextFieldCell
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarDetailsTextCellId, for: indexPath) as! CarDetailsTextFieldCell
                
                cell.setUpTextFieldDelegate()
                
                if(isEditable) {
                    
                    if(data.id == "Number of Passenger seats") {
                        cell.txtFldInfo.isUserInteractionEnabled = false
                    } else {
                        cell.txtFldInfo.isUserInteractionEnabled = true
                    }
                    
                } else {
                    cell.txtFldInfo.isUserInteractionEnabled = false
                }
                
                cell.txtFldInfo.placeholder = data.placeholder
                
                if (data.id == "Enter Car VIN Number") || (data.id == "Enter Car License Number"){
                    cell.txtFldInfo.autocapitalizationType = .allCharacters
                    cell.txtFldInfo.text = data.text.uppercased()
                }else{
                    cell.txtFldInfo.autocapitalizationType = .words
                    cell.txtFldInfo.text = data.text.capitalized
                }
                
                
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
                
            } else {
                
                let cell: CarDetailsPopupCell
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarDetailsPopupCellId, for: indexPath) as! CarDetailsPopupCell
                
                cell.setUpTextFieldDelegate()
                
                cell.txtFldInfo.placeholder = data.placeholder
                cell.txtFldInfo.text = data.text.capitalized
                
                cell.completionBlockShouldChange = { (textField, candidateString ) in
                    return false
                }
                cell.completionBlock = { (textField, textFieldDelegateType) in
                    DispatchQueue.main.async {
                        switch textFieldDelegateType {
                        case .textFieldDidBeginEditing :
                            textField.becomeFirstResponder()
                            break;
                        case .textFieldShouldBeginEditing:
                            break;
                        case.textFieldDidEndEditing:
                            textField.resignFirstResponder()
                        default:
                            break;
                        }
                    }
                    return true
                }
                
                cell.selectionStyle = .none
                return cell
                
            }
        } else if (indexPath.section == 1) {
            
            if(indexPath.row == 0) {
                let cell: SeperatorCell
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kSeperatorCellId, for: indexPath) as! SeperatorCell
                
                cell.selectionStyle = .none
                return cell
            } else {
                let cell: CarDetailsDocumantCell
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarDetailsDocumentCellId, for: indexPath) as! CarDetailsDocumantCell
                
                let data = carDocumentTableData[indexPath.row - 1]
                
                cell.btnDrivingLicence.tag = indexPath.row - 1
                cell.btnInfo.tag = indexPath.row - 1
                cell.btnDrivingLicence.addTarget(self, action: #selector(uploadCarDocumentsTap(_:)), for: .touchUpInside)
                cell.btnInfo.addTarget(self, action: #selector(infoButtonTap(_:)), for: .touchUpInside)
                cell.lblDrivingLicence.text = data.placeholder
                
                if(data.imgurl != nil) {
                    let url = URL(string: data.imgurl)
                    if data.imgurl.count == 0 {
                        cell.imgDrivingLicence.image = nil
                        cell.btnDrivingLicence.setImage(UIImage(named: "docsIcon"), for: .normal)
                        DispatchQueue.main.async {
//                            SVProgressHUD.dismiss()
                            self.view.isUserInteractionEnabled = true
                            self.indicatorView.isHidden = true
                        }
                        
                        cell.btnDrivingLicence.isUserInteractionEnabled = true
                    } else {
                        cell.imgDrivingLicence.kf.indicatorType = .activity
                        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                        let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
                        
                        let token = "Bearer " + authToken
                        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
                        
                        Alamofire.request(url!, method: .get, headers: dictHeaderParams).responseJSON { (responseObject) -> Void in
                            debugPrint(responseObject)
                            if responseObject.data != nil{
                                cell.imgDrivingLicence.image = UIImage(data: responseObject.data!)
                                cell.imgDrivingLicence.contentMode = .scaleAspectFit
                                cell.btnDrivingLicence.setImage(UIImage(named: ""), for: .normal)
                                DispatchQueue.main.async {
//                                    SVProgressHUD.dismiss()
                                    self.view.isUserInteractionEnabled = true
                                    self.indicatorView.isHidden = true
                                }
                            }
                            else{
                                cell.imgDrivingLicence.image = UIImage(named: "")
                                cell.btnDrivingLicence.setImage(UIImage(named: "docsIcon"), for: .normal)
                                DispatchQueue.main.async {
//                                    SVProgressHUD.dismiss()
                                    self.view.isUserInteractionEnabled = true
                                    self.indicatorView.isHidden = true
                                }
                            }
                        }
                    }
                } else {
                    cell.imgDrivingLicence.image = nil
                    cell.btnDrivingLicence.setImage(UIImage(named: "docsIcon"), for: .normal)
                    self.view.isUserInteractionEnabled = true
                    self.indicatorView.isHidden = true
                }
                
                cell.selectionStyle = .none
                return cell
            }
            
        } else {
            let cell: CarImageUploadCell
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCarImageUploadCellId, for: indexPath) as! CarImageUploadCell
            
            let data = carImageTableData[indexPath.row]
            
            cell.btnFront.tag = 0
            cell.btnRear.tag = 1
            cell.btnRight.tag = 2
            cell.btnLeft.tag = 3
            
            cell.btnFront.addTarget(self, action: #selector(uploadCarImageTap(_:)), for: .touchUpInside)
            cell.btnRear.addTarget(self, action: #selector(uploadCarImageTap(_:)), for: .touchUpInside)
            cell.btnRight.addTarget(self, action: #selector(uploadCarImageTap(_:)), for: .touchUpInside)
            cell.btnLeft.addTarget(self, action: #selector(uploadCarImageTap(_:)), for: .touchUpInside)
            
            
            if(data.imgFront != nil) {
                let url = URL(string: data.imgFront)
                if data.imgFront.count == 0 {
                    cell.imgFront.image = nil
                    cell.btnFront.setImage(UIImage(named: "front_image"), for: .normal)
                    DispatchQueue.main.async {
//                        SVProgressHUD.dismiss()
                        self.view.isUserInteractionEnabled = true
                        self.indicatorView.isHidden = true
                    }
                }else{
                    cell.imgFront.kf.indicatorType = .activity
                    let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                    let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
                    
                    let token = "Bearer " + authToken
                    let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
                    
                    Alamofire.request(url!, method: .get, headers: dictHeaderParams).responseJSON { (responseObject) -> Void in
                        debugPrint(responseObject)
                        if responseObject.data != nil{
                            cell.imgFront.image = UIImage(data: responseObject.data!)
                            cell.imgFront.contentMode = .scaleAspectFit
                            cell.btnFront.setImage(UIImage(named: ""), for: .normal)
                            DispatchQueue.main.async {
//                                SVProgressHUD.dismiss()
                                self.view.isUserInteractionEnabled = true
                                self.indicatorView.isHidden = true
                            }
                        }
                        else{
                            cell.imgFront.image = UIImage(named: "")
                            cell.btnFront.setImage(UIImage(named: "front_image"), for: .normal)
                            DispatchQueue.main.async {
//                                SVProgressHUD.dismiss()
                                self.view.isUserInteractionEnabled = true
                                self.indicatorView.isHidden = true
                            }
                        }
                    }
                }
            } else {
                cell.imgFront.image = nil
                cell.btnFront.setImage(UIImage(named: "front_image"), for: .normal)
            }
            
            if(data.imgBack != nil) {
                let url = URL(string: data.imgBack)
                if data.imgBack.count == 0 {
                    cell.imgRear.image = nil
                    cell.btnRear.setImage(UIImage(named: "rear_image"), for: .normal)
                    DispatchQueue.main.async {
//                                SVProgressHUD.dismiss()
                                self.view.isUserInteractionEnabled = true
                                self.indicatorView.isHidden = true
                            }
                }else{
                    cell.imgRear.kf.indicatorType = .activity
                    let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                    let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
                    
                    let token = "Bearer " + authToken
                    let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
                    
                    Alamofire.request(url!, method: .get, headers: dictHeaderParams).responseJSON { (responseObject) -> Void in
                        debugPrint(responseObject)
                        if responseObject.data != nil{
                            cell.imgRear.image = UIImage(data: responseObject.data!)
                            cell.imgRear.contentMode = .scaleAspectFit
                            cell.btnRear.setImage(UIImage(named: ""), for: .normal)
                            DispatchQueue.main.async {
//                                SVProgressHUD.dismiss()
                                self.view.isUserInteractionEnabled = true
                                self.indicatorView.isHidden = true
                            }
                        }
                        else{
                            cell.imgRear.image = UIImage(named: "")
                            cell.btnRear.setImage(UIImage(named: "rear_image"), for: .normal)
                            DispatchQueue.main.async {
//                                SVProgressHUD.dismiss()
                                self.view.isUserInteractionEnabled = true
                                self.indicatorView.isHidden = true
                            }
                        }
                    }
                }
            } else {
                cell.imgRear.image = nil
                cell.btnRear.setImage(UIImage(named: "rear_image"), for: .normal)
                DispatchQueue.main.async {
//                    SVProgressHUD.dismiss()
                    self.view.isUserInteractionEnabled = true
                    self.indicatorView.isHidden = true
                }
            }
            
            
            if(data.imgRight != nil) {
                let url = URL(string: data.imgRight)
                if data.imgRight.count == 0 {
                    cell.imgRight.image = nil
                    cell.btnRight.setImage(UIImage(named: "left_image"), for: .normal)
                    DispatchQueue.main.async {
//                                SVProgressHUD.dismiss()
                                self.view.isUserInteractionEnabled = true
                                self.indicatorView.isHidden = true

                            }
                }else{
                    cell.imgRight.kf.indicatorType = .activity
                    let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                    let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
                    
                    let token = "Bearer " + authToken
                    let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
                    
                    Alamofire.request(url!, method: .get, headers: dictHeaderParams).responseJSON { (responseObject) -> Void in
                        debugPrint(responseObject)
                        if responseObject.data != nil{
                            cell.imgRight.image = UIImage(data: responseObject.data!)
                            cell.imgRight.contentMode = .scaleAspectFit
                            cell.btnRight.setImage(UIImage(named: ""), for: .normal)
                            DispatchQueue.main.async {
//                                SVProgressHUD.dismiss()
                                self.view.isUserInteractionEnabled = true
                                self.indicatorView.isHidden = true
                            }
                        }
                        else{
                            cell.imgRight.image = UIImage(named: "")
                            cell.btnRight.setImage(UIImage(named: "left_image"), for: .normal)
                            DispatchQueue.main.async {
//                                SVProgressHUD.dismiss()
                                self.view.isUserInteractionEnabled = true
                                self.indicatorView.isHidden = true
                            }
                        }
                    }
                }
            } else {
                cell.imgRight.image = nil
                cell.btnRight.setImage(UIImage(named: "left_image"), for: .normal)
                DispatchQueue.main.async {
//                    SVProgressHUD.dismiss()
                    self.view.isUserInteractionEnabled = true
                    self.indicatorView.isHidden = true
                }
            }
            
            
            if(data.imgLeft != nil) {
                let url = URL(string: data.imgLeft)
                if data.imgLeft.count == 0 {
                    cell.imgLeft.image = nil
                    cell.btnLeft.setImage(UIImage(named: "right_image"), for: .normal)
                    DispatchQueue.main.async {
//                        SVProgressHUD.dismiss()
                        self.view.isUserInteractionEnabled = true
                        self.indicatorView.isHidden = true
                    }
                } else {
                    cell.imgLeft.kf.indicatorType = .activity
                    let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                    let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
                    
                    let token = "Bearer " + authToken
                    let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
                    
                    Alamofire.request(url!, method: .get, headers: dictHeaderParams).responseJSON { (responseObject) -> Void in
                        debugPrint(responseObject)
                        if responseObject.data != nil{
                            cell.imgLeft.image = UIImage(data: responseObject.data!)
                            cell.imgLeft.contentMode = .scaleAspectFit
                            cell.btnLeft.setImage(UIImage(named: ""), for: .normal)
                            DispatchQueue.main.async {
//                                SVProgressHUD.dismiss()
                                self.view.isUserInteractionEnabled = true
                                self.indicatorView.isHidden = true
                            }
                        }
                        else{
                            cell.imgLeft.image = UIImage(named: "")
                            cell.btnLeft.setImage(UIImage(named: "right_image"), for: .normal)
                            DispatchQueue.main.async {
//                                SVProgressHUD.dismiss()
                                self.view.isUserInteractionEnabled = true
                                self.indicatorView.isHidden = true
                            }
                        }
                    }
                }
            } else {
                cell.imgLeft.image = nil
                cell.btnLeft.setImage(UIImage(named: "right_image"), for: .normal)
                DispatchQueue.main.async {
//                    SVProgressHUD.dismiss()
                    self.view.isUserInteractionEnabled = true
                    self.indicatorView.isHidden = true
                }
            }
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
//    func enableDisableImageUpload(enableDisable : Bool){
//        if(self.selectedCellType != "CarDocumentCell") {
//            let indexPath = IndexPath(row: 0, section: 2)
//            let cell : CarImageUploadCell = self.tableviewCarDetails.cellForRow(at: indexPath) as! CarImageUploadCell
//            cell.btnLeft.isUserInteractionEnabled = enableDisable
//            cell.btnRear.isUserInteractionEnabled = enableDisable
//            cell.btnFront.isUserInteractionEnabled = enableDisable
//            cell.btnRight.isUserInteractionEnabled = enableDisable
//        }
//
//    }
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

