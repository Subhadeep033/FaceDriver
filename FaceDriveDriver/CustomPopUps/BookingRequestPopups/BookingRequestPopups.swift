//
//  BookingRequestPopups.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 01/02/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation
import Kingfisher
import Firebase
import FirebaseDatabase
import Reachability
import Alamofire
import SwiftyJSON

protocol BookingRequestPopupsDelegate {
    func endTrip(isEnd : Bool,tripDetails : [String:Any])
    func changeTripStatusAndUpdateLocation(dropLattitude:String,dropLongitude:String,dropAddress:String,tripStatus:String)
}

//var staticMapCallback : ((UIImage?) -> Void)?

class BookingRequestPopups: UIView {
    var manual = Bool()
//    var isCalledOnce = Bool()
    var bookingObjDelegate : BookingRequestPopupsDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var pendingViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var pendingView: UIView!
    @IBOutlet weak var pickDropNameLabel: UILabel!
    @IBOutlet weak var pickDropLabel: UILabel!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var pickupAddressLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var profileRatingLabel: UILabel!
    @IBOutlet weak var riderNameLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var imageRatingsLabel: UILabel!
    @IBOutlet weak var profileRatingView: UIView!
    @IBOutlet weak var cancelRequestButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bookingPopupBg: UIView!
    @IBOutlet weak var estimatedDistanceLabel: UILabel!
    @IBOutlet weak var estimatedTimeLabel: UILabel!
    //@IBOutlet weak var estimatedEarningLabel: UILabel!
    
    @IBOutlet weak var profileRatingLabelHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var acceptButtonWidthConstraints: NSLayoutConstraint!
    
    //@IBOutlet weak var dollarHeightConstraints: NSLayoutConstraint!
    //@IBOutlet weak var dollarWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var hrsHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var hrsWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var kmWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var kmHeightConstraints: NSLayoutConstraint!
   // @IBOutlet weak var pendingViewlineLabelHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var pendingViewLabelWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var pendingViewTopViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var activityIndDuration: UIActivityIndicatorView!
    @IBOutlet weak var activityIndDistance: UIActivityIndicatorView!
    @IBOutlet weak var constHeightactivityIndDuration: NSLayoutConstraint!
    @IBOutlet weak var constHeightactivityIndDistance: NSLayoutConstraint!
    @IBOutlet weak var lblDistanceUnit: UILabel!
    @IBOutlet weak var lblDurationUnit: UILabel!
    
    var timer: Timer?
    fileprivate var newRequestID = String()
    fileprivate var riderInfoDict = [String : Any]()
    fileprivate var statusOfCurrentTrip = String()
    var bookingRef: DatabaseReference!
    fileprivate var stopDetails = [[String:Any]]()
    fileprivate var isStopsUpdated = Bool()
    fileprivate var endTripApiDict = [String : Any]()
    fileprivate var currentVC = UIViewController()
    class func instanceFromNib(frame : CGRect) -> BookingRequestPopups{
        let bookingPopup = UINib(nibName: "BookingRequestPopups", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! BookingRequestPopups
        bookingPopup.frame = frame
        return bookingPopup
    }
    
    func setupBookingsPopupWithMaintainingStatusOfOngoingTrip(newRequestId:String, riderInfo: [String : Any], tripStatus:String){
        configureDatabase()
        debugPrint("Trip Status= ",tripStatus)
        statusOfCurrentTrip = tripStatus
        if Utility.isEqualtoString(tripStatus, ApiKeyConstants.kIntransit){
            self.appDelegate.startTripTime = UserDefaults.standard.integer(forKey: ApiKeyConstants.kUserDefaults.kStartTime)
        }
        self.newRequestID = newRequestId
        self.riderInfoDict = riderInfo
        self.appDelegate.tripEndAddress = riderInfo[ApiKeyConstants.kRiderDropOffAddress] as? String ?? ""
        cancelRequestButton.isUserInteractionEnabled = true
        self.updatingInitialUI(rider: self.riderInfoDict,tripStatus: tripStatus)
    }
    
    private func configureDatabase()  {
        if self.bookingRef == nil{
            self.bookingRef = Database.database().reference()
        }
        observeChangeInStops()
    }
    
