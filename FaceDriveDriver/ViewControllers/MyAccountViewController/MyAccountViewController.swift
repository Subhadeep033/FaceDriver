//
//  MyAccountViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 4/29/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SVProgressHUD
import Reachability


class MyAccountViewController: UIViewController {

    @IBOutlet weak var tableviewMyAccount: UITableView!
    var arrCarDetails = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        tableviewMyAccount.estimatedRowHeight = 100.0
        tableviewMyAccount.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getDriverProfieDetails()
    }
    
    //MARK:- Button Action
    @IBAction func backButtonTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:- Service Call
    
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
                        self.arrCarDetails = resultDict["cars"] as? [[String : Any]] ?? []
                        
                        self.tableviewMyAccount.reloadData()
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

extension MyAccountViewController : UITableViewDataSource {
    
    // MARK:- UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return 1
        } else {
            return 2
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let cell: MyAccountCell
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kMyAccountCellId, for: indexPath) as! MyAccountCell
            cell.lblAccountType.text = "Personal Details"
            cell.selectionStyle = .none
            return cell
        } else {
            if (indexPath.row == 0) {
                let cell: SeperatorCell
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kSeperatorCellId, for: indexPath) as! SeperatorCell
                
                cell.selectionStyle = .none
                return cell
            } else {
                let cell: MyAccountCell
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kMyAccountCellId, for: indexPath) as! MyAccountCell
                if (indexPath.section == 3){
                    cell.lblAccountType.text = "Facedrive Documents"
                }
                else{
                    cell.lblAccountType.text = indexPath.section == 1 ? "Personal Documents" : "Car Details and Documents"
                }
                cell.selectionStyle = .none
                return cell
            }
        }
    }
}

//MARK:- TableView Delegate ----
extension MyAccountViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            
            let storyBoard = UIStoryboard.init(name: "Profile", bundle: Bundle.main)
            let profileVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kProfileStoryboardId) as! ProfileViewController
            profileVC.isFromPageView = false
            self.show(profileVC, sender: self)
            
        } else {
            if(indexPath.row > 0) {
                if(indexPath.section == 1) {
                    
                    let storyBoard = UIStoryboard.init(name: "Profile", bundle: Bundle.main)
                    let uploadDocumentVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kUploadDriverDocumentsStoryboardId) as! UploadDrivingLicenceViewController
                    
                    let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                    
                    uploadDocumentVC.isDriverDocuments = true
                    let documents : [[String:Any]] = driverDetailsDict["personal_docs"] as? [[String : Any]] ?? []
                    
                    if documents.count > 0{
                        uploadDocumentVC.personalDetails = driverDetailsDict["personal_docs"] as? [[String : Any]] ?? []
                    }
                    else{
                        uploadDocumentVC.personalDetails = []
                    }
                    
                    uploadDocumentVC.isFromPageView = false
                    self.show(uploadDocumentVC, sender: self)
                    
                }
                else if(indexPath.section == 3){
                    let storyBoard = UIStoryboard.init(name: "Profile", bundle: Bundle.main)
                    let ptcDocumentsVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kPTCDocumentsStoryBoardId) as! PTCDocumentsViewController
                    self.show(ptcDocumentsVC, sender: self)
                }else {
                    
                    let storyBoard = UIStoryboard.init(name: "Profile", bundle: Bundle.main)
                    let carListVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kCarListStoryboardId) as! CarListViewController
                    self.show(carListVC, sender: self)
                }
            }
        }
    }
}
