//
//  MyTripsDetailsViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 14/03/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Cosmos
import Reachability

class TripDetailsCell : UITableViewCell{
    @IBOutlet weak var bookingIdLabel: UILabel!
    @IBOutlet weak var tripIdLabel: UILabel!
    @IBOutlet weak var tripDetailsImageView: UIImageView!
    @IBOutlet weak var carDetailsTypeLabel: UILabel!
    @IBOutlet weak var fareLabel: UILabel!
    @IBOutlet weak var registrationLabel: UILabel!
    @IBOutlet weak var paymentModeLabel: UILabel!
    @IBOutlet weak var tripImageHeightConstraints: NSLayoutConstraint!
}
class PickUpDropCell : UITableViewCell{
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var tripDetailsImageView: UIImageView!
    @IBOutlet weak var pickUpDropLabel: UILabel!
    @IBOutlet weak var pickUpDropAddressLabel: UILabel!
    @IBOutlet weak var bottomLineLabel: UILabel!
    @IBOutlet weak var locationTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var pickupDropPlaceNameLabel: UILabel!
    @IBOutlet weak var pickDropPlaceNameLabelTopConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var bottomLineTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var bottomLineBottomConstraints: NSLayoutConstraint!
}

class RiderDetailsCell : UITableViewCell{
    @IBOutlet weak var riderImageView: UIImageView!
    @IBOutlet weak var riderNameLabel: UILabel!
    @IBOutlet weak var riderRatingView: CosmosView!
}

class PaymentDetailsCell : UITableViewCell {
    @IBOutlet weak var tripFareLabel: UILabel!
    @IBOutlet weak var tripFareDetailsLabel: UILabel!
    @IBOutlet weak var underlineLabel: UILabel!
    @IBOutlet weak var paymentViewTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var tripFareTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var tripFareBottomConstraints: NSLayoutConstraint!
}

class MyTripsDetailsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var tripDetailsDict = [String : Any]()
    var paymentDetailsArr = [String]()
    @IBOutlet weak var tripDetailsTableView: UITableView!
    
    @IBOutlet weak var helpButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        helpButton.isHidden = true
