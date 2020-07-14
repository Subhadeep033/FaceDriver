//
//  MyTripsViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 13/03/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON
import Reachability

class MyTripsCell : UITableViewCell{
    
    @IBOutlet weak var dropLabel: UILabel!
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var paymentModeLabel: UILabel!
    @IBOutlet weak var tripDateLabel: UILabel!
    @IBOutlet weak var tripCostLabel: UILabel!
    @IBOutlet weak var riderNameLabel: UILabel!
    @IBOutlet weak var riderImageView: UIImageView!
    @IBOutlet weak var baseView: UIView!
}
class MyTripsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var noTripsView: UIView!
    @IBOutlet weak var tripHistoryTableView: UITableView!
    @IBOutlet weak var totalTripsLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var totalEarningsLabel: UILabel!
    @IBOutlet weak var weekDateLabel: UILabel!
    
    var pageNumber = 1
    var tripDetailsArr = [[String:Any]]()
    var totalRecords = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        self.weekDateLabel.text = String(format:"%@ - %@",Utility.getCurrentDate(now: Date().startOfWeek!),Utility.getCurrentDate(now: Date().endOfWeek!))
        tripHistoryApiCalled(pageNo: pageNumber)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:- TableView Delegate & DataSource ----
    func numberOfSections(in tableView: UITableView) -> Int {
        if tripDetailsArr.count > 0{
            return 1
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripDetailsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tripHistoryCell : MyTripsCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kMyTripsCell) as! MyTripsCell
        let currentDict = tripDetailsArr[indexPath.row]
        debugPrint(currentDict)
        
        let riderDetails : [String:Any] = currentDict[ApiKeyConstants.kRider] as? [String : Any] ?? [:]
        let fareDetails : [String:Any] = currentDict[ApiKeyConstants.kTrip_Fare] as? [String : Any] ?? [:]
        let driverPayout : [String:Any] = fareDetails[ApiKeyConstants.kDriverPayment] as? [String : Any] ?? [:]
        let url = URL(string: riderDetails[ApiKeyConstants.kImage] as? String ?? "")
        
        tripHistoryCell.riderImageView.kf.indicatorType = .activity
        tripHistoryCell.riderImageView.kf.setImage(with: url, placeholder: UIImage(named: "profileImagePlaceholder"), options: nil, progressBlock: nil) { (result) in
            tripHistoryCell.riderImageView.layer.cornerRadius = tripHistoryCell.riderImageView.frame.height/2
            tripHistoryCell.riderImageView.clipsToBounds = true
        }
        
        tripHistoryCell.riderNameLabel.text = (riderDetails[ApiKeyConstants.kDriverName] as? String ?? "").capitalized
        tripHistoryCell.riderNameLabel.font = UIFont(name: "Roboto-Bold", size:15)
        tripHistoryCell.tripDateLabel.text = Utility.convertTimeStampToDateTime(timeStamp: currentDict[ApiKeyConstants.kBookingDateTime] as? Double ?? 0.0)
        tripHistoryCell.tripDateLabel.font = UIFont(name: "Roboto-Light", size:12)
        let totalFare : Double = driverPayout[ApiKeyConstants.kFinalPayment] as? Double ?? 0.00
        tripHistoryCell.tripCostLabel.text = String(format: "$ %.2f", totalFare)
        tripHistoryCell.tripCostLabel.font = UIFont(name: "Roboto-Bold", size:15)
        
        if (Utility.isEqualtoString(currentDict[ApiKeyConstants.kStatus] as? String ?? "", "drivercanceled")){
            tripHistoryCell.paymentModeLabel.text = "Driver Cancelled"
            tripHistoryCell.paymentModeLabel.font = UIFont(name: "Roboto-Light", size:14)
            tripHistoryCell.paymentModeLabel.textColor = Constants.AppColour.kAppLightRedColor
        }
        else if (Utility.isEqualtoString(currentDict[ApiKeyConstants.kStatus] as? String ?? "", "canceled")){
            tripHistoryCell.paymentModeLabel.text = "Rider Cancelled"
            tripHistoryCell.paymentModeLabel.font = UIFont(name: "Roboto-Light", size:14)
            tripHistoryCell.paymentModeLabel.textColor = Constants.AppColour.kAppLightRedColor
        }
        else{
            tripHistoryCell.paymentModeLabel.text = String(format: "%.2f km", currentDict[ApiKeyConstants.kDistanceInKM] as? Double ?? 0.0)
            tripHistoryCell.paymentModeLabel.font = UIFont(name: "Roboto-Medium", size:14)
            tripHistoryCell.paymentModeLabel.textColor = Constants.AppColour.kAppBlackColor
        }
        
        tripHistoryCell.pickupLabel.text = (currentDict[ApiKeyConstants.kRiderPick_up_address] as? String ?? "")
        tripHistoryCell.pickupLabel.font = UIFont(name: "Roboto-Bold", size:12)
        tripHistoryCell.dropLabel.text = (currentDict[ApiKeyConstants.kRiderDrop_Address] as? String ?? "")
        tripHistoryCell.dropLabel.font = UIFont(name: "Roboto-Bold", size:12)
        tripHistoryCell.baseView.layer.borderColor = Constants.AppColour.kAppLightGreyColor.cgColor
        tripHistoryCell.baseView.layer.borderWidth = 1.5
        tripHistoryCell.baseView.layer.cornerRadius = 7.0
        tripHistoryCell.baseView.clipsToBounds = true
        debugPrint("Records=",totalRecords)
        
        return tripHistoryCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tripDetailsArr.count > 0{
            if (self.totalRecords != tripDetailsArr.count){
                if (indexPath.row == tripDetailsArr.count - 1) {
                    // print("this is the last cell")
                    let spinner = UIActivityIndicatorView(style: .whiteLarge)
                    spinner.startAnimating()
                    spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
                    spinner.color = Constants.AppColour.kAppGreenColor
                    self.tripHistoryTableView.tableFooterView = spinner
                    self.tripHistoryTableView.tableFooterView?.isHidden = false
                    pageNumber = pageNumber + 1
                    self.tripHistoryApiCalled(pageNo: pageNumber)
                }
                else{
                    self.tripHistoryTableView.tableFooterView?.isHidden = true
                }
            }
            else{
                self.tripHistoryTableView.tableFooterView?.isHidden = true
            }
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tripDetails = tripDetailsArr[indexPath.row]
        goToTripDetails(tripDetails: tripDetails)
    }
    
    // MARK:- Navigate To Trip Details Methods-----
    func goToTripDetails(tripDetails : [String : Any]){
        let storyBoard = UIStoryboard.init(name: "EarningsAndTrips", bundle: Bundle.main)
        let tripDetailsVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kMyTripsStoryboardDetailsId) as! MyTripsDetailsViewController
        tripDetailsVC.tripDetailsDict = tripDetails
        self.show(tripDetailsVC, sender: self)
    }
    
    // MARK:- Trip History Api Call Methods-----
    func tripHistoryApiCalled(pageNo:Int){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let token = "Bearer " + authToken
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
        let dictBodyParams:[String:String] = [ApiKeyConstants.kStart_Date : Utility.getCurrentDateInFormattedString(now:Date().startOfWeek!),ApiKeyConstants.kEnd_Date : Utility.getCurrentDateInFormattedString(now:Date().endOfWeek!)]
        let pageSize = 10
        let pageCount = "page=\(pageNo)&pageSize=\(pageSize)"
        let tripHistoryUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kTripHistory + pageCount
        debugPrint("Url = ",tripHistoryUrl)
        if pageNo == 1{
            DispatchQueue.main.async {
                SVProgressHUD.setContainerView(self.view)
                SVProgressHUD.show(withStatus: "Fetching Trip Details...")
            }
        }
        
        Utility.removeAppCookie()
        APIWrapper.requestPUTURL(tripHistoryUrl, params: dictBodyParams as [String : AnyObject], headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            if pageNo == 1{
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
            
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
//                    dictResponse = Utility.recursiveNullRemoveFromDictionary(responseDict: dictResponse!)
                        debugPrint(dictResponse!)
                        let infoDict : [String:Any] = dictResponse![ApiKeyConstants.kInfo] as? [String : Any] ?? [:]
                        self.totalEarningsLabel.text = String(format: "$ %.2f", infoDict[ApiKeyConstants.kTotal_Earns] as? Double ?? 0.0)
                        self.totalTripsLabel.text = "\(infoDict[ApiKeyConstants.kTotal_Trips] as? Int ?? 0)"
                        let tripTime = (infoDict[ApiKeyConstants.kTotal_Mins] as? Int ?? 0)
                        if tripTime == 0{
                            self.totalTimeLabel.text = "0h 0m"
                        }
                        else{
                            if tripTime >= 60{
                                let hrs = tripTime/60
                                let mins = tripTime%60
                                self.totalTimeLabel.text = "\(hrs)h \(mins)m"
                            }
                            else{
                                self.totalTimeLabel.text = "0h \(tripTime)m"
                            }
                        }
                        //let totalTrips : Int = (infoDict[ApiKeyConstants.kTotal_Trips] as? Int ?? 0)
                    
                        //if (totalTrips > 0) {
                        let tripsArr = dictResponse![ApiKeyConstants.kResult] as? [[String : Any]] ?? []
                        debugPrint("Trips=",tripsArr.count )
                        if (tripsArr.count > 0){
                            for dict in tripsArr{
                                self.tripDetailsArr.append(dict)
                            }
                            self.noTripsView.isHidden = true
                        }
                        else{
                            self.noTripsView.isHidden = false
                        }
                        
                        let paginationDict : [String:Any] = dictResponse!["pagination"] as? [String : Any] ?? [:]
                        self.totalRecords = paginationDict["total"] as? Int ?? 0
                        self.tripHistoryTableView.reloadData()
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
            if pageNo == 1{
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
            debugPrint("Error :",error)
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
