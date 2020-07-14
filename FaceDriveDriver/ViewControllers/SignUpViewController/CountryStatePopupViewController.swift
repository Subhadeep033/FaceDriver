//
//  CountryStatePopupViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 13/05/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD
import Reachability

class CountryStatePopupViewController: UIViewController {

    var callback : (([String : AnyObject]) -> Void)?
    
     var tableDataCountry = [[String:Any]]()
     var tableSearchDataCountry = [[String:Any]]()
     var search:String = ""
     var isCountrySelected = Bool()
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var DialogView: UIView!
    
    @IBOutlet weak var noSearchView: UIView!
    @IBOutlet weak var countryStateTableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var countryPopupHeightConstraints: NSLayoutConstraint!
    
    var stateId = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        self.DialogView.layer.cornerRadius = 20.0
        self.DialogView.clipsToBounds = true
        self.setupCountryCodePopups(isCountry: isCountrySelected, stateId: stateId)
        // Do any additional setup after loading the view.
    }
    
    // MARK:- Setup Country Code Popups -----
    func setupCountryCodePopups(isCountry:Bool,stateId : [[String : Any]]){
        
        isCountrySelected = isCountry
        if isCountry{
            self.headerLabel.text = "Select Country"
            self.searchTextField.placeholder = "Select Country"
            tableDataCountry.removeAll()
            tableSearchDataCountry.removeAll()
            self.countryStateTableView.reloadData()
            self.getCountryAndStateList()
        }
        else {
            debugPrint(stateId)
            headerLabel.text = "State/Province"
            self.searchTextField.placeholder = "State/Province"
            tableDataCountry.removeAll()
            tableSearchDataCountry.removeAll()
            for states in stateId{
                let dict : [String : Any] = [ApiKeyConstants.kDriverName : states[ApiKeyConstants.kDriverName]!,"state_id" : states["state_id"]!]
                tableDataCountry.append(dict)
            }
            //                    tableDataCountry = countryList
            countryPopupHeightConstraints.constant = CGFloat((110 + (50 * tableDataCountry.count)))
            tableSearchDataCountry = tableDataCountry
            self.countryStateTableView.reloadData()
        }
        
        searchTextField.setLeftPaddingPoints(10)
        searchTextField.layer.borderColor = Constants.AppColour.kAppLightGreyColor.cgColor
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.cornerRadius = 7.0
        searchTextField.clipsToBounds = true
        searchTextField.delegate = self
        countryStateTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.TableCellId.kCountryStatePopupCellID)
        countryStateTableView.delegate = self
        countryStateTableView.dataSource = self
        
    }
    
    // MARK:- button Action
    @IBAction func dismissButtonTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Service Call
    func getCountryAndStateList(){
        let dictHeaderParams:[String : String] = ["cache-control": "no-cache"]
        let getCountryStateUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kCountryStateList
        
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView((self.view))
            SVProgressHUD.show(withStatus: "Loading...")
        }
        Utility.removeAppCookie()
        APIWrapper.requestGETURL(getCountryStateUrl, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            debugPrint(dictResponse!)
            
            if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                    
                    
                    let countryList : [[String:Any]] = dictResponse![ApiKeyConstants.kResult] as? [[String : Any]] ?? []
                    
                    //                    debugPrint(countryList.count)
                    self.tableDataCountry.removeAll()
                    for country in countryList{
                        let dict : [String : Any] = [ApiKeyConstants.kDriverName : country[ApiKeyConstants.kDriverName]!,"country_id" : country["country_id"]!,"states" : country["states"]!]
                        self.tableDataCountry.append(dict)
                    }
                    //                    tableDataCountry = countryList
                    self.tableSearchDataCountry = self.tableDataCountry
                    self.countryPopupHeightConstraints.constant = CGFloat((110 + (50 * self.tableDataCountry.count)))
                    self.countryStateTableView.reloadData()
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

// MARK:- TableView Delegate Methods -----
extension CountryStatePopupViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDict = tableSearchDataCountry[indexPath.row]
        
        self.callback?(selectedDict as [String : AnyObject])
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK:- TableView DataSource Methods -----
extension CountryStatePopupViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSearchDataCountry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let countryStateTableCell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCountryStatePopupCellID)!
        if isCountrySelected{
            countryStateTableCell.textLabel?.text = tableSearchDataCountry[indexPath.row][ApiKeyConstants.kDriverName] as? String
        }
        else{
            countryStateTableCell.textLabel?.text = tableSearchDataCountry[indexPath.row][ApiKeyConstants.kDriverName] as? String
        }
        
        countryStateTableCell.textLabel?.font = UIFont(name: "Roboto-Light", size: 13.0)
        
        countryStateTableCell.selectionStyle = .none
        
        return countryStateTableCell
    }
}

// MARK:- TextField Delegate Methods -----
extension CountryStatePopupViewController: UITextFieldDelegate {
    
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
        
        let searchPredicate = NSPredicate(format: "SELF.name CONTAINS[c] %@", search)
        let arr = (tableDataCountry as NSArray).filtered(using: searchPredicate)
        
        debugPrint ("array = \(arr)")
        
        if arr.count > 0
        {
            tableSearchDataCountry.removeAll(keepingCapacity: true)
            tableSearchDataCountry = arr as? [[String : Any]] ?? []
            countryStateTableView.isHidden = false
            noSearchView.isHidden = true
        }
        else
        {
            if search == ""{
                tableSearchDataCountry = tableDataCountry
                countryStateTableView.isHidden = false
                noSearchView.isHidden = true
            }
            else{
                tableSearchDataCountry.removeAll()
                countryStateTableView.isHidden = true
                noSearchView.isHidden = false
            }
            
        }
        
        countryStateTableView.reloadData()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
