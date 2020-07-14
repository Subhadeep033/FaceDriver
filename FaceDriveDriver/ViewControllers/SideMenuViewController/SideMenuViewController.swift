//
//  SideMenuViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 12/02/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Cosmos
import Kingfisher
import SVProgressHUD
import Firebase
import FirebaseDatabase
import Intercom
import Reachability
import FBSDKLoginKit
import GoogleSignIn

protocol SideMenuDelegate {
    func sideMenuRemoved(isSideMenuRemoved : Bool)
}

class SideMenuViewController: UIViewController {
    
    var sideMenuRef: DatabaseReference!
    //    fileprivate var refHandle : DatabaseHandle!
    var sideMenuObjDelegate : SideMenuDelegate?
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sideMenuTableView: UITableView!
    @IBOutlet weak var numberOfJobsDoneLabel: UILabel!
    @IBOutlet weak var distanceCoveredLabel: UILabel!
    @IBOutlet weak var onlineHoursLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverRatingView: CosmosView!
    @IBOutlet weak var driverProfileImageView: UIImageView!
    @IBOutlet weak var onlineOfflineTableView: UITableView!
    @IBOutlet weak var onlineOfflineBtn: UIButton!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    var sideMenuDataArray = [[String : String]]()
    var onlineOfflineDataArray = [String]()
    fileprivate var indexPathSelect = [IndexPath]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate var carDetailsPopup = CarDetailsPopupViewController()
    
    @IBOutlet weak var constLeadingMainView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
//        configureDatabase()
        self.mainView.frame = Utility.CGRectMake(-self.mainView.frame.size.width, self.mainView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)
        UIView.animate(withDuration: 0.44, animations: { () -> Void in
            self.mainView.frame = Utility.CGRectMake(0.0, self.mainView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)
        }, completion:nil)
        
    }
    
