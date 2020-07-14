//
//  CarListViewController.swift
//  FaceDriveDriver
//
//  Created by Rajiv Ghosh on 4/29/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SVProgressHUD
import Reachability


class CarListViewController: UIViewController {

    @IBOutlet weak var addCarButton: UIButton!
    @IBOutlet weak var noaddedCarsView: UIView!
    var carDetailsArray = [[String:Any]]()
    @IBOutlet weak var tableviewCarList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        noaddedCarsView.isHidden = true
        tableviewCarList.estimatedRowHeight = 100.0
        tableviewCarList.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchAddedcarList()
    }
    

    //MARK:- Button Action
    @IBAction func backButtonTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonTap(_ sender: UIButton) {
        let storyBoard = UIStoryboard.init(name: "Profile", bundle: Bundle.main)
        let carDetailsVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kCarDetailsStoryboardId) as! CarDetailsViewController
        carDetailsVC.isFromAddCar = true
        carDetailsVC.isFromPageView = false
        carDetailsVC.addedCarID = ""
        self.show(carDetailsVC, sender: self)
    }
    
    
    //MARK:- Service Call
    
    func fetchAddedcarList() {
        
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        let fetchCarListUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetDriverAddedAllCarList
        
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Fetching Car List...")
        }
        
        APIWrapper.requestGETURL(fetchCarListUrl, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1) {
                    let carsArray = dictResponse![ApiKeyConstants.kResult] as? [[String:Any]] ?? []
                    if carsArray.count > 0 {
                        self.addCarButton.isHidden = false
                        self.noaddedCarsView.isHidden = true
                        self.carDetailsArray = carsArray
                        self.tableviewCarList.reloadData()
                    } else {
                        self.noaddedCarsView.isHidden = false
                        self.addCarButton.isHidden = true
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

extension CarListViewController : UITableViewDataSource {
    
    // MARK:- UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carDetailsArray.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kProfileCarListCell) as! ProfileCarListCell
        
        let carDict = carDetailsArray[indexPath.row]
        cell.carNameLabel.text = String(format:"%@ %@",carDict[ApiKeyConstants.CarDetails.kManufacturer] as? String ?? "", carDict[ApiKeyConstants.CarDetails.kModel] as? String ?? "")
        cell.carDetailsLabel.text = String(format:" | %@ %@ Seater",carDict[ApiKeyConstants.kType] as? String ?? "", carDict[ApiKeyConstants.CarDetails.kSeat] as? String ?? "")
        cell.carListImageView.image = UIImage(named: "nextArrowGrey")
        cell.labelCarNumber.text = carDetailsArray[indexPath.row][ApiKeyConstants.CarDetails.kRegistrationNo] as? String
        if carDict[ApiKeyConstants.kIsApproved] as? Int == 1 {
            cell.carApproveImageView.image = UIImage(named: "verified")
        }
        else {
            cell.carApproveImageView.image = UIImage(named: "alert")
        }
        return cell
    }
}

//MARK:- TableView Delegate Methods -----
extension CarListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let carDict = carDetailsArray[indexPath.row]
        
        let storyBoard = UIStoryboard.init(name: "Profile", bundle: Bundle.main)
        let carDetailsVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kCarDetailsStoryboardId) as! CarDetailsViewController
        carDetailsVC.isFromAddCar = false
        carDetailsVC.isFromPageView = false
        carDetailsVC.addedCarID = carDict[ApiKeyConstants.k_id] as? String ?? ""
        carDetailsVC.carDetails = carDict
        self.show(carDetailsVC, sender: self)
    }
}