    // MARK:- Observer Function -----
    func observeChangeInStops() {
        debugPrint("Status=",statusOfCurrentTrip)
        var driverDetailsDict = [String : Any]()
        if Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
            driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            
            self.bookingRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kIsTripChanged).observe(.value, with: { (snapshot) in
                if snapshot.exists(){
                    if (snapshot.value! as? Int ?? 0 == 1){
                        self.bookingRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kIsTripChanged).setValue(0)
                        self.bookingRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kRiderInfo).observeSingleEvent(of: .value, with: { (riderSnapshot) in
                            if riderSnapshot.exists(){
                                debugPrint("Rider",riderSnapshot.value!)
                                self.riderInfoDict = riderSnapshot.value! as? [String:Any] ?? [:]
                                let acceptButtonTitle = self.acceptButton.title(for: .normal)
                                self.stopDetails = self.riderInfoDict[ApiKeyConstants.kStops] as? [[String:Any]] ?? []
                                if (Utility.isEqualtoString(acceptButtonTitle!, ApiKeyConstants.kStartTrip)){
                                    self.updatingUIAsDriverArrivedToPickupLocation()
                                }
                                else if (Utility.isEqualtoString(acceptButtonTitle!, ApiKeyConstants.kConfirmStop) || Utility.isEqualtoString(acceptButtonTitle!, ApiKeyConstants.kEndTrip)){
                                    self.updateUIWhenTripStarted()
                                }
                            }
                        })
                    }
                    else{
                    self.bookingRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kRiderInfo).child(ApiKeyConstants.kStops).observe(.value, with: { (snapshot) in
                            if snapshot.exists() {
                                debugPrint("Stop Info :",snapshot.value!)
                                self.stopDetails = snapshot.value! as? [[String:Any]] ?? []
                                debugPrint("Stops",self.stopDetails)
                                self.riderInfoDict[ApiKeyConstants.kStops] = self.stopDetails
                                if(Utility.isEqualtoString(self.statusOfCurrentTrip,ApiKeyConstants.kIntransit)){
                                    self.isStopsUpdated = true
                                    self.updateUIWhenTripStarted()
                                }
                            }
                        })
                    }
                }
//                    Need To Remove --------
                else{
                self.bookingRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kRiderInfo).child(ApiKeyConstants.kStops).observe(.value, with: { (snapshot) in
                        debugPrint("Stop Info :",snapshot.value!)
                        if snapshot.exists() {
                            self.stopDetails = snapshot.value! as? [[String:Any]] ?? []
                            debugPrint("Stops",self.stopDetails)
                            self.riderInfoDict[ApiKeyConstants.kStops] = self.stopDetails
                            if(Utility.isEqualtoString(self.statusOfCurrentTrip,ApiKeyConstants.kIntransit)){
                                self.isStopsUpdated = true
                                self.updateUIWhenTripStarted()
                            }
                        }
                    })
                }
            })
            
      self.bookingRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kStatus).observe(.value, with: { (snapshot) in
                debugPrint("Trip Status :",snapshot.value!)
                if snapshot.exists(){
                    if ((snapshot.value as? String ?? "" == ApiKeyConstants.kCancelled) || (snapshot.value as? String ?? "" == ApiKeyConstants.kRejected)){
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        self.acceptButton.isUserInteractionEnabled = true
                        self.cancelRequestButton.isUserInteractionEnabled = true
                        self.timer?.invalidate()
                        self.bookingObjDelegate?.endTrip(isEnd: false,tripDetails: [:])
                        self.dismiss(animated: true)
                    }
                    else if (snapshot.value as? String ?? "" == ApiKeyConstants.kAccepted){
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        self.acceptButton.isUserInteractionEnabled = true
                        self.cancelRequestButton.isUserInteractionEnabled = true
                        self.timer?.invalidate()
                        self.updatingPopupUI()
                        self.updateBookingPopupConstaints(isShown: false)
                    }
                    else if (snapshot.value as? String ?? "" == ApiKeyConstants.kArrived){
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        self.acceptButton.isUserInteractionEnabled = true
                        self.cancelRequestButton.isUserInteractionEnabled = true
                        self.updatingUIAsDriverArrivedToPickupLocation()
                        self.statusOfCurrentTrip = ApiKeyConstants.kArrived
                    }
                    else if (snapshot.value as? String ?? "" == ApiKeyConstants.kIntransit){
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        self.statusOfCurrentTrip = ApiKeyConstants.kIntransit
                        self.acceptButton.isUserInteractionEnabled = true
                        self.cancelRequestButton.isUserInteractionEnabled = true
                        self.updateUIWhenTripStarted()
                    }
                    else if (snapshot.value as? String ?? "" == ApiKeyConstants.kComplete){
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        self.statusOfCurrentTrip = ApiKeyConstants.kComplete
                        self.acceptButton.isUserInteractionEnabled = true
                        self.cancelRequestButton.isUserInteractionEnabled = true
                        self.acceptButtonWidthConstraints.constant = 110
                        var endTripDict = [String : Any]()
                        endTripDict[ApiKeyConstants.kTripId] = self.newRequestID
                        endTripDict[ApiKeyConstants.kImage] = self.riderInfoDict[ApiKeyConstants.kProfileImage] as? String ?? ""
                        self.bookingObjDelegate?.endTrip(isEnd: true,tripDetails: endTripDict)
                        self.dismiss(animated: true)
                    }
                    else if (snapshot.value as? String ?? "" == ApiKeyConstants.kCompletedByRider){
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        self.statusOfCurrentTrip = ApiKeyConstants.kCompletedByRider
                        self.acceptButton.isUserInteractionEnabled = true
                        self.cancelRequestButton.isUserInteractionEnabled = true
                        var endTripDict = [String : Any]()
                        endTripDict[ApiKeyConstants.kTripId] = self.newRequestID
                        endTripDict[ApiKeyConstants.kImage] = self.riderInfoDict[ApiKeyConstants.kProfileImage] as? String ?? ""
                        self.bookingObjDelegate?.endTrip(isEnd: true,tripDetails: endTripDict)
                        self.dismiss(animated: true)
                    }
                }
            })
        }
    }
    
    // MARK:- Call Button Action-----
    @IBAction func callButtonTap(_ sender: Any) {
        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        if (Reachibility.isConnectedToNetwork()){
            DispatchQueue.global(qos: .background).async {
                self.maskCallApi()
            }
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
        }
    }
    
    // MARK:- Accept Request Button Action-----
    @IBAction func acceptRideButtonTap(_ sender: UIButton) {
        debugPrint("Accept Button clicked")
        self.cancelRequestButton.isUserInteractionEnabled = false
        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        if(Reachibility.isConnectedToNetwork()){
            let buttonTitle = sender.title(for: .normal)
            if(Utility.isEqualtoString(
                buttonTitle! , ApiKeyConstants.k_Arrived)){
                let arriveTripAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kArrivedTripAlert, preferredStyle: .alert)
                arriveTripAlert.view.tintColor = Constants.AppColour.kAppGreenColor
                let OkAction = UIAlertAction(title: Constants.AppAlertAction.kYESButton, style: .default) { (alert) in
                    SVProgressHUD.setContainerView(currentVC.view)
                    SVProgressHUD.show(withStatus: "Please Wait...")
                    self.acceptButton.isUserInteractionEnabled = false
                    self.cancelRequestButton.isUserInteractionEnabled = false
                    self.tripStatusChange(tripStatus: buttonTitle!.lowercased())
                }
                let cancelAction = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default) { (alert) in
                    self.acceptButton.isUserInteractionEnabled = true
                    self.cancelRequestButton.isUserInteractionEnabled = true
                    arriveTripAlert.dismiss(animated: true, completion: nil)
                }
                arriveTripAlert.addAction(cancelAction)
                arriveTripAlert.addAction(OkAction)
                currentVC.present(arriveTripAlert, animated: true, completion: nil)
            }
            else if(Utility.isEqualtoString(
                buttonTitle! , ApiKeyConstants.kStartTrip)){
                let startTripAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kStartTripAlert, preferredStyle: .alert)
                startTripAlert.view.tintColor = Constants.AppColour.kAppGreenColor
                let OkAction = UIAlertAction(title: Constants.AppAlertAction.kYESButton, style: .default) { (alert) in
                    SVProgressHUD.setContainerView(currentVC.view)
                    SVProgressHUD.show(withStatus: "Please Wait...")
                    
                    self.acceptButton.isUserInteractionEnabled = false
                    self.cancelRequestButton.isUserInteractionEnabled = false
                    self.appDelegate.startTripTime = Utility.currentTimeInMiliseconds()
                    UserDefaults.standard.set(self.appDelegate.startTripTime, forKey: ApiKeyConstants.kUserDefaults.kStartTime)
                    self.appDelegate.startTriplattitude = self.appDelegate.lattitude
                    UserDefaults.standard.set(self.appDelegate.startTriplattitude, forKey: ApiKeyConstants.kUserDefaults.kStartTripLattitude)
                    self.appDelegate.startTriplongitude = self.appDelegate.longitude
                    UserDefaults.standard.set(self.appDelegate.startTriplongitude, forKey: ApiKeyConstants.kUserDefaults.kStartTripLongitude)
                
//                let myStartLocation = CLLocation(latitude: Double(appDelegate.startTriplattitude)! , longitude: Double(appDelegate.startTriplongitude)!)
                    let dict : [String : Any] = [ApiKeyConstants.kLat : Double(self.appDelegate.startTriplattitude)!, ApiKeyConstants.klongitude : Double(self.appDelegate.startTriplongitude)!]
                    self.appDelegate.routeLocationArr.insert(dict as AnyObject, at: 0)
                        UserDefaults.standard.set(self.appDelegate.routeLocationArr, forKey: ApiKeyConstants.kUserDefaults.kTripLocation)
                
                    debugPrint("Start Time=",self.appDelegate.startTripTime)
                    self.tripStatusChange(tripStatus: ApiKeyConstants.kIntransit)
                }
                let cancelAction = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default) { (alert) in
                    self.acceptButton.isUserInteractionEnabled = true
                    self.cancelRequestButton.isUserInteractionEnabled = true
                    startTripAlert.dismiss(animated: true, completion: nil)
                }
                startTripAlert.addAction(cancelAction)
                startTripAlert.addAction(OkAction)
                currentVC.present(startTripAlert, animated: true, completion: nil)
            }
            else if(Utility.isEqualtoString(buttonTitle!,ApiKeyConstants.kConfirmStop)){
//                observeChangeInStops()
//                let stopDetails = self.riderInfoDict["stops"] as! [[String:Any]]
                let confirmStopAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kConfirmStopAlert, preferredStyle: .alert)
                confirmStopAlert.view.tintColor = Constants.AppColour.kAppGreenColor
                let OkAction = UIAlertAction(title: Constants.AppAlertAction.kYESButton, style: .default) { (alert) in
                    SVProgressHUD.setContainerView(currentVC.view)
                    SVProgressHUD.show(withStatus: "Please Wait...")
                    
                    self.acceptButton.isUserInteractionEnabled = false
                    self.cancelRequestButton.isUserInteractionEnabled = false
                    var flagStatus = Bool()
                    var nextStop = [String:Any]()
                    var placeId = String()
                        for stops in self.stopDetails{
                            if !Utility.isEqualtoString(stops[ApiKeyConstants.kStatus] as? String ?? "", ApiKeyConstants.kComplete){
                                flagStatus = true
                                nextStop = stops
                                debugPrint(stops)
                                break
                            }
                            else{
                                flagStatus = false
                                nextStop = [:]
                            }
                        }
                        if flagStatus == true{
                            placeId = nextStop[ApiKeyConstants.kDropPlaceID]! as? String ?? ""
                            debugPrint("Place Id =",placeId)
                            DispatchQueue.global(qos: .background).async {
                                self.stopStatusChangeApi(placeID: placeId, stopStatus: ApiKeyConstants.kComplete)
                            }
                        }
                }
                let cancelAction = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default) { (alert) in
                    self.acceptButton.isUserInteractionEnabled = true
                    self.cancelRequestButton.isUserInteractionEnabled = true
                    confirmStopAlert.dismiss(animated: true, completion: nil)
                }
                
                confirmStopAlert.addAction(cancelAction)
                confirmStopAlert.addAction(OkAction)
                currentVC.present(confirmStopAlert, animated: true, completion: nil)
            }
            else if(Utility.isEqualtoString(
                buttonTitle! , ApiKeyConstants.kEndTrip)){
                
                self.manupulatingDataForEndTrip()
            }
            else{
                self.acceptButton.isUserInteractionEnabled = false
                self.cancelRequestButton.isUserInteractionEnabled = false
                DispatchQueue.global(qos: .background).async {
                    self.bookingAcceptRejectApi(requestId: self.newRequestID, acceptReject: true)
                }
            }
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
        }
    }
    
    // MARK:- Cancel Request Button Action-----
    @IBAction func cancelRequestButtonTap(_ sender: UIButton) {
        self.acceptButton.isUserInteractionEnabled = false
        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        if(Reachibility.isConnectedToNetwork()){
            let buttonTitle = sender.title(for: .normal)
            if(Utility.isEqualtoString(
                buttonTitle! , ApiKeyConstants.kEndTrip)){
                self.manupulatingDataForEndTrip()
            }
            else if(Utility.isEqualtoString(
                buttonTitle! , ApiKeyConstants.kCancel)){
                let cancelTripAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kCancelTripAlert, preferredStyle: .alert)
                cancelTripAlert.view.tintColor = Constants.AppColour.kAppGreenColor
                let OkAction = UIAlertAction(title: Constants.AppAlertAction.kYESButton, style: .default) { (alert) in
                    SVProgressHUD.setContainerView(currentVC.view)
                    SVProgressHUD.show(withStatus: "Please Wait...")
                    self.acceptButton.isUserInteractionEnabled = false
                    self.cancelRequestButton.isUserInteractionEnabled = false
                    DispatchQueue.global(qos: .background).async {
                        self.cancelRideApi(requestId: self.newRequestID)
                    }
                }
                let cancelAction = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default) { (alert) in
                    self.acceptButton.isUserInteractionEnabled = true
                    self.cancelRequestButton.isUserInteractionEnabled = true
                    cancelTripAlert.dismiss(animated: true, completion: nil)
                }
                cancelTripAlert.addAction(cancelAction)
                cancelTripAlert.addAction(OkAction)
                currentVC.present(cancelTripAlert, animated: true, completion: nil)
            }
            else{
                // Reject Trip ---- (OR When Button Title is Reject)
                self.acceptButton.isUserInteractionEnabled = false
                self.cancelRequestButton.isUserInteractionEnabled = false
                manual = true
                DispatchQueue.global(qos: .background).async {
                    self.bookingAcceptRejectApi(requestId: self.newRequestID, acceptReject: false)
                }
            }
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
        }
    }
    
    private func manupulatingDataForEndTrip(){
        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        let endTripAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kEndTripAlert, preferredStyle: .alert)
        endTripAlert.view.tintColor = Constants.AppColour.kAppGreenColor
        let OkAction = UIAlertAction(title: Constants.AppAlertAction.kYESButton, style: .default) { (alert) in
            SVProgressHUD.setContainerView(currentVC.view)
            SVProgressHUD.show(withStatus: "Please Wait...")
            
            self.acceptButton.isUserInteractionEnabled = false
            self.cancelRequestButton.isUserInteractionEnabled = false
            self.appDelegate.endTripTime = Utility.currentTimeInMiliseconds()
            UserDefaults.standard.set(self.appDelegate.endTripTime, forKey: ApiKeyConstants.kUserDefaults.kEndTime)
            self.appDelegate.dropTriplattitude = self.appDelegate.endTriplattitude
            self.appDelegate.dropTriplongitude = self.appDelegate.endTriplongitude
            self.appDelegate.endTriplattitude = self.appDelegate.lattitude
            UserDefaults.standard.set(self.appDelegate.endTriplattitude, forKey: ApiKeyConstants.kUserDefaults.kEndTripLattitude)
            self.appDelegate.endTriplongitude = self.appDelegate.longitude
            UserDefaults.standard.set(self.appDelegate.endTriplongitude, forKey: ApiKeyConstants.kUserDefaults.kEndTripLongitude)
            debugPrint("End Time=",self.appDelegate.endTripTime)
            //                let myEndLocation = CLLocation(latitude: Double(appDelegate.endTriplattitude)! , longitude: Double(appDelegate.endTriplongitude)!)
            let dict : [String : Double] = [ApiKeyConstants.kLat : Double(self.appDelegate.endTriplattitude)!, ApiKeyConstants.klongitude : Double(self.appDelegate.endTriplongitude)!]
            self.appDelegate.routeLocationArr += [dict as AnyObject]
            UserDefaults.standard.set(self.appDelegate.routeLocationArr, forKey: ApiKeyConstants.kUserDefaults.kTripLocation)
            self.tripStatusChange(tripStatus: ApiKeyConstants.kComplete)
            
            endTripAlert.dismiss(animated: true, completion: nil)
            
        }
        let cancelAction = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default) { (alert) in
            self.acceptButton.isUserInteractionEnabled = true
            self.cancelRequestButton.isUserInteractionEnabled = true
            endTripAlert.dismiss(animated: true, completion: nil)
        }
        endTripAlert.addAction(cancelAction)
        endTripAlert.addAction(OkAction)
        currentVC.present(endTripAlert, animated: true, completion: nil)
    }
}