//        tripImageHeightConstraints.constant = 0
//        paymentDetailsArr = ["RECEIPT","Base Fare","Distance Fare","Time Fare","Service Fee","Discount","Sub Total","HST (13%)","Tips","TOTAL"]
        if ((Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kStatus] as? String ?? "", "drivercanceled")) || (Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kStatus] as? String ?? "", "canceled"))){
            paymentDetailsArr = []
        }
        else{
            paymentDetailsArr = ["RECEIPT","Fare","CO2 Offset","FD Fees","Tip","Sub Total","HST","Toll","Final Payout"]
        }
        debugPrint("Trip Details =",tripDetailsDict)
        // Do any additional setup after loading the view.
    }
    
    // MARK:- Back Button Action-----
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:- Help Button Action-----
    @IBAction func helpButtonTap(_ sender: Any) {
    }
    
    // MARK:- TableView Delegate & DataSource Methods-----
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return UITableView.automaticDimension
        }
        else if indexPath.section == 1{
            if indexPath.row == 0{
                return UITableView.automaticDimension
            }
            else{
                return UITableView.automaticDimension
            }
        }
        else if indexPath.section == 2{
            return 70
        }
        else{
            if indexPath.row == 0 || indexPath.row == 8{
                return 47
            }
            else{
                return 27
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 200
        }
        else if indexPath.section == 1{
            return 45
        }
        else if indexPath.section == 2{
            return 70
        }
        else{
            return 20
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else if section == 1{
            let stops:[[String:Any]] = tripDetailsDict[ApiKeyConstants.kStops] as? [[String : Any]] ?? []
            if stops.count > 0{
                return stops.count + 2
            }
            else{
                return 2
            }
        }
        else if section == 2{
            return 1
        }
        else{
            return paymentDetailsArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let tripDetailsCell : TripDetailsCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kTripDetailsCellId) as! TripDetailsCell
            let fareDetails : [String:Any] = tripDetailsDict[ApiKeyConstants.kTrip_Fare] as? [String : Any] ?? [:]
            let driverPayout : [String:Any] = fareDetails[ApiKeyConstants.kDriverPayment] as? [String : Any] ?? [:]
            let totalFare : Double = driverPayout[ApiKeyConstants.kFinalPayment] as? Double ?? 0.00
            
            tripDetailsCell.bookingIdLabel.text = "Booking Id : \(tripDetailsDict[ApiKeyConstants.kTrip_id] ?? "")"
            tripDetailsCell.fareLabel.text = String(format: "$ %.2f", totalFare)
            
            if (Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kStatus] as? String ?? "", "drivercanceled")){
                tripDetailsCell.paymentModeLabel.text = "Driver Cancelled"
                tripDetailsCell.paymentModeLabel.font = UIFont(name: "Roboto-Light", size:14)
                tripDetailsCell.paymentModeLabel.textColor = Constants.AppColour.kAppLightRedColor
            }
            else if (Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kStatus] as? String ?? "", "canceled")){
                tripDetailsCell.paymentModeLabel.text = "Rider Cancelled"
                tripDetailsCell.paymentModeLabel.font = UIFont(name: "Roboto-Light", size:14)
                tripDetailsCell.paymentModeLabel.textColor = Constants.AppColour.kAppLightRedColor
            }
            
            //        paymentModeLabel.text = "Cash"
            let vehicleInfo = tripDetailsDict[ApiKeyConstants.CarDetails.kVehicleInfo] as? [String:Any]  ?? [:]
            tripDetailsCell.carDetailsTypeLabel.text = ("\(vehicleInfo[ApiKeyConstants.CarDetails.kManufacturer] ?? "")" + " " + "\(vehicleInfo[ApiKeyConstants.CarDetails.kModel] ?? "")")
            tripDetailsCell.tripIdLabel.text = Utility.convertTimeStampToDateTime(timeStamp: tripDetailsDict[ApiKeyConstants.kBookingDateTime] as? Double ?? 0.0)
            tripDetailsCell.registrationLabel.text = "\(vehicleInfo[ApiKeyConstants.CarDetails.kRegistrationNo] ?? "")"
            
            let imageStr = tripDetailsDict[ApiKeyConstants.kImage] as? String ?? ""
            let tripImageUrl = URL(string: tripDetailsDict[ApiKeyConstants.kImage] as? String ?? "")
            if (Utility.isEqualtoString(imageStr, "")){
                tripDetailsCell.tripImageHeightConstraints.constant = 0
            }
            else{
                tripDetailsCell.tripDetailsImageView.kf.indicatorType = .activity
                tripDetailsCell.tripDetailsImageView.kf.setImage(with: tripImageUrl, placeholder: UIImage(named: "mapPlaceHolder"), options: nil, progressBlock: nil) { (result) in
                    tripDetailsCell.tripDetailsImageView.layer.borderColor = UIColor.lightGray.cgColor
                    tripDetailsCell.tripDetailsImageView.contentMode = .scaleToFill
                    tripDetailsCell.tripDetailsImageView.layer.borderWidth = 1.0
                }
            }
            return tripDetailsCell
        }
        else if indexPath.section == 1{
            let pickUpCell : PickUpDropCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kPickDropCellId) as! PickUpDropCell
            
            let stops:[[String:Any]] = tripDetailsDict[ApiKeyConstants.kStops] as? [[String : Any]] ?? []
            if stops.count > 0{
                if stops.count == 1{
                    if indexPath.row == 0{
                        pickUpCell.locationTopConstraints.constant = 20
                        pickUpCell.locationImageView.image = UIImage(named: "userLocation")
                        pickUpCell.pickUpDropLabel.text = "Pick Up Location"
                        if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kPickUpPointName] as? String ?? "", ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kPickUpPointName] as? String ?? "", tripDetailsDict[ApiKeyConstants.kRiderPick_up_address] as? String ?? ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else{
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 5
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = false
                            pickUpCell.pickupDropPlaceNameLabel.text = tripDetailsDict[ApiKeyConstants.kPickUpPointName] as? String ?? ""
                        }
                        pickUpCell.pickUpDropAddressLabel.text = tripDetailsDict[ApiKeyConstants.kRiderPick_up_address] as? String ?? ""
                        pickUpCell.tripDetailsImageView.image = UIImage(named: "pickUpDropImg")
                        pickUpCell.bottomLineLabel.isHidden = true
                        pickUpCell.bottomLineBottomConstraints.constant = 5
                        pickUpCell.bottomLineTopConstraints.constant = 5
                    }
                    else if indexPath.row == 1{
                        pickUpCell.locationTopConstraints.constant = 0
                        pickUpCell.locationImageView.image = UIImage(named: "StopIcon")
                        pickUpCell.pickUpDropLabel.text = "Stop 1"
                        if Utility.isEqualtoString(stops[0][ApiKeyConstants.kDrop_Point_Name] as? String ?? "", ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kDrop_Point_Name] as? String ?? "", tripDetailsDict[ApiKeyConstants.kRiderDrop_Address] as? String ?? ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else{
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 5
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = false
                            pickUpCell.pickupDropPlaceNameLabel.text = stops[0][ApiKeyConstants.kDrop_Point_Name] as? String ?? ""
                        }
                        pickUpCell.pickUpDropAddressLabel.text = stops[0][ApiKeyConstants.kRiderDrop_Address] as? String ?? ""
                        pickUpCell.tripDetailsImageView.image = UIImage(named: "pickUpDropImg")
                        pickUpCell.bottomLineLabel.isHidden = true
                        pickUpCell.bottomLineBottomConstraints.constant = 5
                        pickUpCell.bottomLineTopConstraints.constant = 5
                    }
                    else{
                        pickUpCell.locationTopConstraints.constant = 0
                        pickUpCell.locationImageView.image = UIImage(named: "dropLocation")
                        pickUpCell.pickUpDropLabel.text = "Drop Location"
                        if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kDropPointName] as? String ?? "", ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kDropPointName] as? String ?? "", tripDetailsDict[ApiKeyConstants.kRiderDrop_Address] as? String ?? ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else{
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 5
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = false
                            pickUpCell.pickupDropPlaceNameLabel.text = tripDetailsDict[ApiKeyConstants.kDropPointName] as? String ?? ""
                        }
                        //pickUpCell.pickupDropPlaceNameLabel.text = tripDetailsDict[ApiKeyConstants.kDropPointName] as? String ?? ""
                        pickUpCell.pickUpDropAddressLabel.text = tripDetailsDict[ApiKeyConstants.kRiderDrop_Address] as? String ?? ""
                        pickUpCell.tripDetailsImageView.image = UIImage(named: "")
                        pickUpCell.bottomLineLabel.isHidden = false
                        pickUpCell.bottomLineBottomConstraints.constant = 5
                        pickUpCell.bottomLineTopConstraints.constant = 5
                    }
                }
                else if stops.count == 2{
                    if indexPath.row == 0{
                        pickUpCell.locationTopConstraints.constant = 20
                        pickUpCell.locationImageView.image = UIImage(named: "userLocation")
                        pickUpCell.pickUpDropLabel.text = "Pick Up Location"
                        if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kPickUpPointName] as? String ?? "", ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kPickUpPointName] as? String ?? "", tripDetailsDict[ApiKeyConstants.kRiderPick_up_address] as? String ?? ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else{
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 5
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = false
                            pickUpCell.pickupDropPlaceNameLabel.text = tripDetailsDict[ApiKeyConstants.kPickUpPointName] as? String ?? ""
                        }
                        pickUpCell.pickUpDropAddressLabel.text = tripDetailsDict[ApiKeyConstants.kRiderPick_up_address] as? String ?? ""
                        pickUpCell.tripDetailsImageView.image = UIImage(named: "pickUpDropImg")
                        pickUpCell.bottomLineLabel.isHidden = true
                        pickUpCell.bottomLineBottomConstraints.constant = 5
                        pickUpCell.bottomLineTopConstraints.constant = 5
                    }
                    else if indexPath.row == 1{
                        pickUpCell.locationTopConstraints.constant = 0
                        pickUpCell.locationImageView.image = UIImage(named: "StopIcon")
                        pickUpCell.pickUpDropLabel.text = "Stop 1"
                        if Utility.isEqualtoString(stops[0][ApiKeyConstants.kDrop_Point_Name] as? String ?? "", ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kDrop_Point_Name] as? String ?? "", tripDetailsDict[ApiKeyConstants.kRiderDrop_Address] as? String ?? ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else{
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 5
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = false
                            pickUpCell.pickupDropPlaceNameLabel.text = stops[0][ApiKeyConstants.kDrop_Point_Name] as? String ?? ""
                        }
                        pickUpCell.pickUpDropAddressLabel.text = stops[0][ApiKeyConstants.kRiderDrop_Address] as? String ?? ""
                        pickUpCell.tripDetailsImageView.image = UIImage(named: "pickUpDropImg")
                        pickUpCell.bottomLineLabel.isHidden = true
                        pickUpCell.bottomLineBottomConstraints.constant = 5
                        pickUpCell.bottomLineTopConstraints.constant = 5
                    }
                    else if indexPath.row == 2{
                        pickUpCell.locationTopConstraints.constant = 0
                        pickUpCell.locationImageView.image = UIImage(named: "StopIcon")
                        pickUpCell.pickUpDropLabel.text = "Stop 2"
                        if Utility.isEqualtoString(stops[1][ApiKeyConstants.kDrop_Point_Name] as? String ?? "", ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kDrop_Point_Name] as? String ?? "", tripDetailsDict[ApiKeyConstants.kRiderDrop_Address] as? String ?? ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else{
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 5
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = false
                            pickUpCell.pickupDropPlaceNameLabel.text = stops[1][ApiKeyConstants.kDrop_Point_Name] as? String ?? ""
                        }
                        pickUpCell.pickUpDropAddressLabel.text = stops[1][ApiKeyConstants.kRiderDrop_Address] as? String ?? ""
                        pickUpCell.tripDetailsImageView.image = UIImage(named: "pickUpDropImg")
                        pickUpCell.bottomLineLabel.isHidden = true
                        pickUpCell.bottomLineBottomConstraints.constant = 5
                        pickUpCell.bottomLineTopConstraints.constant = 5
                    }
                    else{
                        pickUpCell.locationTopConstraints.constant = 0
                        pickUpCell.locationImageView.image = UIImage(named: "dropLocation")
                        pickUpCell.pickUpDropLabel.text = "Drop Location"
                        if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kDropPointName] as? String ?? "", ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kDropPointName] as? String ?? "", tripDetailsDict[ApiKeyConstants.kRiderDrop_Address] as? String ?? ""){
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                        }
                        else{
                            pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 5
                            pickUpCell.pickupDropPlaceNameLabel.isHidden = false
                            pickUpCell.pickupDropPlaceNameLabel.text = tripDetailsDict[ApiKeyConstants.kDropPointName] as? String ?? ""
                        }
                        pickUpCell.pickUpDropAddressLabel.text = tripDetailsDict[ApiKeyConstants.kRiderDrop_Address] as? String ?? ""
                        pickUpCell.tripDetailsImageView.image = UIImage(named: "")
                        pickUpCell.bottomLineLabel.isHidden = false
                        pickUpCell.bottomLineBottomConstraints.constant = 5
                        pickUpCell.bottomLineTopConstraints.constant = 5
                    }
                }
            }
            else{
                if indexPath.row == 0{
                    pickUpCell.locationTopConstraints.constant = 20
                    pickUpCell.locationImageView.image = UIImage(named: "userLocation")
                    pickUpCell.pickUpDropLabel.text = "Pick Up Location"
                    if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kPickUpPointName] as? String ?? "", ""){
                        pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                        pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                    }
                    else if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kPickUpPointName] as? String ?? "", tripDetailsDict[ApiKeyConstants.kRiderPick_up_address] as? String ?? ""){
                        pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                        pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                    }
                    else{
                        pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 5
                        pickUpCell.pickupDropPlaceNameLabel.isHidden = false
                        pickUpCell.pickupDropPlaceNameLabel.text = tripDetailsDict[ApiKeyConstants.kPickUpPointName] as? String ?? ""
                    }
                    
                    pickUpCell.pickUpDropAddressLabel.text = tripDetailsDict[ApiKeyConstants.kRiderPick_up_address] as? String ?? ""
                    
                    pickUpCell.tripDetailsImageView.image = UIImage(named: "pickUpDropImg")
                    pickUpCell.bottomLineLabel.isHidden = true
                    pickUpCell.bottomLineBottomConstraints.constant = 0
                    pickUpCell.bottomLineTopConstraints.constant = 5
                }
                else{
                    pickUpCell.locationTopConstraints.constant = 0
                    pickUpCell.locationImageView.image = UIImage(named: "dropLocation")
                    pickUpCell.pickUpDropLabel.text = "Drop Location"
                    if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kDropPointName] as? String ?? "", ""){
                        pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                        pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                    }
                    else if Utility.isEqualtoString(tripDetailsDict[ApiKeyConstants.kDropPointName] as? String ?? "", tripDetailsDict[ApiKeyConstants.kRiderDrop_Address] as? String ?? ""){
                        pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 0
                        pickUpCell.pickupDropPlaceNameLabel.isHidden = true
                    }
                    else{
                        pickUpCell.pickDropPlaceNameLabelTopConstraints.constant = 5
                        pickUpCell.pickupDropPlaceNameLabel.isHidden = false
                        pickUpCell.pickupDropPlaceNameLabel.text = tripDetailsDict[ApiKeyConstants.kDropPointName] as? String ?? ""
                    }
                    pickUpCell.pickUpDropAddressLabel.text = tripDetailsDict[ApiKeyConstants.kRiderDrop_Address] as? String ?? ""
                    pickUpCell.tripDetailsImageView.image = UIImage(named: "")
                    pickUpCell.bottomLineLabel.isHidden = false
                    pickUpCell.bottomLineBottomConstraints.constant = 5
                    pickUpCell.bottomLineTopConstraints.constant = 5
                }
            }
            return pickUpCell
        }
        else if indexPath.section == 2{
            let riderDetails : [String:Any] = tripDetailsDict[ApiKeyConstants.kRider] as? [String : Any] ?? [:]
            let riderDetailsCell : RiderDetailsCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kRiderDetailsCellId) as! RiderDetailsCell
            riderDetailsCell.riderNameLabel.text = (riderDetails[ApiKeyConstants.kDriverName] as? String ?? "").capitalized
            riderDetailsCell.riderRatingView.rating = Double(tripDetailsDict[ApiKeyConstants.kRiderRating] as? Int ?? 0)
            let url = URL(string: riderDetails[ApiKeyConstants.kImage] as? String ?? "")
            riderDetailsCell.riderImageView.kf.indicatorType = .activity
            riderDetailsCell.riderImageView.kf.setImage(with: url, placeholder: UIImage(named: "profileImagePlaceholder"), options: nil, progressBlock: nil) { (result) in
                riderDetailsCell.riderImageView.layer.cornerRadius = riderDetailsCell.riderImageView.frame.height/2
                riderDetailsCell.riderImageView.clipsToBounds = true
                
            }
            return riderDetailsCell
        }
        else{
            /*let paymentCell : PaymentDetailsCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kPaymentCellId) as! PaymentDetailsCell
            
            let fareDetails : [String:Any] = tripDetailsDict[ApiKeyConstants.kTrip_Fare] as? [String : Any] ?? [:]
            
            paymentCell.tripFareLabel.text = paymentDetailsArr[indexPath.row]
            paymentCell.tripFareLabel.font = UIFont(name: "Roboto-Medium", size:12)
            paymentCell.tripFareDetailsLabel.font = UIFont(name: "Roboto-Medium", size:12)
            paymentCell.underlineLabel.backgroundColor = UIColor.clear
            paymentCell.paymentViewTopConstraints.constant = 0
            paymentCell.tripFareTopConstraints.constant = 5
            paymentCell.tripFareBottomConstraints.constant = 5
            
            let subtotal : Double = (fareDetails[ApiKeyConstants.kBaseFare] as? Double ?? 0.00) + (fareDetails[ApiKeyConstants.kFareForKM] as? Double ?? 0.00) + (fareDetails[ApiKeyConstants.kFareForMIN] as? Double ?? 0.00)
            
            let totalFare : Double = (fareDetails[ApiKeyConstants.kChargableAmount] as? Double ?? 0.00) + (tripDetailsDict[ApiKeyConstants.kTipAmount] as? Double ?? 0.00)
            let discount = (fareDetails[ApiKeyConstants.kTotalFare] as? Double ?? 0.00) - (fareDetails[ApiKeyConstants.kChargableAmount] as? Double ?? 0.00)
            
            switch (indexPath.row){
            case 0:
                paymentCell.tripFareTopConstraints.constant = 10
                paymentCell.tripFareBottomConstraints.constant = 10
                paymentCell.paymentViewTopConstraints.constant = 10
                paymentCell.tripFareLabel.font = UIFont(name: "Roboto-Medium", size:15)
                paymentCell.underlineLabel.backgroundColor = Constants.AppColour.kAppLightGreyColor
                break
            case 1:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", fareDetails[ApiKeyConstants.kBaseFare] as? Double ?? 0.00)
                break
            case 2:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", fareDetails[ApiKeyConstants.kFareForKM] as? Double ?? 0.00)
                break
            case 3:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", fareDetails[ApiKeyConstants.kFareForMIN] as? Double ?? 0.00)
                break
            case 4:
                paymentCell.tripFareDetailsLabel.text = "$ 0.00"
                break
            case 5:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", discount)
                break
            case 6:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", subtotal)
                break
            case 7:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", fareDetails[ApiKeyConstants.kTotalTax] as? Double ?? 0.00)
                break
            case 8:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", tripDetailsDict[ApiKeyConstants.kTipAmount] as? Double ?? 0.00)
                paymentCell.underlineLabel.backgroundColor = Constants.AppColour.kAppLightGreyColor
                break
            default:
                paymentCell.tripFareTopConstraints.constant = 10
                paymentCell.tripFareBottomConstraints.constant = 10
                paymentCell.tripFareLabel.font = UIFont(name: "Roboto-Medium", size:15)
                paymentCell.tripFareDetailsLabel.font = UIFont(name: "Roboto-Medium", size:15)
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", totalFare)
                
                break
            }
            return paymentCell*/
            let paymentCell : PaymentDetailsCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kPaymentCellId) as! PaymentDetailsCell

            let fareDetails : [String:Any] = tripDetailsDict[ApiKeyConstants.kTrip_Fare] as? [String : Any] ?? [:]
            let driverPayout : [String:Any] = fareDetails[ApiKeyConstants.kDriverPayment] as? [String : Any] ?? [:]
              paymentCell.tripFareLabel.text = paymentDetailsArr[indexPath.row]
              paymentCell.tripFareLabel.font = UIFont(name: "Roboto-Medium", size:12)
              paymentCell.tripFareDetailsLabel.font = UIFont(name: "Roboto-Medium", size:12)
              paymentCell.underlineLabel.backgroundColor = UIColor.clear
              paymentCell.paymentViewTopConstraints.constant = 0
              paymentCell.tripFareTopConstraints.constant = 5
              paymentCell.tripFareBottomConstraints.constant = 5

