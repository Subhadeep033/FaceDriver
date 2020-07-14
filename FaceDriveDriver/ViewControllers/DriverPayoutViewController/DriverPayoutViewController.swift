//
//  DriverPayoutViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 04/05/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Reachability
import SwiftyJSON
import SVProgressHUD
import Alamofire

class DriverPayoutViewController: UIViewController {

    @IBOutlet weak var noAccountView: UIView!
    @IBOutlet weak var driverPayoutTable: UITableView!
    @IBOutlet weak var addDriverDetailsButton: UIButton!
    var bankDetailsArr = [[String : Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getAllDriverAccountDetailsApi()
    }
    // MARK:- Back Button Action-----
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addDriverDetailsButtonTap(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "EarningsAndTrips", bundle: Bundle.main)
        let payoutVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kPayoutDetailsView) as! PayoutDetailsViewController
        self.navigationController?.pushViewController(payoutVC, animated: true)
    }
    
    // MARK:- Settings Button Action -----
    @objc func settingsButtonTap(sender:UIButton!) {
        let selectedIndexPath = sender.tag
        let selectedBankID = bankDetailsArr[selectedIndexPath]["id"] as? String ?? ""
        let settingsAlertController = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: "", preferredStyle: .actionSheet)
        settingsAlertController.view.tintColor = Constants.AppColour.kAppGreenColor
        let markDefaultAction = UIAlertAction(title: Constants.AppAlertAction.kMakeDefaultAccount, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
            
            let defaultPermissionAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: "Do You Want To Mark The Bank As Default?", preferredStyle: .alert)
            defaultPermissionAlert.view.tintColor = Constants.AppColour.kAppGreenColor
            let markDefault = UIAlertAction(title: "Mark Default", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
                self.markBankDetailsAsDefaultApi(bankAccountID: selectedBankID,selectedIndex : selectedIndexPath)
            })
            
            let cancel = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            defaultPermissionAlert.addAction(cancel)
            defaultPermissionAlert.addAction(markDefault)
            self.present(defaultPermissionAlert, animated: true, completion: nil)
            
        }
        
        let deleteAction = UIAlertAction(title: Constants.AppAlertAction.kDeleteAccount, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
            
            let deletePermissionAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: "Do You Want To Delete The Bank Details?", preferredStyle: .alert)
            deletePermissionAlert.view.tintColor = Constants.AppColour.kAppGreenColor
            let delete = UIAlertAction(title: "Delete", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
                self.deleteDriverBankDetailsApi(bankAccountID: selectedBankID,selectedIndex : selectedIndexPath)
            })
            
            let cancel = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            deletePermissionAlert.addAction(cancel)
            deletePermissionAlert.addAction(delete)
            self.present(deletePermissionAlert, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction.init(title: Constants.AppAlertAction.kNo, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        settingsAlertController.addAction(markDefaultAction)
        settingsAlertController.addAction(deleteAction)
        settingsAlertController.addAction(cancel)
        self.present(settingsAlertController, animated: true, completion: nil)
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
    
    // MARK:- Service Call -----
    func getAllDriverAccountDetailsApi(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        let token = "Bearer " + authToken
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
        let fetchdriverBankDetailsUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetDriverBankDetails
        
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Fetching Bank Details List...")
        }
        
        APIWrapper.requestGETURL(fetchdriverBankDetailsUrl, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1) {
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        self.bankDetailsArr.removeAll()
                        self.bankDetailsArr = dictResponse![ApiKeyConstants.kResult] as? [[String:Any]] ?? [[String:Any]]()
                        if self.bankDetailsArr.count > 0 {
                            self.addDriverDetailsButton.isHidden = false
                            self.noAccountView.isHidden = true
                            self.driverPayoutTable.reloadData()
                        } else {
                            self.driverPayoutTable.reloadData()
                            self.noAccountView.isHidden = false
                            self.addDriverDetailsButton.isHidden = true
                        }
                    }
                    else{
                        self.driverPayoutTable.reloadData()
                        self.noAccountView.isHidden = false
                        self.addDriverDetailsButton.isHidden = true
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
    
    func deleteDriverBankDetailsApi(bankAccountID : String,selectedIndex : Int){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        let token = "Bearer " + authToken
        let dictHeaderParams:HTTPHeaders  = ["Content-Type":"application/json","Authorization": token]
        let deleteDriverBankDetailsUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kDeleteDriverBankAccount
        let dictParameter: Parameters = ["account_id" : bankAccountID]
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Deleting Bank Details...")
        }
        
        APIWrapper.requestPOSTURL(deleteDriverBankDetailsUrl, params: dictParameter, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1) {
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                        self.bankDetailsArr.remove(at: selectedIndex)
                        self.driverPayoutTable.reloadData()
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    }
                } else {
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
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
            
        }
    }
    
    func markBankDetailsAsDefaultApi(bankAccountID : String,selectedIndex : Int) {
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        let token = "Bearer " + authToken
        let dictHeaderParams:HTTPHeaders  = ["Content-Type":"application/json","Authorization": token]
        let defaultDriverBankDetailsUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kMarkDefaultDriverAccount
        let dictParameter: Parameters = ["account_id" : bankAccountID]
        
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Mark Default Bank Details...")
        }
        
        APIWrapper.requestPOSTURL(defaultDriverBankDetailsUrl, params: dictParameter, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1) {
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        var bankDetailsDict = self.bankDetailsArr[selectedIndex]
                        bankDetailsDict["default"] = true
                        self.bankDetailsArr[selectedIndex] = bankDetailsDict
                        self.getAllDriverAccountDetailsApi()
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    }
                } else {
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
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
            
        }
    }
}

//MARK:- TableView DataSource & Delegate Method ----
extension DriverPayoutViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bankDetailsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let driverDetailsTableCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kDriverPayoutCell) as! DriverPayoutTableViewCell
        let currentDict:[String:Any] = bankDetailsArr[indexPath.row]
        driverDetailsTableCell.bankNameLabel.text = currentDict["bank_name"] as? String ?? ""
        driverDetailsTableCell.driverNameLabel.text = currentDict["account_holder_name"] as? String ?? ""
        driverDetailsTableCell.accountNumberLabel.text = currentDict["last4"] as? String ?? ""
        driverDetailsTableCell.routingNumberLabel.text = currentDict["routing_number"] as? String ?? ""
        let countryCode = currentDict["country"] as? String ?? ""
        driverDetailsTableCell.countryNameLabel.text = Locale.current.localizedString(forRegionCode: countryCode)
        driverDetailsTableCell.currencyLabel.text = (currentDict["currency"] as? String ?? "").uppercased()
        driverDetailsTableCell.settingsButton.tag = indexPath.row
        if currentDict["default"] as? Bool == true{
            driverDetailsTableCell.settingsButton.isUserInteractionEnabled = false
            driverDetailsTableCell.settingsButton.setImage(UIImage(named: "setDefault"), for: .normal)
        }
        else{
            driverDetailsTableCell.settingsButton.setImage(UIImage(named: "selectOption"), for: .normal)
            driverDetailsTableCell.settingsButton.isUserInteractionEnabled = true
            driverDetailsTableCell.settingsButton.addTarget(self, action: #selector(settingsButtonTap(sender:)), for: .touchUpInside)
        }
        return driverDetailsTableCell
    }
}

extension DriverPayoutViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
}