extension BookingRequestPopups {
    // MARK : Popup show method-----
    func show(animated:Bool){
        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        self.bookingPopupBg.center = self.center
        currentVC.view.addSubview(self)
        
        if animated {
            debugPrint("Self Height =",self.frame.height)
            self.frame.origin.y = (currentVC.view.frame.height) - self.frame.height
            if Utility.isEqualtoString(statusOfCurrentTrip, ApiKeyConstants.kPending){
                self.updateBookingPopupConstaints(isShown: true)
            }
            else{
                self.updateBookingPopupConstaints(isShown: false)
            }
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromTop
            self.layer.add(transition, forKey: nil)

        }else{
            
            self.frame.origin.y = (currentVC.view.frame.height) - self.frame.height
        }
        
    }
    
    // MARK:- Update XIB Constraints & Frame Methods-----
    func updateBookingPopupConstaints(isShown: Bool){
        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: 270)
        self.frame.origin.y = (currentVC.view.frame.height) - (self.frame.height + 20)
        
        /*self.pendingView.isHidden = true
        pendingViewHeightConstraints.constant = 0.0
        //dollarHeightConstraints.constant = 0.0
        //dollarWidthConstraints.constant = 0.0
        hrsHeightConstraints.constant = 0.0
        hrsWidthConstraints.constant = 0.0
        kmWidthConstraints.constant = 0.0
        kmHeightConstraints.constant = 0.0
        //pendingViewlineLabelHeightConstraints.constant = 0.0
        pendingViewLabelWidthConstraints.constant = 0.0
        pendingViewTopViewHeightConstraints.constant = 0.0*/
        