//            let subtotal : Double = (fareDetails[ApiKeyConstants.kBaseFare] as? Double ?? 0.00) + (fareDetails[ApiKeyConstants.kFareForKM] as? Double ?? 0.00) + (fareDetails[ApiKeyConstants.kFareForMIN] as? Double ?? 0.00)
//
//            let totalFare : Double = (fareDetails[ApiKeyConstants.kChargableAmount] as? Double ?? 0.00) + (tripDetailsDict[ApiKeyConstants.kTipAmount] as? Double ?? 0.00)
//            let discount = (fareDetails[ApiKeyConstants.kTotalFare] as? Double ?? 0.00) - (fareDetails[ApiKeyConstants.kChargableAmount] as? Double ?? 0.00)

            switch (indexPath.row){
            case 0:
                paymentCell.tripFareTopConstraints.constant = 10
                paymentCell.tripFareBottomConstraints.constant = 10
                paymentCell.paymentViewTopConstraints.constant = 10
                paymentCell.tripFareLabel.font = UIFont(name: "Roboto-Medium", size:15)
                paymentCell.tripFareDetailsLabel.text = ""
                paymentCell.underlineLabel.backgroundColor = Constants.AppColour.kAppLightGreyColor
                break
            case 1:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", driverPayout[ApiKeyConstants.kFare] as? Double ?? 0.00)
                break
            case 2:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", driverPayout[ApiKeyConstants.kCarbonOffsetFee] as? Double ?? 0.00)
                break
            case 3:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", driverPayout[ApiKeyConstants.kFDFees] as? Double ?? 0.00)
                break
            case 4:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", driverPayout[ApiKeyConstants.kTipsAmount] as? Double ?? 0.00)
                break
            case 5:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", driverPayout[ApiKeyConstants.kSubTotal] as? Double ?? 0.00)//subTotal
                break
            case 6:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", driverPayout[ApiKeyConstants.kHST] as? Double ?? 0.00)
                break
            case 7:
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", driverPayout[ApiKeyConstants.kToll] as? Double ?? 0.00)
                paymentCell.underlineLabel.backgroundColor = Constants.AppColour.kAppLightGreyColor
                break

            default:
                paymentCell.tripFareTopConstraints.constant = 10
                paymentCell.tripFareBottomConstraints.constant = 10
//                paymentCell.underlineLabel.backgroundColor = Constants.AppColour.kAppLightGreyColor
                paymentCell.tripFareLabel.font = UIFont(name: "Roboto-Medium", size:15)
                paymentCell.tripFareDetailsLabel.font = UIFont(name: "Roboto-Medium", size:15)
                paymentCell.tripFareDetailsLabel.text = String(format: "$ %.2f", driverPayout[ApiKeyConstants.kFinalPayment] as? Double ?? 0.00)

                break
            }
            return paymentCell
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
