//
//  SelectCarViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 22/01/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD
import Reachability

class SelectCarViewController: UIViewController {
    
    @IBOutlet weak var selectCarTableView: UITableView!
    var tableDataArr = [[String:Any]]()
    fileprivate var indexPathSelect = [IndexPath]()
    fileprivate var selectedCarID = String()
    
    fileprivate var selectedCarDict = [String:Any]()
    
    var isFromHome : Bool = false
    var callback : (([String : AnyObject]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        selectedCarID = ""
        selectedCarDict = [String:Any]()
        
        if(tableDataArr.count > 0 ) {
            let indexPath   = IndexPath(row: 0, section: 0)
            indexPathSelect.insert(indexPath, at: 0)
            selectedCarID   = tableDataArr[0][ApiKeyConstants.k_id] as? String ?? ""
            selectedCarDict = tableDataArr[0]
        } /*else {
            indexPathSelect.removeAll()
            selectedCarID = ""
            selectedCarDict = [String:Any]()
        }*/
        
        selectCarTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    
    // MARK:- Next Button Tap
    @IBAction func nextButtonTap(_ sender: Any) {
        if Reachibility.isConnectedToNetwork(){
            if(selectedCarID == ""){
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSelectCarError, Button_Title: Constants.AppAlertAction.kOKButton, self)
            } else {
                selectCarApi()
            }
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // MARK:- Back Button Tap
    @IBAction func Click_Back(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

// MARK:- TableView Delegate & DataSource Method-----
extension SelectCarViewController : UITableViewDelegate,UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height/4;
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataArr.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let carCell:SelectCarTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kSelectCarTableCellID) as! SelectCarTableViewCell
        carCell.accessoryView = UIImageView(image: UIImage(named:""))
        carCell.carModelNameLabel.text = "\((tableDataArr[indexPath.row][ApiKeyConstants.CarDetails.kManufacturer] as? String ?? "")?.uppercased() ?? "")" + " \((tableDataArr[indexPath.row][ApiKeyConstants.CarDetails.kModel] as? String ?? "")?.uppercased() ?? "")"
        carCell.carModelNumberLabel.text = (tableDataArr[indexPath.row][ApiKeyConstants.CarDetails.kLicensePlateNo] as? String)?.uppercased()
        
        if indexPathSelect.count > 0 {
            let result = indexPathSelect.filter { $0==indexPath }
            if result.count > 0{
                carCell.accessoryView = UIImageView(image: UIImage(named:"checkTick"))
            }
            else{
                carCell.accessoryView = UIImageView(image: UIImage(named:""))
            }
        }
        return carCell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        debugPrint(tableDataArr[indexPath.row])
        
        selectedCarID   = tableDataArr[indexPath.row][ApiKeyConstants.k_id] as? String ?? ""
        selectedCarDict = tableDataArr[indexPath.row]
        
        if indexPathSelect.count > 0 {
            let result = indexPathSelect.filter { $0==indexPath }
            if result.count > 0 {
                indexPathSelect.remove(at: 0)
                selectedCarID = ""
                selectedCarDict = [String:Any]()
            }
            else{
                indexPathSelect.remove(at: 0)
                indexPathSelect.insert(indexPath, at: 0)
            }
        }
        else{
            indexPathSelect.insert(indexPath, at: 0)
        }
        tableView.reloadData()
        
    }
    
    // MARK:- Select Car Api Called ----
    func selectCarApi() {
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let token = "Bearer " + authToken
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
        let selectCarUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kSelectCar
        
        let dictParams = [ApiKeyConstants.CarDetails.kCar_Id : selectedCarID] as [String : Any]
        debugPrint(dictParams)
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Selecting Car...")
        }
        Utility.removeAppCookie()
        APIWrapper.requestPUTURL(selectCarUrl, params: dictParams as [String : AnyObject], headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        self.goToHomeView(status: true)
                    }
                    else{
                        let alertController = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, preferredStyle: UIAlertController.Style.alert)
                        alertController.view.tintColor = Constants.AppColour.kAppGreenColor
                        let homeAction = UIAlertAction(title: "Home", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                            self.goToHomeView(status: false)
                        }
                        let cancelAction = UIAlertAction(title: Constants.AppAlertAction.kNo, style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                            debugPrint("Cancel")
                            self.dismiss(animated: true, completion: nil)
                        }
                        alertController.addAction(cancelAction)
                        alertController.addAction(homeAction)
                        self.present(alertController, animated: true, completion: nil)
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
    
    // MARK:- GoTo HomeVC -----
    func goToHomeView(status:Bool){
        if(isFromHome) {
            self.dismiss(animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                var dictCallBack = [String : AnyObject]()
                
                dictCallBack[ApiKeyConstants.kisOnline]                     = status as AnyObject
                dictCallBack[ApiKeyConstants.CarDetails.kCarDict]           = self.selectedCarDict as AnyObject
                self.callback?(dictCallBack)
            }
            
        } else {
            let storyBoard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
            let homeVc = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kHomeStoryboardId) as! HomeViewController
            self.show(homeVc, sender: self)
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