        if isShown {
            
            var arr_ETA = [Int]()
            var totalETA = Int()
            
            var arr_Distance = [Int]()
            var totalDistance = Int()
            
            self.pendingView.isHidden = false
            pendingViewHeightConstraints.constant = 70.0
            //dollarHeightConstraints.constant = 12.0
            //dollarWidthConstraints.constant = 9.0
            hrsHeightConstraints.constant = 12.0
            hrsWidthConstraints.constant = 25.0
            kmWidthConstraints.constant = 16.0
            kmHeightConstraints.constant = 12.0
            //pendingViewlineLabelHeightConstraints.constant = 1.0
            pendingViewLabelWidthConstraints.constant = 1.0
            pendingViewTopViewHeightConstraints.constant = 1.0
            constHeightactivityIndDistance.constant = 25.0
            constHeightactivityIndDuration.constant = 25.0
            
            self.lblDistanceUnit.isHidden = true
            self.lblDurationUnit.isHidden = true
            self.estimatedDistanceLabel.isHidden = true
            self.estimatedDistanceLabel.isHidden = true
            
            self.activityIndDistance.startAnimating()
            self.activityIndDuration.startAnimating()
            
            self.activityIndDistance.isHidden = false
            self.activityIndDuration.isHidden = false
            
            

            
            let parameters : [String : String] = ["key" : Constants.SocialLoginKeys.kGoogleMapsApiKey, "sensor" : "false", "mode" : "driving", "origin" : "\(appDelegate.lattitude),\(appDelegate.longitude)", "destination" : "\(appDelegate.pickUpLattitude),\(appDelegate.pickUpLongitude)"]
                let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?")

                Alamofire.request(url!, method:.get, parameters: parameters)
                    .validate(contentType: ["application/json"])
                    .responseJSON { response in
                        
                        guard let jsonResponce = try? JSON(data: response.data!) else {
                            //                failure("error")
                            //print("Error:-----------------",response)
                            return
                        }
                        let routes = jsonResponce["routes"].arrayValue
                        
                        if routes.count > 0
                        {
                            for (index, element) in routes.enumerated() {
                                
                                let dicInfo = element.dictionary
                                
                                let secondArr = dicInfo?["legs"]?.arrayValue
                                let thirdLayerDic = secondArr?[index].dictionary
                                let durationDic = thirdLayerDic?["duration"]
                                let distanceDic = thirdLayerDic?["distance"]
                                
                                
                                // let eta = finalDic?["text"].stringValue
                                
                                arr_ETA.append(durationDic?["value"].intValue ?? 0)
                                arr_Distance.append(distanceDic?["value"].intValue ?? 0)
                               
                                
                            }
                            
                            for etaValue in arr_ETA {
                                totalETA += etaValue
                            }
                            for distanceValue in arr_Distance {
                                totalDistance += distanceValue
                            }
                            
                            
                            let minutes = (totalETA / 60) % 60;
                            let hours = totalETA / 3600;
                                                        
                            //var duration = Double(totalETA)/3600
                            let distance = Double(totalDistance)/1000
                            
                            self.activityIndDuration.stopAnimating()
                            self.estimatedTimeLabel.text        = hours == 0 ? String(minutes) : String(format:"%02d:%02d", hours, minutes)
                            self.estimatedDistanceLabel.text    = String(format: "%.2f", distance)
                            
                            self.lblDurationUnit.text =  hours == 0 ? "mins" : "hrs"
                            self.lblDistanceUnit.isHidden = false
                            self.lblDurationUnit.isHidden = false
                            self.estimatedDistanceLabel.isHidden = false
                            self.estimatedDistanceLabel.isHidden = false
                            
                            self.activityIndDistance.stopAnimating()
                            self.activityIndDuration.stopAnimating()
                            
                            self.activityIndDistance.isHidden = true
                            self.activityIndDuration.isHidden = true
                            
                        }
                        
                    }
            
            
            let estimatedTime = self.riderInfoDict["estimatedTime"] as? Int ?? 0
            var hrs = 00
            var mins = 00
            if estimatedTime >= 60{
                hrs = estimatedTime/60
                mins = estimatedTime%60
            }
            else{
                hrs = 00
                mins = estimatedTime
            }
            estimatedTimeLabel.text = String(format: "%d:%d", hrs,mins)
           // estimatedEarningLabel.text = String(format: "%.2f", self.riderInfoDict["estimatedEarn"] as? Double ?? 0.0)
            estimatedDistanceLabel.text = String(format: "%.2f", self.riderInfoDict["estimatedDistance"] as? Double ?? 0.0)
        }
        else{
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: 190)
            self.frame.origin.y = (self.window?.rootViewController?.view.frame.height)! - (self.frame.height + 20)
            self.pendingView.isHidden = true
            pendingViewHeightConstraints.constant = 0.0
            //dollarHeightConstraints.constant = 0.0
            //dollarWidthConstraints.constant = 0.0
            hrsHeightConstraints.constant = 0.0
            hrsWidthConstraints.constant = 0.0
            kmWidthConstraints.constant = 0.0
            kmHeightConstraints.constant = 0.0
            //pendingViewlineLabelHeightConstraints.constant = 0.0
            pendingViewLabelWidthConstraints.constant = 0.0
            pendingViewTopViewHeightConstraints.constant = 0.0
            constHeightactivityIndDistance.constant = 0.0
            constHeightactivityIndDuration.constant = 0.0
        }
    }
    
    // MARK:- Popup dismiss Methods-----
    func dismiss(animated:Bool){
        self.appDelegate.bookingPopUpCount = 0
        
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIView.AnimationOptions(rawValue: 0), animations: {

                self.frame.origin.y = self.frame.origin.y + self.frame.height
                let transition = CATransition()
                    transition.duration = 0.5
                    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
                    transition.type = CATransitionType.reveal
                    transition.subtype = CATransitionSubtype.fromBottom
                    self.layer.add(transition, forKey: nil)
            }, completion: { (completed) in
                self.removeAllObserversWhenDismissPopup()
                self.removeFromSuperview()
            })
        }else{
            self.removeAllObserversWhenDismissPopup()
            self.bookingPopupBg.removeFromSuperview()
            self.removeFromSuperview()
        }
        
    }
    
    // MARK:- Remove All Observers ------
    func removeAllObserversWhenDismissPopup(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        if self.bookingRef != nil{
            self.bookingRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kIsTripChanged).removeAllObservers()
            self.bookingRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kRiderInfo).child(ApiKeyConstants.kStops).removeAllObservers()
            self.bookingRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as?
                String ?? "").child(ApiKeyConstants.kStatus).removeAllObservers()
        }
    }
    
    // MARK:- Stop status change api Methods-----
    func stopStatusChangeApi(placeID:String, stopStatus:String){
        //var currentVC = UIViewController()
        DispatchQueue.main.async {
            self.currentVC = UIApplication.getTopMostViewController()!
        }
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        let stopStatusApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kChangeMultipleStopStatus
        let dictBodyParams : [String : AnyObject] = [ApiKeyConstants.kTrip_id : self.newRequestID as AnyObject,ApiKeyConstants.kPlace_Id : placeID as AnyObject,ApiKeyConstants.kStop_Status : stopStatus as AnyObject]
        debugPrint("Params=",dictBodyParams)
        Utility.removeAppCookie()
        APIWrapper.requestPUTURL(stopStatusApi, params: dictBodyParams as [String : AnyObject], headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
//                         self.observeChangeInStops()
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                            DispatchQueue.main.async {
//                                SVProgressHUD.dismiss()
//                            }
//                            self.acceptButton.isUserInteractionEnabled = true
//                        }
                        
                    }
                    else{
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                    }
                    
                }
            }
            else{
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                }
                
            }
            
        })
        { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
            }
            
        }
    }
    
    // MARK:- Booking Cancel Api Methods-----
    func cancelRideApi(requestId : String){
        //var currentVC = UIViewController()
        debugPrint("Cancel Ride Api called")
        DispatchQueue.main.async {
            self.currentVC = UIApplication.getTopMostViewController()!
            SVProgressHUD.setContainerView(self.currentVC.view)
            SVProgressHUD.show(withStatus: "Please Wait...")
        }
        if Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
            
            let authToken = "Bearer " + token
            let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
            let cancelApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kCancelRide
            let dictBodyParams : [String : AnyObject] = [ApiKeyConstants.kTrip_id : requestId as AnyObject]
            Utility.removeAppCookie()
            APIWrapper.requestPOSTURL(cancelApi, params: dictBodyParams, headers: dictHeaderParams, success: { (JSONResponse) in
                let jsonValue = JSONResponse
                let dictResponse = jsonValue.dictionaryObject
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                
                debugPrint(dictResponse!)
                if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                        if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                            /*self.acceptButton.isUserInteractionEnabled = true
                            self.cancelRequestButton.isUserInteractionEnabled = true
                            self.bookingObjDelegate?.endTrip(isEnd: false,tripDetails: [:])
                            self.dismiss(animated: true)*/
                        }
                        else{
                            DispatchQueue.main.async {
                                self.acceptButton.isUserInteractionEnabled = true
                                self.cancelRequestButton.isUserInteractionEnabled = true
                                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                            }
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.acceptButton.isUserInteractionEnabled = true
                            self.cancelRequestButton.isUserInteractionEnabled = true
                            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.acceptButton.isUserInteractionEnabled = true
                        self.cancelRequestButton.isUserInteractionEnabled = true
                        Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                    }
                }
                
            }) { (error) -> Void in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.acceptButton.isUserInteractionEnabled = true
                    self.cancelRequestButton.isUserInteractionEnabled = true
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                }
                
            }
        }
    }
    
    // MARK:- Booking Accept Reject Api Methods-----
    func bookingAcceptRejectApi(requestId : String, acceptReject : Bool) {
        debugPrint("Accept Reject Api called")
        self.appDelegate.stopSound()
        if timer?.isValid == true{
            timer?.invalidate()
        }
        DispatchQueue.main.async {
            self.currentVC = UIApplication.getTopMostViewController()!
            SVProgressHUD.setContainerView(self.currentVC.view)
            SVProgressHUD.show(withStatus: "Please Wait...")
        }
        if Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
            
            let authToken = "Bearer " + token
            let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
            let acceptRejectApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kAcceptRejectApi
            let dictBodyParams : [String : AnyObject] = [ApiKeyConstants.kNew_Request_Id : requestId as AnyObject,ApiKeyConstants.kIsAccept : acceptReject as AnyObject,ApiKeyConstants.kManual : manual as AnyObject]
            Utility.removeAppCookie()
            APIWrapper.requestPUTURL(acceptRejectApi, params: dictBodyParams as [String : AnyObject], headers: dictHeaderParams, success: { (JSONResponse) in
                let jsonValue = JSONResponse
                let dictResponse = jsonValue.dictionaryObject
                
                
                debugPrint(dictResponse!)
                if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                        if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                            if(Utility.isEqualtoString(dictResponse![ApiKeyConstants.kMessage] as? String ?? "",ApiKeyConstants.kAccepted)){
                                /*self.acceptButton.isUserInteractionEnabled = true
                                self.cancelRequestButton.isUserInteractionEnabled = true
                                self.timer?.invalidate()
                                self.updatingPopupUI()
                                self.updateBookingPopupConstaints(isShown: false)*/
                            }
                            else if(Utility.isEqualtoString(dictResponse![ApiKeyConstants.kMessage] as? String ?? "",ApiKeyConstants.kRejected)){
                                /*self.acceptButton.isUserInteractionEnabled = true
                                self.cancelRequestButton.isUserInteractionEnabled = true
                                self.timer?.invalidate()
                                self.bookingObjDelegate?.endTrip(isEnd: false,tripDetails: [:])
                                self.dismiss(animated: true)*/
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                self.acceptButton.isUserInteractionEnabled = true
                                self.cancelRequestButton.isUserInteractionEnabled = true
                                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? "", Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                            }
                            
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            self.acceptButton.isUserInteractionEnabled = true
                            self.cancelRequestButton.isUserInteractionEnabled = true
                            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.acceptButton.isUserInteractionEnabled = true
                        self.cancelRequestButton.isUserInteractionEnabled = true
                        Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                    }
                    
                }
            })
            { (error) -> Void in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.acceptButton.isUserInteractionEnabled = true
                    self.cancelRequestButton.isUserInteractionEnabled = true
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                }
            }
        }
    }
    
    // MARK:- Trip Status Change -----
    func tripStatusChange(tripStatus : String) -> Void {
        //let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        var dictBodyParamsForTripStatus = [String : AnyObject]()
        if(Utility.isEqualtoString(tripStatus, ApiKeyConstants.kComplete)){
//            let diff = Int(self.appDelegate.endTripTime - self.appDelegate.startTripTime)
//            let minutes = Int(diff / 60000)
//            let encodedPolyLineString = ""
//            let tripLocations = UserDefaults.standard.array(forKey: ApiKeyConstants.kUserDefaults.kTripLocation)
//            debugPrint("Trip Locations Arr =",tripLocations ?? [])
            //Utility.getEncodedStringWithCoordinates(locationPoint: ((tripLocations as AnyObject) as? [AnyObject] ?? []), completion: { (success) in
                    //encodedPolyLineString = success
                    //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: encodedPolyLineString, Button_Title: "OK", currentVC)
            
//                    let distanceInMeters = Utility.distanceOfTrip(locationPoints: ((tripLocations as AnyObject) as? [AnyObject] ?? []))
//                    let distanceInKm = distanceInMeters.rounded()/1000
//                    debugPrint("Distance= EncodedString=",distanceInKm,encodedPolyLineString)
            
//                    let centerLat : Double = (Double(self.appDelegate.pickUpLattitude)! + Double(self.appDelegate.dropTriplattitude)!)/2
//                    let centerLong : Double = (Double(self.appDelegate.pickUpLongitude)! + Double(self.appDelegate.dropTriplongitude)!)/2
//                    let latLongDict = ["pickUpLatLong":["lat" : Double(self.appDelegate.pickUpLattitude)!,"longitude" : Double(self.appDelegate.pickUpLongitude)!],"centerLatLong":["lat" : centerLat,"longitude" : centerLong],"dropLatLong":["lat" : Double(self.appDelegate.dropTriplattitude)!,"longitude" : Double(self.appDelegate.dropTriplongitude)!]]
//                    debugPrint("LatLong ---------",latLongDict)
                
                    let pickUpPoint = [ApiKeyConstants.kType : ApiKeyConstants.kPoint,ApiKeyConstants.kCoordinates : [self.appDelegate.startTriplongitude,self.appDelegate.startTriplattitude]] as [String : Any]
                    let dropPoint = [ApiKeyConstants.kType : ApiKeyConstants.kPoint,ApiKeyConstants.kCoordinates : [self.appDelegate.longitude,self.appDelegate.lattitude]] as [String : Any]
                
                    let pickUpPointStr = Utility.convertToJsonString(dic:pickUpPoint)
                    let dropPointStr = Utility.convertToJsonString(dic:dropPoint)
                
                    dictBodyParamsForTripStatus = [ApiKeyConstants.kTripStatus : tripStatus as String, ApiKeyConstants.kTrip_id : self.newRequestID as String,ApiKeyConstants.kRiderPickup_point : pickUpPointStr,ApiKeyConstants.kRiderDrop_Point : dropPointStr,ApiKeyConstants.kRiderPickup_Address : self.appDelegate.pickUpAddress,ApiKeyConstants.kRiderDrop_Address : self.appDelegate.dropAddress/*,ApiKeyConstants.kTotal_km : distanceInKm as Double,ApiKeyConstants.kTotal_time : minutes, ApiKeyConstants.kDriverPloy_Line : encodedPolyLineString*/] as [String : AnyObject]
                    debugPrint("Body Params For Completed Trip =",dictBodyParamsForTripStatus)
                    DispatchQueue.global(qos: .background).async {
                        self.tripStatusChangedApiCalled(paramDict: dictBodyParamsForTripStatus)
                    }
                    //self.endTripApiCalled(paramDict: dictBodyParamsForTripStatus, tripImage: UIImage(named: "mapPlaceHolder")!)
                //})
        }
        else if(Utility.isEqualtoString(tripStatus, ApiKeyConstants.kArrived)){
            self.appDelegate.arrivedTime = Utility.currentTimeInMiliseconds()
            UserDefaults.standard.set(self.appDelegate.arrivedTime, forKey: ApiKeyConstants.kUserDefaults.kArrivedTime)

            let arrivedTripTime = Int(self.appDelegate.arrivedTime - self.appDelegate.acceptTime)
            let arrivedMins = Int(arrivedTripTime/60000)
            
            let arrivedLocations = UserDefaults.standard.array(forKey: ApiKeyConstants.kUserDefaults.kPickUpLocation)
            var arrivedDistanceInMeters : Double = 0.0
            var arrivedDistanceInKm : Double = 0.0
            if arrivedLocations != nil {
                arrivedDistanceInMeters = Utility.distanceOfTrip(locationPoints: ((arrivedLocations as AnyObject) as! [AnyObject]))
                arrivedDistanceInKm = arrivedDistanceInMeters.rounded()/1000
            }
            
            dictBodyParamsForTripStatus = [ApiKeyConstants.kTripStatus : tripStatus as String, ApiKeyConstants.kTrip_id : self.newRequestID as String,ApiKeyConstants.kArrived_km : arrivedDistanceInKm as Double, ApiKeyConstants.kArrived_time : arrivedMins] as [String : AnyObject]
            DispatchQueue.global(qos: .background).async {
                self.tripStatusChangedApiCalled(paramDict: dictBodyParamsForTripStatus)
            }
        }
        else{
            dictBodyParamsForTripStatus = [ApiKeyConstants.kTripStatus : tripStatus as String, ApiKeyConstants.kTrip_id : self.newRequestID as String] as [String : AnyObject]
            DispatchQueue.global(qos: .background).async {
                self.tripStatusChangedApiCalled(paramDict: dictBodyParamsForTripStatus)
            }
        }
    }
    
    /*func endTripApiCalled(paramDict : [String : AnyObject],tripImage : UIImage){
        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        let tripStatusApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kTripStatusApi
        debugPrint(tripStatusApi)
        Utility.removeAppCookie()
        
        let jpegdata = tripImage.jpegData(compressionQuality: 0.75)
        APIWrapper.requestPUTMultipartWith(tripStatusApi, imageData: jpegdata, parameters: paramDict, headers: dictHeaderParams, success: { (JSONResponse) in
            
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint("End Trip Response =",dictResponse!)
            
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        //self.endTripApiDict = dictResponse!
                    }
                    else{
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        self.acceptButton.isUserInteractionEnabled = true
                        self.cancelRequestButton.isUserInteractionEnabled = true
                        //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
                    }
                }
                else{
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    self.acceptButton.isUserInteractionEnabled = true
                    self.cancelRequestButton.isUserInteractionEnabled = true
                    //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
                }
            }
            else{
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                self.acceptButton.isUserInteractionEnabled = true
                self.cancelRequestButton.isUserInteractionEnabled = true
                Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
            }
        }) { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            self.acceptButton.isUserInteractionEnabled = true
            self.cancelRequestButton.isUserInteractionEnabled = true
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
        }
    }*/
    
    func tripStatusChangedApiCalled(paramDict : [String : AnyObject]){
        //var currentVC = UIViewController()
        DispatchQueue.main.async {
            self.currentVC  = UIApplication.getTopMostViewController()!
        }
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        let tripStatusApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kTripStatusApi
        debugPrint(tripStatusApi)
        
        Utility.removeAppCookie()
        APIWrapper.requestPUTURL(tripStatusApi, params: paramDict as [String : AnyObject], headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            
            
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        /*if(Utility.isEqualtoString(dictResponse![ApiKeyConstants.kMessage] as? String ?? "",ApiKeyConstants.kArrived)){
                            self.acceptButton.isUserInteractionEnabled = true
                            self.cancelRequestButton.isUserInteractionEnabled = true
                            self.updatingUIAsDriverArrivedToPickupLocation()
                            self.statusOfCurrentTrip = ApiKeyConstants.kArrived
                        }
                        else if(Utility.isEqualtoString(dictResponse![ApiKeyConstants.kMessage] as? String ?? "",ApiKeyConstants.kIntransit)){
                            self.statusOfCurrentTrip = ApiKeyConstants.kIntransit
                            self.acceptButton.isUserInteractionEnabled = true
                            self.cancelRequestButton.isUserInteractionEnabled = true
                            self.updateUIWhenTripStarted()
                        }
                        else{
                            /*self.acceptButton.isUserInteractionEnabled = true
                            self.dismiss(animated: true)
                            self.acceptButtonWidthConstraints.constant = 110
                            var endTripDict : as? [String : Any] ?? [:] = dictResponse![ApiKeyConstants.kFareBreakUp] as! Dictionary
                            endTripDict[ApiKeyConstants.kTripTime] = dictResponse![ApiKeyConstants.kTotal_time] as? Int ?? 0
                            endTripDict[ApiKeyConstants.kTripDistance] = dictResponse![ApiKeyConstants.kTotal_km] as? Double ?? 0.0
                            endTripDict[ApiKeyConstants.kTripId] = self.newRequestID
                            endTripDict[ApiKeyConstants.kImage] = self.riderInfoDict[ApiKeyConstants.kProfileImage] as? String ?? ""
                            self.appDelegate.createLocalNotifications(title: Constants.NotificationConstant.kNotificationTitle, subTitle: Constants.NotificationConstant.kEndTripSubTitle, message: Constants.NotificationConstant.kEndTripBody, notificationIdentifier: Constants.NotificationConstant.kEndTripNotificationID)
                            self.bookingObjDelegate?.endTrip(isEnd: true,tripDetails: endTripDict)*/
                            
                        }*/
                    }
                    else{
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            self.acceptButton.isUserInteractionEnabled = true
                            self.cancelRequestButton.isUserInteractionEnabled = true
                            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.acceptButton.isUserInteractionEnabled = true
                        self.cancelRequestButton.isUserInteractionEnabled = true
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                    }
                }
            }
            else{
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.acceptButton.isUserInteractionEnabled = true
                    self.cancelRequestButton.isUserInteractionEnabled = true
                    Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                }
            }
        })
        { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.acceptButton.isUserInteractionEnabled = true
                self.cancelRequestButton.isUserInteractionEnabled = true
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
            }
        }
    }
    
    // MARK:- Call Mask Api-----
    func maskCallApi (){
        //var currentVC = UIViewController()
        DispatchQueue.main.async {
            self.currentVC = UIApplication.getTopMostViewController()!
            SVProgressHUD.setContainerView(self.currentVC.view)
            SVProgressHUD.show()
        }
        
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        let maskCallApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kCallMaskingApi
        let riderUserId = self.riderInfoDict[ApiKeyConstants.kid]
        let dictBodyParams : [String : AnyObject] = ["userId" : riderUserId as AnyObject]
        debugPrint("Params=",dictBodyParams)
        Utility.removeAppCookie()
        
        APIWrapper.requestPOSTURL(maskCallApi, params: dictBodyParams, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        DispatchQueue.main.async {
                            let riderContactNumber = dictResponse![ApiKeyConstants.kResult] as? String ?? ""
                            if let url = URL(string: "tel://\(riderContactNumber)"), UIApplication.shared.canOpenURL(url) {
                                if #available(iOS 10, *) {
                                    UIApplication.shared.open(url)
                                } else {
                                    UIApplication.shared.openURL(url)
                                }
                            }
                        }
                        
                    }
                    else{
                        DispatchQueue.main.async {
                            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                    }
                    
                }
            }
            else{
                DispatchQueue.main.async {
                    Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
                }
                
            }
            
        }) { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self.currentVC)
            }
            
        }
    }
    
    // MARK:- Updating PopupUI Methods -----
    func updatingPopupUI() -> Void{
        callButton.isHidden = false
        profileImageView.isHidden = false
        profileRatingView.isHidden = false
        timerView.isHidden = true
        //cancelRequestButton.isHidden = true
        profileRatingLabelHeightConstraints.constant = 0.0
        profileRatingLabel.isHidden = true
        ratingImageView.isHidden = true
        
        let urlString = self.riderInfoDict[ApiKeyConstants.kProfileImage] as? String ?? ""
        let url = URL(string: urlString)
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "profileImagePlaceholder"), options: nil, progressBlock: nil) { (result) in
            
        }
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        pickDropNameLabel.text = self.riderInfoDict[ApiKeyConstants.kPickUpName] as? String
        pickupAddressLabel.text = self.riderInfoDict[ApiKeyConstants.kRiderPickupAddress] as? String
        self.appDelegate.dropAddress = self.pickupAddressLabel.text ?? ""
