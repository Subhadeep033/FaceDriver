//
//  AddNewCarPageViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 5/2/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Reachability
import SVProgressHUD


class AddCarTabData : Codable {
    let cellType : String!
    let placeholder : String!
    let id : String!
    var counter : String!
    var isSelected : String!
}

class AddNewCarPageViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionViewTab: UICollectionView!
    fileprivate var addCarTabTableData = [AddCarTabData]()
    
    public lazy var pageViewController: PageViewController = { [unowned self] in
        
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        
        var cars = [[String:Any]]()
        
        if (driverDetailsDict["cars"] as? [[String : Any]] != nil){
            cars = driverDetailsDict["cars"] as? [[String : Any]] ?? []
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
        
        let controller1 = UIStoryboard.init(name: "DriverInfo", bundle: nil).instantiateViewController(withIdentifier: "AddNewCarConditionViewController") as! AddNewCarConditionViewController
        controller1.isFromPageView = true
        
        let controller2 = UIStoryboard(name: "Profile", bundle: nil) .
            instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kCarDetailsStoryboardId) as! CarDetailsViewController
        
        if(cars.count > 0) {
            controller2.carDetails = cars[0] as [String:Any]
            controller2.isFromAddCar = false
        } else {
            controller2.isFromAddCar = true
        }
        controller2.isFromPageView = true
        
        let controller3 = UIStoryboard(name: "Profile", bundle: nil) .
            instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kUploadDriverDocumentsStoryboardId) as! UploadDrivingLicenceViewController
        
        controller3.isDriverDocuments = true
        
        var documents = [[String:Any]]()
        
        if (driverDetailsDict["personal_docs"] as? [[String : Any]] != nil){
            documents = driverDetailsDict["personal_docs"] as? [[String : Any]] ?? []
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
        
        if documents.count > 0{
            controller3.personalDetails = driverDetailsDict["personal_docs"] as? [[String : Any]] ?? []
        }
        else{
            controller3.personalDetails = []
        }
        
        controller3.isFromPageView = true
        
        let controller4 = UIStoryboard(name: "Profile", bundle: nil) .
            instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kProfileStoryboardId) as! ProfileViewController
        controller4.isFromPageView = true
        
        let controller5 = UIStoryboard(name: "DriverInfo", bundle: nil) .
            instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kStatusStoryBoardId) as! StatusViewController
        controller5.isFromPageView = true
        
        let controller = PageViewController(controllers: [controller1, controller2, controller3, controller4, controller5], interPageSpacing: 0)
        
        controller.isScrollEnabled = false
        return controller
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: NSNotification.Name(rawValue: "load"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadListDocuments(notification:)), name: NSNotification.Name(rawValue: "loadDocuments"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadProfile(notification:)), name: NSNotification.Name(rawValue: "loadProfile"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadStatus(notification:)), name: NSNotification.Name(rawValue: "loadStatus"), object: nil)
        self.getDriverProfieDetails()
    }
    
    @objc func loadList(notification: NSNotification){
        
        let data = addCarTabTableData[0]
        data.isSelected = "false"
        let data1 = addCarTabTableData[1]
        data1.isSelected = "true"
        addCarTabTableData[0] = data
        addCarTabTableData[1] = data1
        let indexPath = IndexPath(item: 1, section: 0)
        self.collectionViewTab.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        self.collectionViewTab.reloadData()
    }
    
    @objc func loadListDocuments(notification: NSNotification){
        
        let data = addCarTabTableData[1]
        data.isSelected = "false"
        let data1 = addCarTabTableData[2]
        data1.isSelected = "true"
        addCarTabTableData[1] = data
        addCarTabTableData[2] = data1
        let indexPath = IndexPath(item: 2, section: 0)
        self.collectionViewTab.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        self.collectionViewTab.reloadData()
    }
    
    @objc func loadProfile(notification: NSNotification){
        
        let data = addCarTabTableData[2]
        data.isSelected = "false"
        let data1 = addCarTabTableData[3]
        data1.isSelected = "true"
        addCarTabTableData[2] = data
        addCarTabTableData[3] = data1
        let indexPath = IndexPath(item: 3, section: 0)
        self.collectionViewTab.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        self.collectionViewTab.reloadData()
    }
    
    @objc func loadStatus(notification: NSNotification){
        
        let data = addCarTabTableData[3]
        data.isSelected = "false"
        let data1 = addCarTabTableData[4]
        data1.isSelected = "true"
        addCarTabTableData[3] = data
        addCarTabTableData[4] = data1
        let indexPath = IndexPath(item: 4, section: 0)
        self.collectionViewTab.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        self.collectionViewTab.reloadData()
    }
    
    //MARK:- Get Driver Profile ------
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
                        
                        do {
                            let assetData = try Data(contentsOf: Bundle.main.url(forResource: "NewCarAddTab", withExtension: ".json")!)
                            self.addCarTabTableData = try JSONDecoder().decode([AddCarTabData].self, from: (assetData))
                            
                            self.collectionViewTab.reloadData()
                            
                            self.pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.containerView.bounds.size.width, height: self.containerView.bounds.size.height)
                            self.addChild(self.pageViewController)
                            self.containerView.addSubview(self.pageViewController.view)
                            self.pageViewController.didScrollToIndex = { index in
                                //print("didScrollToIndex = \(index)")
                            }
                            
                            self.checkPTCStatus()
                            
                        } catch {
                            print(error)
                        }
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
    
    @IBAction func submitButtonTap(_ sender: UIButton) {
        
    }
    
    //MARK:- Logout Button Action ----
    @IBAction func logoutButtonTap(_ sender: Any) {
        let logoutAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kLogoutPemission, preferredStyle: .alert)
        logoutAlert.view.tintColor = Constants.AppColour.kAppGreenColor
        let ok = UIAlertAction(title: Constants.AppAlertAction.kYESButton, style: .default) { (action) in
            //     Logout Api call.
            if(Reachibility.isConnectedToNetwork()){
                let driverDetailsDict : [String : Any] = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                let storyBoard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
                let menuVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSideMenuStoryboardId) as! SideMenuViewController
                menuVC.logoutApiCalled(token: driverDetailsDict[ApiKeyConstants.kToken] as? String ?? "",isForceLogout:false)

            }
            else{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
            
        }
        let cancel = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        logoutAlert.addAction(cancel)
        logoutAlert.addAction(ok)
        self.present(logoutAlert, animated: true, completion: nil)
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
    
    func checkPTCStatus(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let ptcStatus = driverDetailsDict[ApiKeyConstants.kUserDefaults.kPTCStatus] as? String ?? ""
        
        switch ptcStatus {
            
        case ApiKeyConstants.PTCStatus.kForReview:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kReviewStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kEConsentSent:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.eConsentStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kAbstractReady:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kAbstractReadyStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kFingerPrintsRequired:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kFingerprintsRequiredStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kAbstractRejected:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kAbstractRejectedStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kPTCPending,ApiKeyConstants.PTCStatus.kPTCSubmissionReady:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kPTCSubmissionReadyStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kOrientationReady:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kOrientationReadyStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kHamiltonWaitingList:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kWaitingListHamilton, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        default:
            //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kDefaultPTCMessage, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
        }
    }
}

//MARK:- CollectionViewDataSource ------
extension AddNewCarPageViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return addCarTabTableData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = addCarTabTableData[indexPath.item]
        
        let cell:NewCarTabCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewCarTabCell", for: indexPath) as! NewCarTabCell
        
        cell.lblHeader.text = data.placeholder
        
        if(data.isSelected == "true") {
            cell.lblSelector.isHidden = false
            cell.lblHeader.textColor = Constants.AppColour.kAppGreenColor
        } else {
            cell.lblSelector.isHidden = true
            cell.lblHeader.textColor = Constants.AppColour.kAppLightBlackColor
        }
        
        return cell
    }
    
}

//MARK:- CollectionView Delegate ----
extension AddNewCarPageViewController:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        let data = addCarTabTableData[indexPath.item]
        
        _ = addCarTabTableData.map({
            if($0.id == data.id) {
                $0.isSelected = "true"
            } else {
                $0.isSelected = "false"
            }
        })
        
        collectionViewTab.reloadData()
        self.pageViewController.scrollToIndex(index: indexPath.item)
    }
    
}
extension AddNewCarPageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width:(collectionView.frame.size.width-3)/3, height: 50)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

