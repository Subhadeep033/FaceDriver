//
//  CountryStatePopups.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 23/02/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD
import Reachability

fileprivate var tableDataCountry = [[String:Any]]()
fileprivate var tableSearchDataCountry = [[String:Any]]()
fileprivate var search:String = ""
fileprivate var isCountrySelected = Bool()

class CountryStatePopups: UIView,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    var callback : (([String : AnyObject]) -> Void)?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var DialogView: UIView!
    @IBOutlet weak var BackgroundView: UIView!
    @IBOutlet weak var countryStateTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    var parentVC : UIViewController!
    //var countryStateDelegateObj : CountryStateDelegate?
    
    class func instanceFromNib() -> CountryStatePopups{
        return UINib(nibName: "CountryStatePopups", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! CountryStatePopups
        
    }
    
    func setupCountryCodePopups(vc:UIViewController, isCountry:Bool,stateId:[[String : Any]]){
        
        parentVC = vc
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView))
        tapGestureRecognizer.delegate = self
        
        isCountrySelected = isCountry
        if isCountry{
            headerLabel.text = "Select Country"
            tableDataCountry.removeAll()
            tableSearchDataCountry.removeAll()
            self.countryStateTableView.reloadData()
            self.searchTextField.placeholder = "Select Country"
            self.getCountryAndStateList()
            self.show(animated:true)
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
            tableSearchDataCountry = tableDataCountry
            self.countryStateTableView.reloadData()
            self.show(animated:true)
        }
        
        BackgroundView.addGestureRecognizer(tapGestureRecognizer)
        searchTextField.setLeftPaddingPoints(10)
        searchTextField.layer.borderColor = Constants.AppColour.kAppBorderColor.cgColor
        searchTextField.layer.borderWidth = 2.0
        searchTextField.clipsToBounds = true
        searchTextField.delegate = self
        countryStateTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.TableCellId.kCountryStatePopupCellID)
        countryStateTableView.delegate = self
        countryStateTableView.dataSource = self
        
    }
    
}

extension CountryStatePopups{
    
    func show(animated:Bool){
        
        self.BackgroundView.alpha = 1
       // self.DialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.DialogView.frame.height/2)
        
        self.parentVC.view.addSubview(self)
        //UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)
        
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.BackgroundView.alpha = 1
            })
            
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIView.AnimationOptions(rawValue: 0), animations: {
               // self.DialogView.center = self.center
                //self.dialogView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                debugPrint("Dialog Frame:",self.DialogView.frame)
            }, completion: { (completed) in
                
            })
        }else{
            self.BackgroundView.alpha = 1
           // self.DialogView.center  = self.center
        }
        
        countryStateTableView.reloadData()
    }
    
    func dismiss(animated:Bool){
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.BackgroundView.alpha = 0
            }, completion: { (completed) in
                
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIView.AnimationOptions(rawValue: 0), animations: {
                //self.DialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.DialogView.frame.height/2)
            }, completion: { (completed) in
                self.removeFromSuperview()
            })
        }else{
            self.removeFromSuperview()
        }
        
    }
    
    @objc func didTappedOnBackgroundView(){
        dismiss(animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.DialogView){
            return false
        }
        else{
            return true
        }
    }
    
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
        }
        else
        {
            tableSearchDataCountry=tableDataCountry
        }
        
        countryStateTableView.reloadData()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK:- TableView Delegate & DataDource
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDict = tableSearchDataCountry[indexPath.row]
        
        self.callback?(selectedDict as [String : AnyObject])
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
        
        //countryStateDelegateObj?.countrySelected(country: selectedDict)
        //countryStateDelegateObj?.stateSelected(state: selectedDict)
    }
    
    func getCountryAndStateList(){
        let dictHeaderParams:[String : String] = ["cache-control": "no-cache"]
        let getCountryStateUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kCountryStateList
        
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView((self))
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
                    tableDataCountry.removeAll()
                    for country in countryList{
                        let dict : [String : Any] = [ApiKeyConstants.kDriverName : country[ApiKeyConstants.kDriverName]!,"country_id" : country["country_id"]!,"states" : country["states"]!]
                        tableDataCountry.append(dict)
                    }
                    //                    tableDataCountry = countryList
                    tableSearchDataCountry = tableDataCountry
                    self.countryStateTableView.reloadData()
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                }
            }
            else{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
            }
        })
        { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
        }
    }
    
    // MARK:- Network Change Observer Methods-----
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            debugPrint("Reachable via WiFi")
            Utility.isNetworkEnabled(targetView: (self.window?.rootViewController!.view)!, targetedVC: self.window!.rootViewController!, message: Constants.AppAlertMessage.kBackToOnline, networkEnabled: true, btnMessage: "")
        case .cellular:
            debugPrint("Reachable via Cellular")
            Utility.isNetworkEnabled(targetView: (self.window?.rootViewController!.view)!, targetedVC: self.window!.rootViewController!, message: Constants.AppAlertMessage.kBackToOnline, networkEnabled: true, btnMessage: "")
        case .none:
            debugPrint("Network not reachable")
            Utility.isNetworkEnabled(targetView: (self.window?.rootViewController!.view)!, targetedVC: self.window!.rootViewController!, message: Constants.AppAlertMessage.kNoNetworkAccess, networkEnabled: false, btnMessage: "")
        case .unavailable:
            debugPrint("Network not available")
        }
    }
}
