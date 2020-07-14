//
//  CarDetailsPopupViewController.swift
//  Facedriver
//
//  Created by Rajiv Ghosh on 9/3/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Reachability

class CarDetailsPopupViewController: UIViewController {
    
    @IBOutlet weak var tblCarServices: UITableView!
    @IBOutlet weak var constTableHeight: NSLayoutConstraint!
    @IBOutlet weak var constPopupHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblCarName: UILabel!
    @IBOutlet weak var lblCarPlateNumber: UILabel!
    @IBOutlet weak var lblCarColor: UILabel!
    @IBOutlet weak var lblCarRegion: UILabel!
    @IBOutlet weak var baseView: UIView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var tableServicesDataArr = [[String:AnyObject]]()
    var carName = String()
    var carManufractureName = String()
    var regionName = String()
    var plateNumber = String()
    var carColor = String()
    //var callback : ((Bool) -> Void)?
    //var isFromHome : Bool = false
    //var callback : (([String : Bool]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        baseView.layer.cornerRadius = 20.0
        baseView.clipsToBounds = true
        tblCarServices.estimatedRowHeight   = 100.0
        tblCarServices.rowHeight            = UITableView.automaticDimension
        
        self.view.isHidden = true
        self.lblCarName.text                = carManufractureName + " " + carName
        self.lblCarPlateNumber.text         = plateNumber
        self.lblCarColor.text               = carColor
        self.lblCarRegion.text              = regionName
        
        tblCarServices.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.constTableHeight.constant = CGFloat((tableServicesDataArr.count * 40) > 155 ? 155 : (tableServicesDataArr.count * 40))
        self.constPopupHeight.constant = 255.0 + self.constTableHeight.constant
        self.view.layoutIfNeeded()
        self.view.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        //self.callback?(true as Bool)
    }
    
    // MARK:- Back Button Tap
    @IBAction func Click_DismissButton(_ sender: Any) {
        //self.appDelegate.serviceTypePopup = false
        self.dismiss(animated: true)
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

extension CarDetailsPopupViewController : UITableViewDelegate,UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableServicesDataArr.count == 0{
            tableServicesDataArr = [["name" : "NA"]] as [[String : AnyObject]]
            return tableServicesDataArr.count
        }
        else{
            return tableServicesDataArr.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let carCell:MyAccountCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kMyAccountCellId) as! MyAccountCell
        
        let dictCarDetails = tableServicesDataArr[indexPath.row]
        carCell.lblAccountType.text = dictCarDetails["name"] as? String ?? ""
        return carCell
    }
}

