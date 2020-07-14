//
//  SelectRegionPopupViewController.swift
//  FaceDriveDriver
//
//  Created by DAT-Asset-259 on 06/06/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD
import Reachability
import Alamofire

class SelectRegionPopupViewController: UIViewController {
    
    var popUpTableDataArr = [[String:Any]]()
    var selectedDataSet = [[String:Any]]()
    var idSet = Set<String>()
    
    var callback : (([[String : AnyObject]]) -> Void)?
    
    @IBOutlet weak var popupViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var popupTableView: UITableView!
    
    var isEdit: Bool = false
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
    
    
    @IBAction func doneButtonTap(_ sender: Any) {
        
        selectedDataSet = popUpTableDataArr.filter({ idSet.contains($0[ApiKeyConstants.k_id] as? String ?? "") })
        
        self.callback?(selectedDataSet as [[String : AnyObject]])
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    // MARK:- Initial Setup
    
    func setupSelectCarPopups() {
        //self.headerLabel.font = UIFont(name: "Roboto-Bold", size: 25.0)
        if(!isEdit) {
            idSet.removeAll()
        }
        popUpTableDataArr.removeAll()
        
        self.headerLabel.text = headerTitle.capitalized
        
        self.getRegionApi()
    }
    
    
    // MARK:- Service Call
    
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
                        self.popupViewHeightConstraints.constant = CGFloat((60 * self.popUpTableDataArr.count) + 120) > self.view.frame.size.height/2 ? self.view.frame.size.height/2 : CGFloat((60 * self.popUpTableDataArr.count) + 120)
                        
                        self.popupTableView.reloadData()
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension SelectRegionPopupViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popUpTableDataArr.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let popupTableCell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kPopupTableCellID)!
        
        popupTableCell.accessoryView = UIImageView(image: UIImage(named: ""))
        
        let regionDetails = popUpTableDataArr[indexPath.row]
        
        popupTableCell.textLabel!.text = (regionDetails[ApiKeyConstants.kDriverName]! as AnyObject).capitalized
        
        popupTableCell.textLabel!.font = UIFont(name: "Roboto-Light", size: 13.0)
        popupTableCell.textLabel!.textColor = Constants.AppColour.kAppBlackColor
        popupTableCell.textLabel!.alpha = 0.5
        popupTableCell.backgroundColor = UIColor.clear
        popupTableCell.textLabel!.numberOfLines = 1
        popupTableCell.selectionStyle = .none
        
        if(self.idSet.contains(regionDetails[ApiKeyConstants.k_id] as? String ?? "")) {
            popupTableCell.accessoryView = UIImageView(image: UIImage(named:"checkTick"))
            popupTableCell.textLabel!.alpha = 1.0
        } else {
            popupTableCell.accessoryView = UIImageView(image: UIImage(named:""))
            popupTableCell.textLabel!.alpha = 0.5
        }
        
        return popupTableCell
        
    }
}

extension SelectRegionPopupViewController : UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let regionDetails = popUpTableDataArr[indexPath.row]
        
        if (self.idSet.contains(regionDetails[ApiKeyConstants.k_id] as? String ?? "")) {
            
            self.idSet.remove(regionDetails[ApiKeyConstants.k_id] as? String ?? "")
            
           /* if let index = selectedDataSet.index(where: { (item) -> Bool in return true} ) {
                print(selectedDataSet[index]) // Cur(id: "b", name: "steve", symbol: "s", switchVal: true)\n"
                print(selectedDataSet[index])  // "b\n"
            }*/
            
           /* let isContain = selectedDataSet.index(where: { (item) in
                
                if(item["_id"] as? String == item_acc["_id"] as? String) {
                } else {
                }
            })*/
            
           // print(isContain ?? default value)
                
        } else {
            self.idSet.insert(regionDetails[ApiKeyConstants.k_id] as? String ?? "")
        }
        
        tableView.reloadData()
        
    }
}

