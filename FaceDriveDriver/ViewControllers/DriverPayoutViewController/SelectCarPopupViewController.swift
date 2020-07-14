//
//  SelectCarPopupViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 5/15/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD
import Reachability
import Alamofire

class SelectCarPopupViewController: UIViewController {
    
    var popUpTableDataArr = [[String:Any]]()
    var popUpSearchTableDataArr = [[String:Any]]()
    var search : String = ""
    var indexPathSelect = [IndexPath]()
    
    var callback : (([String : AnyObject]) -> Void)?
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var popupViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var popupTableView: UITableView!
    
    @IBOutlet weak var noResultFoundView: UIView!
    
    var tagNumber: Int = 0
    var headerTitle: String = ""
    var manufacturerID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        popupTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.TableCellId.kPopupTableCellID)
        popupTableView.delegate = self
        popupTableView.dataSource = self
        
        self.setupSelectCarPopups()
    }
    
    // MARK:- Button Action
    
    @IBAction func dismissButtonTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK:- Initial Setup
    
    func setupSelectCarPopups() {
        //self.headerLabel.font = UIFont(name: "Roboto-Bold", size: 25.0)
        popUpTableDataArr.removeAll()
        indexPathSelect.removeAll()
        popUpSearchTableDataArr.removeAll()
        
        self.headerLabel.text = headerTitle.capitalized
        
        switch self.tagNumber {
        case 0:
            self.getCarDetailsApi()
            break;
        case 1:
            self.getRegionApi()
            break;
        case 2:
            self.getCarManuFacturerApi()
            break;
        case 3:
            self.getCarModelApi(carManufacturerID:self.manufacturerID)
            break;
        case 4:
            self.getCarEnergyType()
            break;
        case 5:
            self.getStripeStateApi()
            break;
        default:
            popUpTableDataArr = [["noOfSeat" : "2"],["noOfSeat" : "4"],["noOfSeat" : "6"]]
            self.popupTableView.reloadData()
            break;
        }
        searchTextField.setLeftPaddingPoints(10)
        searchTextField.layer.borderColor = Constants.AppColour.kAppLightGreyColor.cgColor
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.cornerRadius = 7.0
        searchTextField.clipsToBounds = true
        searchTextField.delegate = self
    }
    
    
    // MARK:- Service Call
    // MARK:- Car Details Api Call
    func getCarDetailsApi(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        Utility.removeAppCookie()
        let carDetailsUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetCarDetails
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Loading Car Details...")
        }
        
        APIWrapper.requestGETURL(carDetailsUrl, headers: dictHeaderParams, success: { (JSONResponse) in
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
                        self.popUpTableDataArr.removeAll()
                        
                        for dict in dictResponse![ApiKeyConstants.kResult] as? [AnyObject] ?? []{
                            self.popUpTableDataArr.append(dict as? [String : Any] ?? [:])
                        }
                        self.popupViewHeightConstraints.constant = CGFloat((60 * self.popUpTableDataArr.count) + 130) > self.view.frame.size.height/2 ? self.view.frame.size.height/2 : CGFloat((60 * self.popUpTableDataArr.count) + 130)
                        self.popUpSearchTableDataArr = self.popUpTableDataArr
                        self.popupTableView.reloadData()
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton,self)
                    }
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            }
            else{
                Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton,self)
            }
        })
        { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // MARK:- Get Car EnergyType Api Call
    func getCarEnergyType(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        Utility.removeAppCookie()
        let getCarEnergyTypeUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetEnergyType
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Loading Energy Type...")
        }
        
        APIWrapper.requestGETURL(getCarEnergyTypeUrl, headers: dictHeaderParams, success: { (JSONResponse) in
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
                        self.popUpTableDataArr.removeAll()
                        
                        for dict in dictResponse![ApiKeyConstants.kResult] as? [AnyObject] ?? []{
                            self.popUpTableDataArr.append(dict as? [String : Any] ?? [:])
                        }
                        self.popupViewHeightConstraints.constant = CGFloat((60 * self.popUpTableDataArr.count) + 130) > self.view.frame.size.height/2 ? self.view.frame.size.height/2 : CGFloat((60 * self.popUpTableDataArr.count) + 130)
                        self.popUpSearchTableDataArr = self.popUpTableDataArr
                        self.popupTableView.reloadData()
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
    // MARK:- Get Region Api Call
    func getRegionApi(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        Utility.removeAppCookie()
        let getRegionUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetRegion
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Loading Region...")
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
                        self.popUpTableDataArr.removeAll()
                        
                        for dict in dictResponse![ApiKeyConstants.kResult] as? [AnyObject] ?? []{
                            self.popUpTableDataArr.append(dict as? [String : Any] ?? [:])
                        }
                        self.popupViewHeightConstraints.constant = CGFloat((60 * self.popUpTableDataArr.count) + 85) > self.view.frame.size.height/2 ? self.view.frame.size.height/2 : CGFloat((60 * self.popUpTableDataArr.count) + 85)
                        
                        self.popupTableView.reloadData()
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
    
    // MARK:- Car Manufacture Api Call
    func getCarManuFacturerApi(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        Utility.removeAppCookie()
        let getCarManufacturerUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetCarManufacturerList
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Loading Car Manufacturer...")
        }
        
        APIWrapper.requestGETURL(getCarManufacturerUrl, headers: dictHeaderParams, success: { (JSONResponse) in
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
                        self.popUpTableDataArr.removeAll()
                        let dictResult = dictResponse![ApiKeyConstants.kResult] as? [AnyObject] ?? []
                        
                        if(dictResult.count > 0) {
                            let sortedArray = (dictResult as NSArray).sortedArray(using: [NSSortDescriptor(key: ApiKeyConstants.kDriverName, ascending: true)]) as? [[String:AnyObject]] ?? [[:]]
                            for dict in sortedArray{
                                if dict[ApiKeyConstants.kDriverName] != nil{
                                    self.popUpTableDataArr.append(dict as [String : Any])
                                }
                            }
                        }
                        self.popupViewHeightConstraints.constant = CGFloat((60 * self.popUpTableDataArr.count) + 130) > self.view.frame.size.height/2 ? self.view.frame.size.height/2 : CGFloat((60 * self.popUpTableDataArr.count) + 130)
                        self.popUpSearchTableDataArr = self.popUpTableDataArr
                        self.popupTableView.reloadData()
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
    
    // MARK:- Car Model Api Call
    func getCarModelApi(carManufacturerID:String){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        
        let dictBodyParams:[String:String] = ["make_id" : carManufacturerID]
        Utility.removeAppCookie()
        let getCarModelUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetCarModelList
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Loading Car Model...")
        }
        
        APIWrapper.requestPUTURL(getCarModelUrl, params: dictBodyParams as [String : AnyObject], headers: dictHeaderParams, success: { (JSONResponse) in
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
                        self.popUpTableDataArr.removeAll()
                        
                        let dictResult = dictResponse![ApiKeyConstants.kResult] as? [AnyObject] ?? []
                        
                        if(dictResult.count > 0) {
                            let sortedArray = (dictResult as NSArray).sortedArray(using: [NSSortDescriptor(key: ApiKeyConstants.kDriverName, ascending: true)]) as? [[String:AnyObject]] ?? [[:]]
                            for dict in sortedArray{
                                if dict[ApiKeyConstants.kDriverName] != nil{
                                    if self.popUpTableDataArr.count > 0{
                                        let filterArray: [Any] = self.popUpTableDataArr.filter { NSPredicate(format: "(name contains[c] %@)", dict[ApiKeyConstants.kDriverName] as? String ?? "").evaluate(with: $0) }
                                        
                                        if filterArray.count == 0{
                                            self.popUpTableDataArr.append(dict as [String : Any])
                                        }
                                    }
                                    else{
                                        self.popUpTableDataArr.append(dict as [String : Any])
                                    }
                                }
                            }
                        }
                        
                        self.popupViewHeightConstraints.constant = CGFloat((60 * self.popUpTableDataArr.count) + 130) > self.view.frame.size.height/2 ? self.view.frame.size.height/2 : CGFloat((60 * self.popUpTableDataArr.count) + 130)
                        self.popUpSearchTableDataArr = self.popUpTableDataArr
                        self.popupTableView.reloadData()
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
        }){
            (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // MARK:- Stripe State Api Call
    func getStripeStateApi() {
        
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let headers:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        Utility.removeAppCookie()
        let url = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetStripeState
        
        
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Loading States...")
        }
        
        
        APIWrapper.requestPOSTURL(url, params: [:], headers: headers, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        //                    debugPrint(dictResponse![ApiKeyConstants.kResult]!)
                        self.popUpTableDataArr.removeAll()
                        
                        for dict in dictResponse![ApiKeyConstants.kResult] as? [AnyObject] ?? []{
                            self.popUpTableDataArr.append(dict as? [String : Any] ?? [:])
                        }
                        self.popupViewHeightConstraints.constant = CGFloat((60 * self.popUpTableDataArr.count) + 130) > self.view.frame.size.height/2 ? self.view.frame.size.height/2 : CGFloat((60 * self.popUpTableDataArr.count) + 130)
                        self.popUpSearchTableDataArr = self.popUpTableDataArr
                        self.popupTableView.reloadData()
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
}

//MARK:- UITableViewDataSource Method -----
extension SelectCarPopupViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popUpSearchTableDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let popupTableCell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kPopupTableCellID)!
        
        popupTableCell.accessoryView = UIImageView(image: UIImage(named: ""))
        
        
        switch self.tagNumber {
            case 0:
                popupTableCell.textLabel!.text = (popUpSearchTableDataArr[indexPath.row]["car_type"]! as AnyObject) as? String
                break;
            case 1:
                popupTableCell.textLabel!.text = (popUpSearchTableDataArr[indexPath.row][ApiKeyConstants.kDriverName]! as AnyObject) as? String
                break;
            case 2:
                if popUpSearchTableDataArr[indexPath.row][ApiKeyConstants.kDriverName] != nil{
                    popupTableCell.textLabel!.text = (popUpSearchTableDataArr[indexPath.row][ApiKeyConstants.kDriverName]! as AnyObject) as? String
                }
                break;
            case 3:
                if popUpSearchTableDataArr[indexPath.row][ApiKeyConstants.kDriverName] != nil{
                    popupTableCell.textLabel!.text = (popUpSearchTableDataArr[indexPath.row][ApiKeyConstants.kDriverName]! as AnyObject) as? String
                }
                break;
            case 4:
                popupTableCell.textLabel!.text = (popUpSearchTableDataArr[indexPath.row][ApiKeyConstants.kDriverName]! as AnyObject) as? String
                break;
            case 5:
                popupTableCell.textLabel!.text = (popUpSearchTableDataArr[indexPath.row][ApiKeyConstants.kDriverName]! as AnyObject) as? String
                break;
            default:
                popupTableCell.textLabel!.text = (popUpSearchTableDataArr[indexPath.row]["noOfSeat"]! as AnyObject) as? String
                break;
        }
        
        popupTableCell.textLabel!.font = UIFont(name: "Roboto-Light", size: 13.0)
        popupTableCell.textLabel!.textColor = Constants.AppColour.kAppBlackColor
        popupTableCell.textLabel!.alpha = 0.5
        popupTableCell.backgroundColor = UIColor.clear
        popupTableCell.textLabel!.numberOfLines = 1
        popupTableCell.selectionStyle = .none
        
        if indexPathSelect.count > 0{
            let result = indexPathSelect.filter { $0==indexPath }
            if result.count > 0{
                popupTableCell.accessoryView = UIImageView(image: UIImage(named:"checkTick"))
                popupTableCell.textLabel!.alpha = 1.0
            }
            else{
                popupTableCell.accessoryView = UIImageView(image: UIImage(named:""))
                popupTableCell.textLabel!.alpha = 0.5
            }
        }
        return popupTableCell
    }
}

//MARK:- UITableViewDelegate Methods ----
extension SelectCarPopupViewController : UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPathSelect.count > 0 {
            let result = indexPathSelect.filter { $0==indexPath }
            if result.count > 0 {
                indexPathSelect.remove(at: 0)
            }
            else {
                indexPathSelect.remove(at: 0)
                indexPathSelect.insert(indexPath, at: 0)
                
                self.callback?(popUpSearchTableDataArr[indexPath.row] as [String : AnyObject])
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
        else{
            indexPathSelect.insert(indexPath, at: 0)
            
            self.callback?(popUpSearchTableDataArr[indexPath.row] as [String : AnyObject])
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
        tableView.reloadData()
        
    }
}

//MARK:- UITextFieldDelegate Methods-----
extension SelectCarPopupViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty
        {
            search = String(textField.text?.dropLast() ?? "")
        }
        else
        {
            search=textField.text!+string
        }
        
        debugPrint(search)
        var arr = [[String : Any]]()
        if self.tagNumber == 0{
            arr.removeAll()
            let searchPredicate = NSPredicate(format: "SELF.car_type CONTAINS[c] %@", search)
            arr = (popUpTableDataArr as NSArray).filtered(using: searchPredicate) as? [[String : Any]] ?? []
        }else{
            arr.removeAll()
            let searchPredicate = NSPredicate(format: "SELF.name CONTAINS[c] %@", search)
            arr = (popUpTableDataArr as NSArray).filtered(using: searchPredicate) as? [[String : Any]] ?? []
        }
        debugPrint ("array = \(arr)")
        
        if arr.count > 0
        {
            popUpSearchTableDataArr.removeAll(keepingCapacity: true)
            popUpSearchTableDataArr = arr
            popupTableView.isHidden = false
            noResultFoundView.isHidden = true
        }
        else
        {
            if search == ""{
                popUpSearchTableDataArr = popUpTableDataArr
                popupTableView.isHidden = false
                noResultFoundView.isHidden = true
            }
            else{
                popUpSearchTableDataArr.removeAll()
                popupTableView.isHidden = true
                noResultFoundView.isHidden = false
            }
        }
        
        popupTableView.reloadData()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
