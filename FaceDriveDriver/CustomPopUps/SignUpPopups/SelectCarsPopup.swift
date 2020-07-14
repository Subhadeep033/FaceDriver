//
//  SelectCarsPopup.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 24/01/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SVProgressHUD


/*protocol selectCarDetailsDelegate{
 func setCarDetails(selectedObj : [String:AnyObject])
 func selectedRegion(regionObj : [String : AnyObject])
 func selectedCarManufacturer(carManufacturerObj : [String : AnyObject])
 func selectedCarModel(carModelObj : [String : AnyObject])
 }*/






class SelectCarsPopup: UIView,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource {
    
     var popUpTableDataArr = [[String:Any]]()
     var indexPathSelect = [IndexPath]()
     var popupTag = Int()
    
    //var delegate : selectCarDetailsDelegate?
    var callback : (([String : AnyObject]) -> Void)?
    
    @IBOutlet weak var popupViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var popupTableView: UITableView!
    @IBOutlet weak var selectCarPopupsTrailingConstraints: NSLayoutConstraint!
    
    class func instanceFromNib() -> SelectCarsPopup{
        return UINib(nibName: "SelectCarsPopup", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! SelectCarsPopup
        
    }
    
    func setupSelectCarPopups(title:String,tagNumber:Int,manufacturerID:String) {
        //self.headerLabel.font = UIFont(name: "Roboto-Bold", size: 25.0)
        popUpTableDataArr.removeAll()
        indexPathSelect.removeAll()
        
        popupTag = tagNumber
        self.headerLabel.text = title.capitalized
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView))
        tapGestureRecognizer.delegate = self
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
        if(tagNumber == 0){
            getCarDetailsApi()
            //            popUpTableDataArr = [["carType" : "FaceDriver Economy"],["carType" : "FaceDriver XL"]]
        }
        else if(tagNumber == 1){
            getRegionApi()
        }
        else if(tagNumber == 2){
            getCarManuFacturerApi()
        }
        else if(tagNumber == 3){
            getCarModelApi(carManufacturerID:manufacturerID)
        }
        else {
            popUpTableDataArr = [["noOfSeat" : "2"],["noOfSeat" : "4"],["noOfSeat" : "6"]]
        }
        popupTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.TableCellId.kPopupTableCellID)
        popupTableView.delegate = self
        popupTableView.dataSource = self
        self.show(animated: true, tag:popupTag)
    }
    
}