//        let countryCode = self.riderInfoDict[ApiKeyConstants.kCountryCode] as? String ?? ""
//        let mobileNumber = self.riderInfoDict[ApiKeyConstants.kMobileNumber] as? String ?? ""
//        riderContactNumber = "+" + countryCode + "-" + mobileNumber
        
        imageRatingsLabel.text = NSString(format: "%.1f", self.riderInfoDict[ApiKeyConstants.kAvgRatings] as? Double ?? 0.0) as String
        acceptButton.setTitle(ApiKeyConstants.k_Arrived, for: .normal)
        acceptButton.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 15.0)
        cancelRequestButton.setTitle(ApiKeyConstants.kCancel, for: .normal)
        cancelRequestButton.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 15.0)
        let pickUpLocation : [String : Any]  = self.riderInfoDict[ApiKeyConstants.kRiderPickupPoint] as? [String : Any] ?? [:]
        appDelegate.pickUpLattitude = pickUpLocation[ApiKeyConstants.kLat] as? String ?? "0.0"
        UserDefaults.standard.set(self.appDelegate.pickUpLattitude, forKey: ApiKeyConstants.kUserDefaults.kPickUpLattitude)
        appDelegate.pickUpLongitude = pickUpLocation[ApiKeyConstants.kLng] as? String ?? "0.0"
        UserDefaults.standard.set(self.appDelegate.pickUpLongitude, forKey: ApiKeyConstants.kUserDefaults.kPickUpLongitude)
        self.bookingObjDelegate?.changeTripStatusAndUpdateLocation(dropLattitude: pickUpLocation[ApiKeyConstants.kLat] as? String ?? "0.0", dropLongitude: pickUpLocation[ApiKeyConstants.kLng] as? String ?? "0.0", dropAddress: self.pickupAddressLabel.text!,tripStatus: ApiKeyConstants.kAccepted)
    }
    
    // MARK:- Updating Initial UI Methods & Background State-----
    func updatingInitialUI(rider : [String : Any],tripStatus:String) -> Void {
        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        if Utility.isEqualtoString(tripStatus, ApiKeyConstants.kPending){
            self.acceptButton.setTitle(ApiKeyConstants.kAcceptTrip, for: .normal)
            self.cancelRequestButton.setTitle("Reject", for: .normal)
            let dict : [String : Any] = [ApiKeyConstants.kLat : Double(self.appDelegate.lattitude)!, ApiKeyConstants.klongitude : Double(self.appDelegate.longitude)!]
            self.appDelegate.pickupRouteLocationArr.insert(dict as AnyObject, at: 0)
            UserDefaults.standard.set(self.appDelegate.pickupRouteLocationArr, forKey: ApiKeyConstants.kUserDefaults.kPickUpLocation)
            self.appDelegate.acceptTime = Utility.currentTimeInMiliseconds()
            UserDefaults.standard.set(self.appDelegate.acceptTime, forKey: ApiKeyConstants.kUserDefaults.kAcceptTime)
            commonUIUpdate()
            timerView.layer.cornerRadius = timerView.frame.height/2
            timerView.layer.borderColor = Constants.AppColour.kAppLightGreyColor.cgColor
            timerView.layer.borderWidth = 1.0
            timerLabel.text = NSString(format: "%d", rider[ApiKeyConstants.kCountDownTime] as? Int ?? 30) as String
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                let borderWidth:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
                borderWidth.fromValue = 0
                borderWidth.toValue = 1
                borderWidth.duration = 1.0
                self.timerView.layer.cornerRadius = CGFloat(Int(self.timerView.frame.height)/2)
                self.timerView.layer.borderWidth = 1.0
                self.timerView.layer.borderColor = Constants.AppColour.kAppPolyLineGreenColor.cgColor
                self.timerView.layer.add(borderWidth, forKey: "Width")
                self.timerView.layer.borderWidth = 1.0
                let myInt = (self.timerLabel.text! as NSString).integerValue
                let timeSec = myInt - 1
                self.timerLabel.text = String(timeSec)
                if myInt < 2{
                    self.acceptButton.isUserInteractionEnabled = false
                    self.cancelRequestButton.isUserInteractionEnabled = false
                }
                else{
                    self.acceptButton.isUserInteractionEnabled = true
                    self.cancelRequestButton.isUserInteractionEnabled = true
                }
                if timeSec == 0{
                    timer.invalidate()
                    if(Reachibility.isConnectedToNetwork()){
                        self.manual = false
                        self.acceptButton.isUserInteractionEnabled = false
                        self.cancelRequestButton.isUserInteractionEnabled = false
                        DispatchQueue.global(qos: .background).async {
                            self.bookingAcceptRejectApi(requestId: self.newRequestID, acceptReject: false)
                        }
                    }
                    else{
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
                    }
                }
            }
        
            profileRatingLabelHeightConstraints.constant = 12.0
            profileRatingLabel.isHidden = false
            ratingImageView.isHidden = false
        
            callButton.isHidden = true
            profileImageView.isHidden = true
            profileRatingView.isHidden = true
            pickDropLabel.text = ApiKeyConstants.kPickUp
            profileRatingLabel.text = NSString(format: "%.2f", rider[ApiKeyConstants.kAvgRatings] as? Double ?? 0.0) as String
            pickDropNameLabel.text = rider[ApiKeyConstants.kPickUpName] as? String
            pickupAddressLabel.text = rider[ApiKeyConstants.kRiderPickupAddress] as? String
            self.appDelegate.dropAddress = self.pickupAddressLabel.text!
//            let countryCode = rider[ApiKeyConstants.kCountryCode] as? String ?? ""
//            let mobileNumber = rider[ApiKeyConstants.kMobileNumber] as? String ?? ""
        
//            riderContactNumber = "+" + countryCode + "-" + mobileNumber
        }
        else if Utility.isEqualtoString(tripStatus, ApiKeyConstants.kAccepted){
            commonUIUpdate()
            updatingPopupUI()
        }
        else if Utility.isEqualtoString(tripStatus, ApiKeyConstants.kArrived){
            commonUIUpdate()
            updatingUIAsDriverArrivedToPickupLocation()
        }
        else if Utility.isEqualtoString(tripStatus, ApiKeyConstants.kIntransit){
            commonUIUpdate()
            updateUIWhenTripStarted()
        }
        self.show(animated: true)
    }
    
    // MARK:- Common UI Update Methods-----
    func commonUIUpdate(){
        let urlString = self.riderInfoDict[ApiKeyConstants.kProfileImage] as? String ?? ""
        let url = URL(string: urlString)
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "profileImagePlaceholder"), options: nil, progressBlock: nil) { (result) in
            
        }
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
        bookingPopupBg.layer.cornerRadius = 10.0
        bookingPopupBg.layer.borderColor = Constants.AppColour.kAppLightGreyColor.cgColor
        bookingPopupBg.layer.borderWidth = 1.0
        
        profileRatingView.layer.cornerRadius = profileRatingView.frame.height/2
        profileRatingView.layer.borderColor = Constants.AppColour.kAppLightGreyColor.cgColor
        profileRatingView.layer.borderWidth = 1.0
        
        riderNameLabel.text = self.riderInfoDict[ApiKeyConstants.kRiderName] as? String
        
    }
    
    // MARK:- Common UI Update When Driver Arrived Methods-----
    func commonUIUpdateWhenDriverArrived(){
        profileImageView.isHidden = false
        profileRatingView.isHidden = false
        timerView.isHidden = true
        //cancelRequestButton.isHidden = true
        profileRatingLabelHeightConstraints.constant = 0.0
        profileRatingLabel.isHidden = true
        ratingImageView.isHidden = true
        imageRatingsLabel.text = NSString(format: "%.1f", self.riderInfoDict[ApiKeyConstants.kAvgRatings] as? Double ?? 0.0) as String
        self.callButton.isHidden = true
        //self.cancelRequestButton.isHidden = true
        acceptButton.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 15.0)
    }
    
    // MARK:- UI update as driver arrived pickup location Methods-----
    func updatingUIAsDriverArrivedToPickupLocation(){
        commonUIUpdateWhenDriverArrived()
        self.callButton.isHidden = false
                //Booking Without Stops
        self.acceptButtonWidthConstraints.constant = 110
        var dropLocation = [String : Any]()
        if (self.riderInfoDict[ApiKeyConstants.kStops] != nil){
            self.pickDropLabel.text = ApiKeyConstants.kStop
            stopDetails = self.riderInfoDict[ApiKeyConstants.kStops] as? [[String : Any]] ?? [[:]]
            self.pickDropNameLabel.text = stopDetails[0][ApiKeyConstants.kDropName] as? String
            self.pickupAddressLabel.text = stopDetails[0][ApiKeyConstants.kRiderDropOffAddress] as? String
            self.appDelegate.dropAddress = self.pickupAddressLabel.text!
            dropLocation = stopDetails[0][ApiKeyConstants.kRiderDropPoint]! as? [String : Any] ?? [:]
        }
        else{
            dropLocation = self.riderInfoDict[ApiKeyConstants.kRiderDropPoint]! as? [String : Any] ?? [:]
            self.pickDropLabel.text = ApiKeyConstants.kDropOff
            self.pickDropNameLabel.text = self.riderInfoDict[ApiKeyConstants.kDropName] as? String
            self.pickupAddressLabel.text = self.riderInfoDict[ApiKeyConstants.kRiderDropOffAddress] as? String
            self.appDelegate.dropAddress = self.pickupAddressLabel.text!
        }
        self.acceptButton.setTitle(ApiKeyConstants.kStartTrip, for: .normal)
        self.cancelRequestButton.setTitle(ApiKeyConstants.kCancel, for: .normal)
        
        self.appDelegate.endTriplattitude = dropLocation[ApiKeyConstants.kLat] as? String ?? "0.0"
        UserDefaults.standard.set(self.appDelegate.endTriplattitude, forKey: ApiKeyConstants.kUserDefaults.kEndTripLattitude)
        self.appDelegate.endTriplongitude = dropLocation[ApiKeyConstants.kLng] as? String ?? "0.0"
        UserDefaults.standard.set(self.appDelegate.endTriplongitude, forKey: ApiKeyConstants.kUserDefaults.kEndTripLongitude)
        self.bookingObjDelegate?.changeTripStatusAndUpdateLocation(dropLattitude: dropLocation[ApiKeyConstants.kLat] as? String ?? "", dropLongitude: dropLocation[ApiKeyConstants.kLng] as? String ?? "", dropAddress: self.pickupAddressLabel.text!,tripStatus: ApiKeyConstants.kArrived)
    }
    
    // MARK:- Start Trip UI update Methods-----
    func updateUIWhenTripStarted(){
        commonUIUpdateWhenDriverArrived()
        if (self.riderInfoDict[ApiKeyConstants.kStops] != nil){

            if self.isStopsUpdated == true{
                self.isStopsUpdated = false
            }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            self.acceptButton.isUserInteractionEnabled = true
            self.cancelRequestButton.isUserInteractionEnabled = true
            
            self.pickDropLabel.text = ApiKeyConstants.kStop
            var flagStatus = Bool()
            var nextStop = [String:Any]()
            var placeId = String()
            stopDetails = self.riderInfoDict[ApiKeyConstants.kStops] as? [[String : Any]] ?? [[:]]
            
            for stops in stopDetails{
                if !Utility.isEqualtoString(stops[ApiKeyConstants.kStatus] as? String ?? "", ApiKeyConstants.kComplete){
                    flagStatus = true
                    nextStop = stops
                    debugPrint(stops)
                    break
                }
                else{
                    flagStatus = false
                    nextStop = [:]
                    //                            No Next stops
                }
            }
            if flagStatus == true{
                 self.pickDropLabel.text = ApiKeyConstants.kStop
                 self.acceptButton.isUserInteractionEnabled = true
                 self.cancelRequestButton.isUserInteractionEnabled = true
                 self.pickDropNameLabel.text = nextStop[ApiKeyConstants.kDropName] as? String
                 self.pickupAddressLabel.text = nextStop[ApiKeyConstants.kRiderDropOffAddress] as? String
                 self.appDelegate.dropAddress = self.pickupAddressLabel.text!
                 self.acceptButton.setTitle(ApiKeyConstants.kConfirmStop, for: .normal)
                 self.cancelRequestButton.setTitle(ApiKeyConstants.kEndTrip, for: .normal)
                 self.acceptButtonWidthConstraints.constant = 140
                 let dropLocation : [String : Any] = nextStop[ApiKeyConstants.kRiderDropPoint]! as? [String : Any] ?? [:]
                 self.appDelegate.endTriplattitude = dropLocation[ApiKeyConstants.kLat] as? String ?? "0.0"
                 UserDefaults.standard.set(self.appDelegate.endTriplattitude, forKey: ApiKeyConstants.kUserDefaults.kEndTripLattitude)
                 self.appDelegate.endTriplongitude = dropLocation[ApiKeyConstants.kLng] as? String ?? "0.0"
                 UserDefaults.standard.set(self.appDelegate.endTriplongitude, forKey: ApiKeyConstants.kUserDefaults.kEndTripLongitude)
                 self.bookingObjDelegate?.changeTripStatusAndUpdateLocation(dropLattitude: dropLocation[ApiKeyConstants.kLat] as? String ?? "0.0", dropLongitude: dropLocation[ApiKeyConstants.kLng] as? String ?? "0.0", dropAddress: self.pickupAddressLabel.text!,tripStatus: ApiKeyConstants.kIntransit)
                placeId = nextStop[ApiKeyConstants.kDropPlaceID]! as? String ?? ""
                debugPrint("Place Id =",placeId)
            }
            else{
                self.acceptButton.isUserInteractionEnabled = true
                self.cancelRequestButton.isUserInteractionEnabled = true
                self.acceptButton.setTitle(ApiKeyConstants.kEndTrip, for: .normal)
                self.callButton.isHidden = true
                self.cancelRequestButton.isHidden = true
                //After Stops complete.
                self.acceptButtonWidthConstraints.constant = 110
                self.pickDropLabel.text = ApiKeyConstants.kDropOff
                self.pickDropNameLabel.text = self.riderInfoDict[ApiKeyConstants.kDropName] as? String
                self.pickupAddressLabel.text = self.riderInfoDict[ApiKeyConstants.kRiderDropOffAddress] as? String
                self.appDelegate.dropAddress = self.pickupAddressLabel.text!
                let dropLocation : [String : Any] = self.riderInfoDict[ApiKeyConstants.kRiderDropPoint]! as? [String : Any] ?? [:]
                self.appDelegate.endTriplattitude = dropLocation[ApiKeyConstants.kLat] as? String ?? "0.0"
                UserDefaults.standard.set(self.appDelegate.endTriplattitude, forKey: ApiKeyConstants.kUserDefaults.kEndTripLattitude)
                self.appDelegate.endTriplongitude = dropLocation[ApiKeyConstants.kLng] as? String ?? "0.0"
                UserDefaults.standard.set(self.appDelegate.endTriplongitude, forKey: ApiKeyConstants.kUserDefaults.kEndTripLongitude)
                self.bookingObjDelegate?.changeTripStatusAndUpdateLocation(dropLattitude: dropLocation[ApiKeyConstants.kLat] as? String ?? "0.0", dropLongitude: dropLocation[ApiKeyConstants.kLng] as? String ?? "0.0", dropAddress: self.pickupAddressLabel.text!,tripStatus: ApiKeyConstants.kIntransit)
            }
            
        }
        else{
            self.acceptButton.isUserInteractionEnabled = true
            self.cancelRequestButton.isUserInteractionEnabled = true
            self.acceptButtonWidthConstraints.constant = 110
            self.callButton.isHidden = true
            self.cancelRequestButton.isHidden = true
            self.pickDropLabel.text = ApiKeyConstants.kDropOff
            self.pickDropNameLabel.text = self.riderInfoDict[ApiKeyConstants.kDropName] as? String
            self.pickupAddressLabel.text = self.riderInfoDict[ApiKeyConstants.kRiderDropOffAddress] as? String
            self.appDelegate.dropAddress = self.pickupAddressLabel.text!
            let dropLocation : [String : Any] = self.riderInfoDict[ApiKeyConstants.kRiderDropPoint]! as? [String : Any] ?? [:]
            self.appDelegate.endTriplattitude = dropLocation[ApiKeyConstants.kLat] as? String ?? "0.0"
            UserDefaults.standard.set(self.appDelegate.endTriplattitude, forKey: ApiKeyConstants.kUserDefaults.kEndTripLattitude)
            self.appDelegate.endTriplongitude = dropLocation[ApiKeyConstants.kLng] as? String ?? "0.0"
            UserDefaults.standard.set(self.appDelegate.endTriplongitude, forKey: ApiKeyConstants.kUserDefaults.kEndTripLongitude)
            self.bookingObjDelegate?.changeTripStatusAndUpdateLocation(dropLattitude: dropLocation[ApiKeyConstants.kLat] as? String ?? "0.0", dropLongitude: dropLocation[ApiKeyConstants.kLng] as? String ?? "0.0", dropAddress: self.pickupAddressLabel.text!,tripStatus: ApiKeyConstants.kIntransit)
            self.acceptButton.setTitle(ApiKeyConstants.kEndTrip, for: .normal)
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
    
    //    MARK:- Get Static Map image from encoded polyline -------
//    func getStaticMapOfTrip(encodedPolyline : String, markersLatLong:[String:Any], isEncodedPolyline : Bool) -> Void{
//        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
//        let viewWidth = Int(currentVC.view.frame.width)
//        let centerLatLongDict = markersLatLong["centerLatLong"] as? [String:Any] ?? [:]
//        let centerLat = centerLatLongDict["lat"] as? Double ?? 0.0
//        let centerLong = centerLatLongDict["longitude"] as? Double ?? 0.0
//        
//        let sourceLatLongDict = markersLatLong["pickUpLatLong"] as? [String:Any] ?? [:]
//        let sourceLat = sourceLatLongDict["lat"] as? Double ?? 0.0
//        let sourceLong = sourceLatLongDict["longitude"] as? Double ?? 0.0
//        
//        let destLatLongDict = markersLatLong["dropLatLong"] as? [String:Any] ?? [:]
//        let destLat = destLatLongDict["lat"] as? Double ?? 0.0
//        let destLong = destLatLongDict["longitude"] as? Double ?? 0.0
//        var staticMapUrl = String()
//        if isEncodedPolyline {
//            staticMapUrl = "https://maps.googleapis.com/maps/api/staticmap?center=\(centerLat),\(centerLong)&\(Constants.MapStyle.mapStyle)&markers=color:green|label:S|\(sourceLat),\(sourceLong)&markers=color:red|label:D|\(destLat),\(destLong)&scale=2&size=\(viewWidth)x200&maptype=roadmap&key=\(Constants.SocialLoginKeys.kGoogleMapsApiKey)&path=color:0x3B852F|weight:3|enc:\(encodedPolyline)&format=png&visual_refresh=true"
//        }
//        else{
//            staticMapUrl = "https://maps.googleapis.com/maps/api/staticmap?center=\(centerLat),\(centerLong)&\(Constants.MapStyle.mapStyle)&markers=color:green|label:S|\(sourceLat),\(sourceLong)&markers=color:red|label:D|\(destLat),\(destLong)&scale=2&size=\(viewWidth)x200&maptype=roadmap&key=\(Constants.SocialLoginKeys.kGoogleMapsApiKey)&path=color:0x3B852F|weight:3|\(encodedPolyline)&format=png&visual_refresh=true"
//        }
//        debugPrint("Url =",staticMapUrl)
//        
//        let mapUrl = URL(string: staticMapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
//        let imgViewMap = UIImageView()
//        imgViewMap.kf.setImage(with: mapUrl, placeholder: UIImage(named: ""), options: nil, progressBlock: nil) { (result) in
//            debugPrint(result)
//            staticMapCallback?(imgViewMap.image ?? UIImage(named: "mapPlaceHolder")!)
////            UIImageWriteToSavedPhotosAlbum(imgViewMap.image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
//        }
//    }
    
//    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        if let error = error {
//            // we got back an error!
//            debugPrint("Saved Error",error)
//        } else {
//            debugPrint("Saved")
//        }
//    }
}
