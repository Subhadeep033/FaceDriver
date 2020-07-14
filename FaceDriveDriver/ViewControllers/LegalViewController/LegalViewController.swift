//
//  LegalViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 26/03/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SafariServices
import Reachability
import SVProgressHUD

class LegalTableCell : UITableViewCell{
    
    @IBOutlet weak var legalTextLabel: UILabel!
}

class LegalViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var legalTableView: UITableView!
    var legalDataArray = [[String:String]]()
    var dataDetailsDict = [String : String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        self.getLegalListApi()
        //legalDataArray = ["Copyright","Terms & Condition","Privacy Policy","Data Providers","Software License","Location Information"]
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Service Call -----
    func getLegalListApi(){
        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        Utility.removeAppCookie()
        let getRegionUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kLegalList
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(currentVC.view)
            SVProgressHUD.show(withStatus: "Loading...")
        }
        
        APIWrapper.requestGETURL(getRegionUrl, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        //                    debugPrint(dictResponse![ApiKeyConstants.kResult]!)
                        self.legalDataArray = dictResponse![ApiKeyConstants.kResult] as? [[String : String]] ?? []
                        self.legalTableView.reloadData()
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    }
                }
                else {
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
    
    // MARK:- TableView Delegate & DataSource Methods-----
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return legalDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let legalCell : LegalTableCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kLegalCell) as! LegalTableCell
        let legalDict = legalDataArray[indexPath.row]
        legalCell.legalTextLabel.text = legalDict[ApiKeyConstants.kPageName]?.capitalized
        return legalCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let legalDict = legalDataArray[indexPath.row]
        let legalPageName : String = legalDict[ApiKeyConstants.kPageName]?.capitalized ?? ""
        let legalUrl : String = legalDict[ApiKeyConstants.kPageUrl] ?? ""
        
        openWebPageWithUrl(url: legalUrl,headerTitle : legalPageName)
        
    }
    
    //MARK:- Open Webpage Url -----
    func openWebPageWithUrl(url : String,headerTitle : String){
        
        let storyBoard = UIStoryboard.init(name: "EarningsAndTrips", bundle: Bundle.main)
        let legalDetailsVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kLegalDetailsId) as! LegalDetailsViewController
        legalDetailsVC.legalLinkToOpen = url
        legalDetailsVC.headerTitle = headerTitle
        self.show(legalDetailsVC, sender: self)
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