//    private func configureDatabase()  {
//        sideMenuRef = Database.database().reference()
//    }
    
    deinit {
        if sideMenuRef != nil{
            sideMenuRef.removeAllObservers()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.view.layoutIfNeeded()
        //self.appDelegate.isSideMenuOpen = true
        self.mainView.frame = Utility.CGRectMake(-UIScreen.main.bounds.width, mainView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)
        UIView.animate(withDuration: 0.61, animations: { () -> Void in
            self.mainView.frame = Utility.CGRectMake(0.0, self.mainView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)
            self.view.layoutIfNeeded()
        }, completion:nil)
        self.view.layoutIfNeeded()
        initialUI()
        
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(true)
//        if sideMenuRef != nil{
//            sideMenuRef.removeAllObservers()
//        }
//    }
    
    //MARK:- All Button Actions -----
    @IBAction func hideSideMenuBtnTap(_ sender: Any) {
        UIView.animate(withDuration: 0.44, animations: { () -> Void in
            
            self.mainView.frame = Utility.CGRectMake(-self.view.frame.size.width, self.mainView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)
            self.view.layoutIfNeeded()
            
        }, completion: { (finished) -> Void in
            self.sideMenuObjDelegate?.sideMenuRemoved(isSideMenuRemoved: true)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
        })
    }
    
    @IBAction func onlineOfflineStatusChangeBtnTap(_ sender: Any) {
        if self.appDelegate.isWithInTrip == false{
            onlineOfflineTableView.isHidden = !onlineOfflineTableView.isHidden
            onlineOfflineTableView.reloadData()
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kChangeCurrentStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    //MARK:- Initialize UI
    func initialUI(){
        self.currentDateLabel.text = Utility.getCurrentDate(now:Date())
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        let build = Bundle.main.infoDictionary!["CFBundleVersion"]!
        let currentEnvironment = Utility.retrieveStringFromUserDefaults(ApiKeyConstants.kUserDefaults.kCurrentEnvironment)
        self.versionLabel.text = String(format:"Version : %@.%@-%@ - 22/11/2019",version as! CVarArg,build as! CVarArg,currentEnvironment)
        let userDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        debugPrint("User=",userDict)
        self.updateAverageRating()
        
        if userDict[ApiKeyConstants.kIsApproved] as? Bool == false{
            onlineOfflineBtn.isUserInteractionEnabled = false
        } else {
            onlineOfflineBtn.isUserInteractionEnabled = true
        }
        let firstName = userDict[ApiKeyConstants.kFirst_Name] as? String ?? ""
        let lastName = userDict[ApiKeyConstants.kLast_Name] as? String ?? ""
        driverNameLabel.text = firstName + " " + lastName
        
        let urlString = userDict[ApiKeyConstants.kImage] as? String ?? ""
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)//URL(string: urlString)
        driverProfileImageView.kf.indicatorType = .activity
        driverProfileImageView.kf.setImage(with: url, placeholder: UIImage(named: "sideMenuProfile"), options: nil, progressBlock: nil) { (result) in
            
        }
        driverProfileImageView.layer.cornerRadius = driverProfileImageView.frame.width/2
        driverProfileImageView.clipsToBounds = true
        
        onlineOfflineTableView.isHidden = true
        
        sideMenuDataArray = [["keyLabel" : "My Account","imageName" : "myaccounts"],["keyLabel" : "My Trips","imageName" : "myTrips"],["keyLabel" : "My Earning","imageName" : "myEarnings"],/*["keyLabel" : "Settings","imageName" : "settings"],*/["keyLabel" : "Payout","imageName" : "payout"],["keyLabel" : "Refer & Earn","imageName" : "referEarn"],["keyLabel" : "Help","imageName" : "help"],["keyLabel" : "Contact Support","imageName" : "support"],["keyLabel" : "Legal","imageName" : "legal"],["keyLabel" : "Logout","imageName" : "logout"]]
        
        onlineOfflineDataArray = ["Online","Offline"]
        onlineOfflineDriver()
        sideMenuTableView.reloadData()
    }
    
    //MARK:- Remove Side Menu Animation----
    func removeSideMenuWithAnimation() {
        UIView.animate(withDuration: 0.44, animations: { () -> Void in
            self.mainView.frame = Utility.CGRectMake(-UIScreen.main.bounds.width, self.mainView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
    
    // MARK:- Get Driver Profile Api Call Methods-----
    func updateAverageRating() {
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        Utility.removeAppCookie()
        let averageRatingUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetAverageRating
        
        APIWrapper.requestGETURL(averageRatingUrl, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                    var resultDict : [String : Any] = dictResponse![ApiKeyConstants.kResult] as? [String : Any] ?? [:]
                    resultDict = Utility.recursiveNullRemoveFromDictionary(responseDict: resultDict)
                    var userDict : [String : Any] = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                    userDict[ApiKeyConstants.kRating] = resultDict[ApiKeyConstants.kDriverAvgRatings]
                    Utility.saveToUserDefaultsWithKeyandDictionary(userDict , key: ApiKeyConstants.kUserDefaults.kDriverDetails)
                    
                    if ((userDict[ApiKeyConstants.kRating] as? Double ?? 0.0) == 0.0){
                        self.ratingLabel.isHidden = true
                        self.driverRatingView.isHidden = true
                    }
                    else{
                        self.ratingLabel.isHidden = false
                        self.driverRatingView.isHidden = false
                        self.ratingLabel.text = NSString(format: "%.2f", userDict[ApiKeyConstants.kRating] as? Double ?? 0.0) as String
                        self.driverRatingView.rating = userDict[ApiKeyConstants.kRating] as? Double ?? 0.0
                    }
                    
                    let tripStatistics = resultDict[ApiKeyConstants.kStatistic] as? [String:Any] ?? [:]
                    self.numberOfJobsDoneLabel.text = String(format: "%d", tripStatistics[ApiKeyConstants.kTotalJobs] as? Int ?? 0)
                    self.distanceCoveredLabel.text = String(format: "%.2fKM", tripStatistics[ApiKeyConstants.kTotalDistance] as? Double ?? 0.00)
                    let hrsOnline = Int(tripStatistics[ApiKeyConstants.kHoursOnline] as? Double ?? 0)
                    var hours = Int()
                    var mins = Int()
                    if (hrsOnline == 0){
                        hours = 00
                        mins = 00
                    }
                    else{
                        hours = Int(hrsOnline/60)
                        mins = Int(hrsOnline%60)
                    }
                    if (hours < 10) && (mins < 10){
                        self.onlineHoursLabel.text = String(format: "0%d:0%d",hours,mins)
                    }
                    else if (hours < 10) && (mins > 10){
                        self.onlineHoursLabel.text = String(format: "0%d:%d",hours,mins)
                    }
                    if (hours > 10) && (mins < 10){
                        self.onlineHoursLabel.text = String(format: "%d:0%d",hours,mins)
                    }
                    else{
                        self.onlineHoursLabel.text = String(format: "%d:%.2d",hours,mins)
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
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    //MARK:- Fetch car list
    
    func fetchAddedcarList(authToken:String) {
        
        let token = "Bearer " + authToken
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
        let fetchCarListUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetAddedCarList
        
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Fetching Car List...")
        }
        
        APIWrapper.requestGETURL(fetchCarListUrl, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1) {
                    let carsArray = dictResponse![ApiKeyConstants.kResult] as? [[String:Any]] ?? []
                    if carsArray.count > 0 {
                        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                        let controller = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSelectCarStoryboardId) as! SelectCarViewController
                        controller.tableDataArr = carsArray
                        controller.isFromHome  = true
                        controller.callback    = { message in
                            let isOnlineStatus = message[ApiKeyConstants.kisOnline] as? Bool ?? false
                            self.appDelegate.selectedCarDict.removeAll()
                            self.appDelegate.selectedCarDict = message[ApiKeyConstants.CarDetails.kCarDict] as? [String:AnyObject] ?? [:]
                            self.changeDriverStatus(status: !isOnlineStatus, token: authToken)
                        }
                        self.navigationController?.present(controller, animated: true, completion: nil)
                    } else {
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNoCarAvailable, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    }
                } else {
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
    
    // MARK:- Driver Status Api Call Methods-----
    func changeDriverStatus(status:Bool, token:String) {
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        let onlineOfflineUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kOnlineOfflineStatusApi
        
        let dictBodyParams : [String : AnyObject] = [ApiKeyConstants.kStatus : status ? 0 as AnyObject : 1 as AnyObject, ApiKeyConstants.klattitude : self.appDelegate.lattitude as AnyObject, ApiKeyConstants.klongitude : self.appDelegate.longitude as AnyObject]
        
        debugPrint("Header : ",dictHeaderParams)
        debugPrint("Body : ",dictBodyParams)
        debugPrint("Url : ",onlineOfflineUrl)
        //        DispatchQueue.main.async {
        //            SVProgressHUD.setContainerView(self.view)
        //            SVProgressHUD.show(withStatus: "Loading...")
        //        }
        Utility.removeAppCookie()
        APIWrapper.requestPUTURL(onlineOfflineUrl, params: dictBodyParams as [String : AnyObject], headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            //            DispatchQueue.main.async {
            //                SVProgressHUD.dismiss()
            //            }
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        var driverDetailsDict = [String : Any]()
                        if Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
                            driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                        }
                        driverDetailsDict[ApiKeyConstants.kStatus] = dictBodyParams[ApiKeyConstants.kStatus]
                        debugPrint(driverDetailsDict)
                        Utility.saveToUserDefaultsWithKeyandDictionary(driverDetailsDict, key: ApiKeyConstants.kUserDefaults.kDriverDetails)
                        
                        self.onlineOfflineTableView.isHidden = true
                        
                        var dictResult      = [String: AnyObject]()
                        var dictRegion      = [[String : AnyObject]]()
                        var currentRegion   = [String : AnyObject]()
                        
                        if !status {
                            dictResult = (dictResponse![ApiKeyConstants.kResult] as? [String: AnyObject] ?? [:])
                            dictRegion      = (dictResult["regionInfo"] as? [[String : AnyObject]] ?? [])
                            currentRegion   = dictResult["currentRegion"] as? [String : AnyObject] ?? [:]
                            self.appDelegate.arrServices.removeAll()
                            self.appDelegate.arrServices     = (dictResult["services"] as? [[String : AnyObject]] ?? [])
                            self.appDelegate.carCurrentRegionName = currentRegion["name"] as? String ?? "NA"
                            
                            UserDefaults.standard.set(self.appDelegate.arrServices, forKey: ApiKeyConstants.kUserDefaults.kCarDetailsServices)
                            UserDefaults.standard.set(self.appDelegate.carCurrentRegionName, forKey: ApiKeyConstants.kUserDefaults.kCarDetailsRegion)
                            UserDefaults.standard.set(self.appDelegate.selectedCarDict, forKey: ApiKeyConstants.kUserDefaults.kCarDetailsDictionary)
                            
                            if(dictRegion.count > 0) {
                                self.appDelegate.dictRegionCoordinates.removeAll()
                            }
                            
                            for index in 0..<dictRegion.count {
                                let dictGeometry = (dictRegion[index]["geometry"]) as? [String: AnyObject] ?? [:]
                                
                                let polygonCords = dictGeometry["coordinates"] as? [[AnyObject]] ?? [[]]
                                let arrPloygonCOrds = polygonCords[0]
                                
                                print("Cords ------------- ", arrPloygonCOrds)
                                self.appDelegate.dictRegionCoordinates.append(arrPloygonCOrds)
                            }
                            
                            if self.appDelegate.dictRegionCoordinates.count > 0{
                                UserDefaults.standard.set(self.appDelegate.dictRegionCoordinates, forKey: ApiKeyConstants.kUserDefaults.kRegionCord)
                            }
                            debugPrint("Cord =",self.appDelegate.dictRegionCoordinates)
                            let tokenId = driverDetailsDict[ApiKeyConstants.kid] as? String ?? ""
                            self.updateFirebaseDb(status: 1, authToken: tokenId)
                        }
                        
                        self.onlineOfflineDriver()
                        
                        if !status {
                            
                            if(self.appDelegate.selectedCarDict.count > 0) {
                                
                                let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                                self.carDetailsPopup = storyBoard.instantiateViewController(withIdentifier: "CarDetailsPopupViewController") as! CarDetailsPopupViewController
                                self.carDetailsPopup.tableServicesDataArr    = self.appDelegate.arrServices
                                self.carDetailsPopup.carColor                = (self.appDelegate.selectedCarDict[ApiKeyConstants.CarDetails.kColor] as? String ?? "").capitalized
                                self.carDetailsPopup.carName                 = self.appDelegate.selectedCarDict[ApiKeyConstants.CarDetails.kModel] as? String ?? ""
                                self.carDetailsPopup.carManufractureName     = self.appDelegate.selectedCarDict[ApiKeyConstants.CarDetails.kManufacturer] as? String ?? ""
                                self.carDetailsPopup.plateNumber             = (self.appDelegate.selectedCarDict[ApiKeyConstants.CarDetails.kLicensePlateNo] as? String ?? "").uppercased()
                                if Utility.isEqualtoString(self.appDelegate.carCurrentRegionName, "NA"){
                                    self.carDetailsPopup.regionName = self.appDelegate.carCurrentRegionName
                                }
                                else{
                                    self.carDetailsPopup.regionName = self.appDelegate.carCurrentRegionName.capitalized
                                }
                                //self.appDelegate.serviceTypePopup = true
                                
                                self.carDetailsPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                                self.present(self.carDetailsPopup, animated: true, completion: nil)
                            }
                        }
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
    
    //MARK:- Online/Offline Driver -----
    func onlineOfflineDriver(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let status = driverDetailsDict[ApiKeyConstants.kStatus] as? Int ?? 0
        
        if status == 1{
            self.appDelegate.arrServices.removeAll()
            self.appDelegate.arrServices = UserDefaults.standard.array(forKey: ApiKeyConstants.kUserDefaults.kCarDetailsServices) as? [[String : AnyObject]] ?? []
            self.appDelegate.selectedCarDict.removeAll()
            self.appDelegate.selectedCarDict = UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kCarDetailsDictionary) as? [String : AnyObject] ?? [:]
            
            self.appDelegate.carCurrentRegionName = UserDefaults.standard.value(forKey: ApiKeyConstants.kUserDefaults.kCarDetailsRegion) as? String ?? "NA"
            
            onlineOfflineBtn.setImage(UIImage(named: "online"), for: .normal)
            
            if indexPathSelect.count > 0{
                indexPathSelect.remove(at: 0)
                let indexPath = IndexPath(row: 0, section: 0)
                indexPathSelect.insert(indexPath, at: 0)
                debugPrint(indexPathSelect)
                onlineOfflineTableView.reloadData()
            }
            else{
                let indexPath = IndexPath(row: 0, section: 0)
                indexPathSelect.insert(indexPath, at: 0)
                debugPrint(indexPathSelect)
                onlineOfflineTableView.reloadData()
            }
        }
        else{
            onlineOfflineBtn.setImage(UIImage(named: "offline"), for: .normal)
            if indexPathSelect.count > 0{
                indexPathSelect.remove(at: 0)
                let indexPath = IndexPath(row: 1, section: 0)
                indexPathSelect.insert(indexPath, at: 0)
                debugPrint(indexPathSelect)
                onlineOfflineTableView.reloadData()
            }
            else{
                let indexPath = IndexPath(row: 1, section: 0)
                indexPathSelect.insert(indexPath, at: 0)
                debugPrint(indexPathSelect)
                onlineOfflineTableView.reloadData()
            }
        }
        let tokenId = driverDetailsDict[ApiKeyConstants.kid] as? String ?? ""
        self.updateFirebaseDb(status: status, authToken: tokenId)
    }
}

//MARK:- TableView Delegate & Datasource Method ------
extension SideMenuViewController : UITableViewDelegate,UITableViewDataSource{
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == onlineOfflineTableView){
            return onlineOfflineTableView.frame.height/CGFloat(onlineOfflineDataArray.count)
        }
        else{
            return 50 //sideMenuTableView.frame.height/CGFloat(sideMenuDataArray.count)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == onlineOfflineTableView){
            return onlineOfflineDataArray.count
        }
        else{
            return sideMenuDataArray.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == onlineOfflineTableView){
            let onlineOfflineCell : OnlineOfflineTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kOnlineOfflineCellId) as! OnlineOfflineTableViewCell
            
            onlineOfflineCell.selectImageView.image = UIImage(named:"")
            onlineOfflineCell.statusLabel.text =  onlineOfflineDataArray[indexPath.row]
            onlineOfflineCell.statusLabel.alpha = 0.5
            debugPrint ("index=",indexPathSelect.count)
            if indexPathSelect.count > 0{
                let result = indexPathSelect.filter { $0==indexPath }
                if result.count > 0{
                    onlineOfflineCell.selectImageView.image =  UIImage(named:"checkTick")
                    onlineOfflineCell.statusLabel.alpha = 1.0
                }
                else{
                    onlineOfflineCell.selectImageView.image = UIImage(named:"")
                }
            }
            
            if indexPath.row == onlineOfflineDataArray.count-1{
                onlineOfflineCell.separatorInset = .zero
                
            }
            return onlineOfflineCell
        }
        else{
            let sideMenuCell : SideMenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kSideMenuCellId) as! SideMenuTableViewCell
            
            sideMenuCell.sideMenuCellImageView.image = UIImage(named: sideMenuDataArray[indexPath.row]["imageName"]!)
            
            sideMenuCell.sideMenuCellLabel.text =  sideMenuDataArray[indexPath.row]["keyLabel"]!
            if indexPath.row == sideMenuDataArray.count-1{
                sideMenuCell.separatorInset = .zero
            }
            return sideMenuCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == onlineOfflineTableView){
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            //            let currentStatus = driverDetailsDict![ApiKeyConstants.kStatus] as! Bool
            let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
            debugPrint(indexPathSelect)
            if indexPathSelect.count > 0{
                let result = indexPathSelect.filter { $0==indexPath }
                debugPrint(result)
                if result.count > 0{
                    //                    indexPathSelect.remove(at: 0)
                }
                else{
                    indexPathSelect.remove(at: 0)
                    debugPrint(indexPathSelect)
                    indexPathSelect.insert(indexPath, at: 0)
                    debugPrint(indexPathSelect)
                    if indexPath.row == 0{
                        //online----
                        if(Reachibility.isConnectedToNetwork()){
                            //self.changeDriverStatus(status: true, token: authToken)
                            let stripeCustomerId = driverDetailsDict["stripeCustomerId"] as? String ?? ""
                            
                                if Utility.isEqualtoString(stripeCustomerId, ""){
                                    let addBankAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNoBankAccountAdded, preferredStyle: .alert)
                                    addBankAlert.view.tintColor = Constants.AppColour.kAppGreenColor
                                    let actionYes = UIAlertAction(title: Constants.AppAlertAction.kAddBank, style: .default) { (action) in
                                        self.dismiss(animated: true, completion: nil)
                                        let storyBoard = UIStoryboard.init(name: "EarningsAndTrips", bundle: Bundle.main)
                                        let referEarnVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kPayoutDetailsView) as! PayoutDetailsViewController
                                        
                                        self.show(referEarnVC, sender: self)
                                    }
                                    let actionCancel = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default) { (action) in
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    addBankAlert.addAction(actionCancel)
                                    addBankAlert.addAction(actionYes)
                                    self.present(addBankAlert, animated: true, completion: nil)
                                    
                                }
                                else{
                                    self.fetchAddedcarList(authToken: authToken)
                                }
                            
                        }
                        else{
                            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
                        }
                    }
                    else{
                        //   offline ----
                        if(Reachibility.isConnectedToNetwork()){
                            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                            let currentStatus = driverDetailsDict[ApiKeyConstants.kStatus] as? Bool ?? false
                            let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
                            
                            let offlineAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kGoOffline, preferredStyle: .alert)
                            offlineAlert.view.tintColor = Constants.AppColour.kAppGreenColor
                            let actionYes = UIAlertAction(title: Constants.AppAlertAction.kYESButton, style: .default) { (action) in
                                self.dismiss(animated: true, completion: nil)
                                self.changeDriverStatus(status: currentStatus, token: authToken)
                            }
                            let actionCancel = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default) { (action) in
                                self.dismiss(animated: true, completion: nil)
                            }
                            offlineAlert.addAction(actionCancel)
                            offlineAlert.addAction(actionYes)
                            self.present(offlineAlert, animated: true, completion: nil)
                        }
                        else{
                            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
                        }
                    }
                }
            }
            else{
                indexPathSelect.insert(indexPath, at: 0)
                debugPrint(indexPathSelect)
            }
            onlineOfflineTableView.reloadData()
        }
        else{
            switch indexPath.row{
            case 0:
                removeSideMenuWithAnimation()
                goToProfile()
                break
                
            case 1:
                //  My Trips :
                removeSideMenuWithAnimation()
                goToMyTripss()
                break
                
            case 2:
                 //  My Earnings :
                 removeSideMenuWithAnimation()
                 goToMyEarnings()
                 break
                 
                 /*case 3:
                 //  Settings :
                 break
                 */
            case 3:
                //   Payout :
                removeSideMenuWithAnimation()
                goToPayout()
                break
                
            case 4:
                //  Refer & Earn :
                removeSideMenuWithAnimation()
                goToReferEarn()
                break
                
            case 5:
                //  Help :
                
                // register in itercome
                if Utility.isEqualtoString(Utility.retrieveStringFromUserDefaults("IntercomlogedIn"), "1") {
                    Utility.updateInterComUser()
                    Intercom.presentMessenger()
                } else {
                    Utility.RegisterInIntercom()
                    Intercom.presentMessenger()
                }
                break
            case 6:
                //  Support :
                self.callNumber(phoneNumber: Constants.AppAlertAction.kPhoneNumber)
                break
            case 7:
                //  Legal :
                removeSideMenuWithAnimation()
                goToLegal()
                break
            
            default:
                debugPrint("Logout")
                if self.appDelegate.isWithInTrip == false{
                    let logoutAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kLogoutPemission, preferredStyle: .alert)
                    logoutAlert.view.tintColor = Constants.AppColour.kAppGreenColor
                    let ok = UIAlertAction(title: Constants.AppAlertAction.kYESButton, style: .default) { (action) in
                        //     Logout Api call.
                        if(Reachibility.isConnectedToNetwork()){
                            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                            let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
                                self.logoutApiCalled(token: authToken,isForceLogout:false)
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
                    break
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kLogoutPermission, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            }
        }
    }
    
    //MARK:- Support Call
    
    func callNumber(phoneNumber:String) {
        
        let addBankAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertSupportCallTitle, message: Constants.AppAlertMessage.kSupportCallMessage, preferredStyle: .alert)
        addBankAlert.view.tintColor = Constants.AppColour.kAppGreenColor
        
        let actionYes = UIAlertAction(title: Constants.AppAlertAction.kCall, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
            
            if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {

              let application:UIApplication = UIApplication.shared
              if (application.canOpenURL(phoneCallURL)) {
                  application.open(phoneCallURL, options: [:], completionHandler: nil)
              }
            }
        }
        let actionCancel = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        addBankAlert.addAction(actionCancel)
        addBankAlert.addAction(actionYes)
        self.present(addBankAlert, animated: true, completion: nil)

    }
    
    //MARK:- Firebase Update Method ----
    func updateFirebaseDb(status:Int, authToken:String ){
        debugPrint("SideMenu updateFirebaseDb")
        if sideMenuRef == nil{
            sideMenuRef = Database.database().reference()
        }
        debugPrint("Lat=",appDelegate.lattitude)
        debugPrint("Lon=",appDelegate.longitude)
    self.sideMenuRef.child(ApiKeyConstants.kFirebaseTableName).child(authToken).child(ApiKeyConstants.kisOnline).setValue(status)
    self.sideMenuRef.child(ApiKeyConstants.kFirebaseTableName).child(authToken).child(ApiKeyConstants.klattitude).setValue(self.appDelegate.lattitude)
    self.sideMenuRef.child(ApiKeyConstants.kFirebaseTableName).child(authToken).child(ApiKeyConstants.klongitude).setValue(self.appDelegate.longitude)
        
    self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(authToken).child(ApiKeyConstants.ktimeStamp).setValue(Utility.currentTimeInMiliseconds())
    }
    
    //MARK:- Navigation To Different VC ----
    func goToMyTripss(){
        let storyBoard = UIStoryboard.init(name: "EarningsAndTrips", bundle: Bundle.main)
        let earningsVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kMyTripsStoryboardId) as! MyTripsViewController
        
        self.show(earningsVC, sender: self)
    }
    func goToMyEarnings(){
        let storyBoard = UIStoryboard.init(name: "EarningsAndTrips", bundle: Bundle.main)
        let earningsVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kDriverEarningsStoryboardId) as! DriverEarningsViewController
        
        self.show(earningsVC, sender: self)
    }
    func goToLegal(){
        let storyBoard = UIStoryboard.init(name: "EarningsAndTrips", bundle: Bundle.main)
        let earningsVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kLegalStoryboardId) as! LegalViewController
        
        self.show(earningsVC, sender: self)
    }
    func goToProfile(){
        let storyBoard = UIStoryboard.init(name: "Profile", bundle: Bundle.main)
        let profileVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kMyAccountStoryboardId) as! MyAccountViewController
        
        self.show(profileVC, sender: self)
    }
    func goToReferEarn(){
        let storyBoard = UIStoryboard.init(name: "EarningsAndTrips", bundle: Bundle.main)
        let referEarnVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kReferEarnStoryboardId) as! ReferEarnViewController
        
        self.show(referEarnVC, sender: self)
    }
    func goToPayout(){
        let storyBoard = UIStoryboard.init(name: "EarningsAndTrips", bundle: Bundle.main)
        let referEarnVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kDriverPayoutStoryboardId) as! DriverPayoutViewController
        
        self.show(referEarnVC, sender: self)
    }
    
    //MARK:- Logout Api Calling ----
    func logoutApiCalled(token:String, isForceLogout:Bool){
        let authToken = "Bearer " + token
        let deviceToken = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDeviceToken)
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        let dictBodyParam:[String : String] = [ApiKeyConstants.kDeviceToken : deviceToken?[ApiKeyConstants.kUserDefaults.DeviceToken] as? String ?? ""]
        var logoutUrl = String()
        if (isForceLogout){
            logoutUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kForceLogoutApi
        }
        else{
            logoutUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kLogoutApi
        }
        
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Logging Out...")
        }
        
        APIWrapper.requestPOSTURL(logoutUrl, params: dictBodyParam, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                    self.removeFirebaseObserver { (success) -> Void in
                        if success {
                            let initialController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kInitialViewStoryBoardId) as! InitialViewController
                            let navigationController = UINavigationController(rootViewController: initialController)
                            navigationController.isNavigationBarHidden = true
                            self.appDelegate.window?.rootViewController = navigationController
                        }
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
            debugPrint("Error :",error)
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
        
    }
    
    func removeFirebaseObserver(completion: (_ success: Bool) -> Void) {
        let bookingsPopups = BookingRequestPopups.instanceFromNib(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 190))
        if(self.appDelegate.isWithInTrip == true){
            self.appDelegate.isWithInTrip = false
            self.appDelegate.stopSound()
            self.appDelegate.isNewRequestNotificationFired = false
            self.appDelegate.isScheduleRequestNotificationFired = false
            self.appDelegate.bookingPopUpCount = 0
            Utility.saveStringInUserDefaults("0", key: ApiKeyConstants.kUserDefaults.kWithInTrip)
            bookingsPopups.timer?.invalidate()
            bookingsPopups.dismiss(animated: true)
        }
        if (bookingsPopups.bookingRef != nil) {
            bookingsPopups.bookingRef.removeAllObservers()
        }
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logOut()
        GIDSignIn.sharedInstance().signOut()
        Utility.removeAllObserversWhenLogout()
        Utility.saveStringInUserDefaults("0", key: ApiKeyConstants.kUserDefaults.kIntercomLogin)
        Utility.removeFromUserDefaultsWithKeyandDictionary(ApiKeyConstants.kUserDefaults.kRegionCord)
        Utility.removeFromUserDefaultsWithKeyandDictionary(ApiKeyConstants.kUserDefaults.kDriverDetails)
        Utility.removeFromUserDefaultsWithKeyandDictionary(ApiKeyConstants.kUserDefaults.kWelcomeMessage)
    
        Utility.removeFromUserDefaultsWithKeyandDictionary(ApiKeyConstants.kUserDefaults.kInfoMessage)
        //Utility.removeFromUserDefaultsWithKeyandDictionary(ApiKeyConstants.kUserDefaults.kDeviceToken)
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kMapType) != nil{
            UserDefaults.standard.removeObject(forKey: ApiKeyConstants.kUserDefaults.kMapType)
        }
        Database.database().reference().removeAllObservers()
        if sideMenuRef != nil{
            sideMenuRef.removeAllObservers()
        }
        let storyBoard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
        let homeVc = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kHomeStoryboardId) as! HomeViewController
        homeVc.locationManager.stopUpdatingLocation()
        Utility.removeAppCookie()
        self.removeSideMenuWithAnimation()
        
        self.appDelegate.bookingPopUpCount = 0
        debugPrint("Driver Dict",Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:])

        completion(true)
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