extension SelectCarsPopup{
    func show(animated:Bool, tag:Int){
        if Utility.isPlusDevice(){
            self.selectCarPopupsTrailingConstraints.constant = 20.0
        }
        else{
            self.selectCarPopupsTrailingConstraints.constant = 60.0
        }
        self.backgroundView.alpha = 1
        self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
        UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)
        
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 1
            })
            
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIView.AnimationOptions(rawValue: 0), animations: {
                self.dialogView.center = self.center
                //self.dialogView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                debugPrint("Dialog Frame:",self.dialogView.frame)
            }, completion: { (completed) in
                
            })
        }else{
            self.backgroundView.alpha = 1
            self.dialogView.center  = self.center
        }
        //        popupViewHeightConstraints.constant = CGFloat((60 * popUpTableDataArr.count) + 85) > self.frame.size.height/2 ? self.frame.size.height/2 : CGFloat((60 * popUpTableDataArr.count) + 85)
        //        debugPrint("popupheight= Frameheight=",popupViewHeightConstraints.constant,self.frame.size.height)
        //        popupTableView.reloadData()
    }
    
    func dismiss(animated:Bool){
        
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0
            }, completion: { (completed) in
                
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIView.AnimationOptions(rawValue: 0), animations: {
                self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
            }, completion: { (completed) in
                let dictCallBack = [String : AnyObject]()
                self.callback?(dictCallBack)
                self.removeFromSuperview()
            })
        }else{
            let dictCallBack = [String : AnyObject]()
            self.callback?(dictCallBack)
            self.removeFromSuperview()
        }
        
    }
    
    @objc func didTappedOnBackgroundView(){
        dismiss(animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.dialogView){
            return false
        }
        else{
            return true
        }
    }
    
    // MARK : TableView Delegate & DataDource
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popUpTableDataArr.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let popupTableCell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kPopupTableCellID)!
        
        
        popupTableCell.accessoryView = UIImageView(image: UIImage(named: ""))
        if(popupTag == 0){
            popupTableCell.textLabel!.text = (popUpTableDataArr[indexPath.row]["car_type"]! as AnyObject).capitalized
        }
        else if(popupTag == 1){
            popupTableCell.textLabel!.text = (popUpTableDataArr[indexPath.row][ApiKeyConstants.kDriverName]! as AnyObject).capitalized
        }
        else if(popupTag == 2){
            if popUpTableDataArr[indexPath.row][ApiKeyConstants.kDriverName] != nil{
                popupTableCell.textLabel!.text = (popUpTableDataArr[indexPath.row][ApiKeyConstants.kDriverName]! as AnyObject).capitalized
            }
        }
        else if(popupTag == 3){
            if popUpTableDataArr[indexPath.row][ApiKeyConstants.kDriverName] != nil{
                popupTableCell.textLabel!.text = (popUpTableDataArr[indexPath.row][ApiKeyConstants.kDriverName]! as AnyObject).capitalized
            }
        }
        else{
            popupTableCell.textLabel!.text = (popUpTableDataArr[indexPath.row]["noOfSeat"]! as AnyObject).capitalized
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPathSelect.count > 0{
            let result = indexPathSelect.filter { $0==indexPath }
            if result.count > 0{
                indexPathSelect.remove(at: 0)
            }
            else{
                indexPathSelect.remove(at: 0)
                indexPathSelect.insert(indexPath, at: 0)
                
                /*if popupTag == 0{
                 delegate?.setCarDetails(selectedObj: popUpTableDataArr[indexPath.row] as [String : AnyObject])
                 }
                 else if popupTag == 1{
                 delegate?.selectedRegion(regionObj: popUpTableDataArr[indexPath.row] as [String : AnyObject])
                 }
                 else if popupTag == 2{
                 delegate?.selectedCarManufacturer(carManufacturerObj: popUpTableDataArr[indexPath.row] as [String : AnyObject])
                 }
                 else if popupTag == 3{
                 delegate?.selectedCarModel(carModelObj: popUpTableDataArr[indexPath.row] as [String : AnyObject])
                 }
                 self.dismiss(animated: true)*/
                
                self.callback?(popUpTableDataArr[indexPath.row] as [String : AnyObject])
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
        else{
            indexPathSelect.insert(indexPath, at: 0)
            /*if popupTag == 0{
             delegate?.setCarDetails(selectedObj: popUpTableDataArr[indexPath.row] as [String : AnyObject])
             }
             else if popupTag == 1{
             delegate?.selectedRegion(regionObj: popUpTableDataArr[indexPath.row] as [String : AnyObject])
             }
             else if popupTag == 2{
             delegate?.selectedCarManufacturer(carManufacturerObj: popUpTableDataArr[indexPath.row] as [String : AnyObject])
             }
             else if popupTag == 3{
             delegate?.selectedCarModel(carModelObj: popUpTableDataArr[indexPath.row] as [String : AnyObject])
             }
             self.dismiss(animated: true)*/
            
            
            self.callback?(popUpTableDataArr[indexPath.row] as [String : AnyObject])
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
        tableView.reloadData()
        
    }
    
    func getCarDetailsApi(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        Utility.removeAppCookie()
        let carDetailsUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetCarDetails
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView((self.window?.rootViewController?.view)!)
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
                        self.popupViewHeightConstraints.constant = CGFloat((60 * self.popUpTableDataArr.count) + 85) > self.frame.size.height/2 ? self.frame.size.height/2 : CGFloat((60 * self.popUpTableDataArr.count) + 85)
                        debugPrint("popupheight= Frameheight=",self.popupViewHeightConstraints.constant,self.frame.size.height)
                        self.popupTableView.reloadData()
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                    }
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                }
            }
            else{
                Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
            }
        })
        { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
        }
    }
    
    func getRegionApi(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        Utility.removeAppCookie()
        let getRegionUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetRegion
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView((self.window?.rootViewController?.view)!)
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
                        self.popupViewHeightConstraints.constant = CGFloat((60 * self.popUpTableDataArr.count) + 85) > self.frame.size.height/2 ? self.frame.size.height/2 : CGFloat((60 * self.popUpTableDataArr.count) + 85)
                        debugPrint("popupheight= Frameheight=",self.popupViewHeightConstraints.constant,self.frame.size.height)
                        self.popupTableView.reloadData()
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                    }
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                }
            }
            else{
                Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
            }
        })
        { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
        }
    }
    
    func getCarManuFacturerApi(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        Utility.removeAppCookie()
        let getCarManufacturerUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetCarManufacturerList
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView((self.window?.rootViewController?.view)!)
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
                        
                        for dict in dictResponse![ApiKeyConstants.kResult] as? [AnyObject] ?? []{
                            if dict[ApiKeyConstants.kDriverName] != nil{
                                self.popUpTableDataArr.append(dict as? [String : Any] ?? [:])
                            }
                        }
                        self.popupViewHeightConstraints.constant = CGFloat((60 * self.popUpTableDataArr.count) + 85) > self.frame.size.height/2 ? self.frame.size.height/2 : CGFloat((60 * self.popUpTableDataArr.count) + 85)
                        debugPrint("popupheight= Frameheight=",self.popupViewHeightConstraints.constant,self.frame.size.height)
                        self.popupTableView.reloadData()
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                    }
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                }
            }
            else{
                Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
            }
        })
        { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
        }
    }
    
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
            SVProgressHUD.setContainerView((self.window?.rootViewController?.view)!)
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
                        
                        for dict in dictResponse![ApiKeyConstants.kResult] as? [AnyObject] ?? []{
                            if dict[ApiKeyConstants.kDriverName] != nil{
                                self.popUpTableDataArr.append(dict as? [String : Any] ?? [:])
                            }
                        }
                        self.popupViewHeightConstraints.constant = CGFloat((60 * self.popUpTableDataArr.count) + 85) > self.frame.size.height/2 ? self.frame.size.height/2 : CGFloat((60 * self.popUpTableDataArr.count) + 85)
                        debugPrint("popupheight= Frameheight=",self.popupViewHeightConstraints.constant,self.frame.size.height)
                        self.popupTableView.reloadData()
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                    }
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
                }
            }
            else{
                Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
            }
        }){
            (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, (self.window?.rootViewController)!)
        }
    }
}


