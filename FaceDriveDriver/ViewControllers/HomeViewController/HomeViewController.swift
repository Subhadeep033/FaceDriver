//
//  HomeViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 30/01/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import Firebase
import FirebaseDatabase
import ObjectMapper
import SVProgressHUD
import Alamofire
import SwiftyJSON
import AVFoundation
import Reachability
import Mapbox
import MapboxNavigation
import MapboxCoreNavigation
import MapboxDirections
import ActionSheetPicker_3_0
import Foundation
class CustomPointAnnotation: MGLPointAnnotation {
    var tag: Int = 0
}


class HomeViewController: UIViewController,BookingRequestPopupsDelegate,SideMenuDelegate {
    
    //var homeRefHandle : DatabaseHandle!
    //var homeBookingRef : DatabaseReference!
    var allCarMarker = [GMSMarker]()
    var endTripDict = [String : Any]()
    var oldPolyLine = GMSPolyline()
    var userMarker = GMSMarker()
    var initialMarker = GMSMarker()
    var userLocationMarker = GMSMarker()
    var dropLocationMarker = GMSMarker()
    @IBOutlet weak var hambargerButton: UIButton!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var onlineButton: UIButton!
    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var userLocationButton: UIButton!
    @IBOutlet weak var btnSOS: UIButton!
    @IBOutlet weak var btnShowCarDetails: UIButton!
    @IBOutlet weak var userLocationBottomConstraints: NSLayoutConstraint!
    fileprivate var timer: Timer?
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var isInitialLoad = true
    var isTripStarted = false
    var currentTripStatus = ApiKeyConstants.kPending
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var arrPolygon = [GMSPolygon]()
    var isLocationCheckDoneOnce : Int = 0
    var userposition = CLLocationCoordinate2D()
    var regionName = String()
    var regionDescription = String()
    var bookingsPopups : BookingRequestPopups? = nil
    var currentDropLat : String = ""
    var currentDropLong : String = ""
    var currentDropAddress : String = ""
    var changeInZoom : Float = 15.0
    var tripDistance : Double = 0.0
    var path = GMSPath()
    var gmsBounds = GMSCoordinateBounds()
    var currentRouteCoordinates = [CLLocationCoordinate2D]()
    var routeCordsCount = UInt()
    @IBOutlet weak var regionView: UIView!
    @IBOutlet weak var regionNameLabel: UILabel!
    @IBOutlet weak var regionDescriptionLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var mapboxView: NavigationMapView!
    let markerMapBox = CustomPointAnnotation()
    var arrPolygonMapBox = [MGLPolygon]()
    var allAnnotations = [CustomPointAnnotation]()
    var routeLine = MGLPolyline()
    var directionsRoute: Route?
    var isMapBox = false
    //var wp1 = Waypoint()
    //var wp2 = Waypoint()
    fileprivate var carDetailsPopup = CarDetailsPopupViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kMapType) == nil{
            isMapBox = false
            Utility.saveIntegerInUserDefaults(0, key: ApiKeyConstants.kUserDefaults.kMapType)
        }
        else{
            let selectedMap = Utility.retrieveIntegerFromUserDefaults(ApiKeyConstants.kUserDefaults.kMapType)
            if selectedMap == 0{
                isMapBox = false
            }
            else{
                isMapBox = true
            }
        }
        
        if (isMapBox) {
            self.mapboxView.delegate = self
            self.mapboxView.isHidden = false
            self.mapView.isHidden = true
            self.initializeMapBox()
            
        } else {
            self.mapboxView.isHidden = true
            self.mapView.delegate = self
            self.mapView.isHidden = false
            self.initializeGSMMap()
        }
//        if self.ref != nil{
//            self.ref.child(ApiKeyConstants.kFirebaseTableName).removeAllObservers()
//        }

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        isLocationCheckDoneOnce = 0
        self.onlineButton.isUserInteractionEnabled = false
        if appDelegate.appDelHomeVcRef == nil{
            appDelegate.appDelHomeVcRef = Database.database().reference()
        }
        if Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            debugPrint("Id xxxxxxxx =",driverDetailsDict[ApiKeyConstants.kid] as? String ?? "")
            
          self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kisVacant).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    if (snapshot.value! as? Int ?? 0 == 0){
                        self.appDelegate.isWithInTrip = true
                    }
                    else{
                        self.appDelegate.isWithInTrip = false
                    }
                self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kisVacant).removeAllObservers()
                }
            })
        }
        if !appDelegate.isWithInTrip {
            checkForZoneInfo()
            initializeView()
            
            if appDelegate.lastLattitude != "0.0" && appDelegate.lastLongitude != "0.0"{
        
                if(isMapBox) {
                    self.setCameraPositionOnMapBox(userposition: CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!))
                } else {
                    focusOnCurrentLocationForGoogleMap()
                }
            }
        }
        else if self.bookingsPopups != nil && appDelegate.isWithInTrip{
            self.bookingsPopups?.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.configureDatabase()
        })
    }
    
    // MARK:- App Move To Foreground Method ----
    @objc func appMovedToForeground() {
        print("App moved to ForeGround!")
        Utility.isLocationEnabled(targetView: self.view, targetedVC: self, message: Constants.AppAlertMessage.kAllowLocationService, actionEnabled: true, btnMessage: Constants.AppAlertAction.kTurnOn)
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            let status = driverDetailsDict[ApiKeyConstants.kStatus] as? Int ?? 0
            
            if status == 1 {
                startAnimation()
            }
        }
    }
    
    
    // MARK:- Initialize view
    func initializeView()  {
        
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        if driverDetailsDict[ApiKeyConstants.kIsApproved] != nil{
            if driverDetailsDict[ApiKeyConstants.kIsApproved] as? Bool == false{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kProfileApprove, Button_Title: Constants.AppAlertAction.kOKButton, self)
                onlineButton.isHidden = true
                backView.isHidden = true
                circleImageView.isHidden = true
            } else {
                if appDelegate.lastLattitude != "0.0" && appDelegate.lastLongitude != "0.0" {
                    appDelegate.lattitude = appDelegate.lastLattitude
                    appDelegate.longitude = appDelegate.lastLongitude
                    userposition = CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!)
                }
                
                isInitialLoad = true
                onlineOfflineDriver()
                backView.isHidden = false
                onlineButton.isHidden = false
                circleImageView.isHidden = false
                regionView.isHidden = true
            }
        } else {
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kProfileApprove, Button_Title: Constants.AppAlertAction.kOKButton, self)
            onlineButton.isHidden = true
            backView.isHidden = true
            circleImageView.isHidden = true
        }
        navigationButton.isHidden = true
        btnSOS.isHidden = true
        btnSOS.layer.cornerRadius = btnSOS.frame.height / 2
    }
    
    
    // MARK:- All Button Action Methods-----
    
    @IBAction func SOSButtonTap(_ sender: Any) {
//        let storyBoard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
//        let sosPopup = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSOSPopupStoryBoardId) as! SOSViewController
//
//        sosPopup.callback = { details in
//            if let url = URL(string: "tel://\(details)"), UIApplication.shared.canOpenURL(url) {
//                if #available(iOS 10, *) {
//                    UIApplication.shared.open(url)
//                } else {
//                    UIApplication.shared.openURL(url)
//                }
//            }
//
//        }
//        sosPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//        self.present(sosPopup, animated: true, completion: nil)
        
        if let url = URL(string: "tel://\(911)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func navigationBtnTap(_ sender: Any) {
        
        if(isMapBox) {
            callMapboxNavigation()
        } else {
            
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                if Utility.isEqualtoString(currentTripStatus, ApiKeyConstants.kAccepted){
                    debugPrint("Pick Up=",appDelegate.pickUpAddress);
                    var addressStr = appDelegate.pickUpAddress.replacingOccurrences(of: ",", with: "")
                    addressStr = addressStr.replacingOccurrences(of: "\n", with: "")
                    let pickUpArr = addressStr.components(separatedBy: " ")
                    var pickUpAddress : String = ""
                    for str in pickUpArr {
                        if pickUpAddress == ""{
                            pickUpAddress = str
                        }else{
                            pickUpAddress = String(format: "%@+%@", pickUpAddress,str)
                        }
                    }
                    UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=\(appDelegate.lattitude),\(appDelegate.longitude)&daddr=\(appDelegate.pickUpLattitude),\(appDelegate.pickUpLongitude)&directionsmode=driving")! , options: [:]
                        , completionHandler: nil)
                }
                else{
                    debugPrint("Drop=",appDelegate.dropAddress);
                    var addressStr = appDelegate.dropAddress.replacingOccurrences(of: ",", with: "")
                    addressStr = addressStr.replacingOccurrences(of: "\n", with: "")
                    let dropArr = addressStr.components(separatedBy: " ")
                    var dropAddress : String = ""
                    for str in dropArr {
                        if str != ""{
                            if dropAddress == ""{
                                dropAddress = str
                            }else{
                                dropAddress = String(format: "%@+%@", dropAddress,str)
                            }
                        }
                    }
                    UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=\(appDelegate.lattitude),\(appDelegate.longitude)&daddr=\(appDelegate.endTriplattitude),\(appDelegate.endTriplongitude)&directionsmode=driving")! , options: [:]
                        , completionHandler: nil)
                }
            }
            else {
                if self.bookingsPopups != nil && appDelegate.isWithInTrip{
                    self.bookingsPopups?.isHidden = true
                }
                let storyBoard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
                let mapWebVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kMapWebViewId) as! MapInWebViewController
                if Utility.isEqualtoString(currentTripStatus, ApiKeyConstants.kAccepted){
                    mapWebVC.strTripStatus = currentTripStatus
                }
                else{
                    mapWebVC.strTripStatus = currentTripStatus
                }
                self.show(mapWebVC, sender: self)
            }
        }
    }
    
    func callMapboxNavigation(){
        //mapboxView.setUserTrackingMode(.followWithCourse, animated: true)
        if Utility.isEqualtoString(currentTripStatus, ApiKeyConstants.kAccepted){
                let wp1 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!), name: "Start")
                let wp2 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: Double(appDelegate.pickUpLattitude)!, longitude: Double(appDelegate.pickUpLongitude)!), name: appDelegate.pickUpAddress)
                    wp1.allowsArrivingOnOppositeSide = false
                    wp2.allowsArrivingOnOppositeSide = false
                let options = NavigationRouteOptions(waypoints: [wp1, wp2], profileIdentifier: .automobileAvoidingTraffic)
                        options.routeShapeResolution = .full
                        options.includesSteps = true
                        options.includesVisualInstructions = true
                        options.includesSpokenInstructions = true
            
                        Directions.shared.calculate(options) { (waypoints, routes, error) in
                            guard error == nil else {
                                print("Error calculating directions: \(error!)")
                                return
                            }
                            self.directionsRoute = routes?.first
                            
                        }
                        
                let navigationService = MapboxNavigationService(route: directionsRoute!, simulating: .never)
                let navigationOptions = NavigationOptions(navigationService: navigationService)
                let navigationViewController = NavigationViewController(for: directionsRoute!, options: navigationOptions)
        
                    navigationViewController.shouldManageApplicationIdleTimer = false
                    self.present(navigationViewController, animated: true, completion: nil)
            }
            else{
                let wp1 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!), name: "")
                let wp2 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: Double(appDelegate.endTriplattitude)!, longitude: Double(appDelegate.endTriplongitude)!), name: appDelegate.dropAddress)
                    wp1.allowsArrivingOnOppositeSide = false
                    wp2.allowsArrivingOnOppositeSide = false
                let options = NavigationRouteOptions(waypoints: [wp1, wp2], profileIdentifier: .automobileAvoidingTraffic)
                        options.routeShapeResolution = .full
                        options.includesSteps = true
                        options.includesVisualInstructions = true
                        options.includesSpokenInstructions = true
            
                        Directions(accessToken: appDelegate.MAPBOX_ACCESS_TOKEN).calculate(options) { (waypoints, routes, error) in
                            guard error == nil else {
                                print("Error calculating directions: \(error!)")
                                return
                            }
                            self.directionsRoute = routes?.first
                        }
                        
                let navigationService = MapboxNavigationService(route: directionsRoute!, simulating:.never, routerType: RouteController.self)
                let navigationOptions = NavigationOptions(navigationService: navigationService)
                let navigationViewController = NavigationViewController(for: directionsRoute!, options: navigationOptions)
                    navigationViewController.shouldManageApplicationIdleTimer = false
                self.present(navigationViewController, animated: true, completion: nil)
            }
    }
    
    // MARK:- Current Location With Completion ----
    func getCurrentLocationAndFocusOnLocation(getCurrentLocation: () -> Void){
        self.getCurrentLocation()   //Will change in future.
        getCurrentLocation()
    }
    
    // MARK:- Show Current Location Button Tap----
    @IBAction func showUserLocationBtnTap(_ sender: Any) {
        getCurrentLocationAndFocusOnLocation{
            if appDelegate.lattitude != "0.0" && appDelegate.longitude != "0.0"{
                if (appDelegate.isWithInTrip){
                    if(isMapBox) {
                        self.mapboxView.setVisibleCoordinates(&self.currentRouteCoordinates, count: self.routeCordsCount, edgePadding: .init(top: 100, left: 20, bottom: 290, right: 20), animated: true)
                    }  else {
                        let update = GMSCameraUpdate.fit(self.gmsBounds)
                        self.mapView.animate(with: update)
                    }
                }
                else{
                    if(isMapBox) {
                        self.setCameraPositionOnMapBox(userposition: CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!))
                    }  else {
                        focusOnCurrentLocationForGoogleMap()
                    }
                }
            }
        }
    }
    
    @IBAction func btnShowCarDetailsTap(_ sender: UIButton) {
        if(Reachibility.isConnectedToNetwork()){
            self.btnShowCarDetails.setTitle("Please Wait.", for: .normal)
            self.updateCarServiceType()
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    
    // MARK:- Online/Offline Button Tap----
    @IBAction func onlineButtonTap(_ sender: Any) {
        if(Reachibility.isConnectedToNetwork()){
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            let currentStatus = driverDetailsDict[ApiKeyConstants.kStatus] as? Bool ?? false
            let authToken = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
            let stripeCustomerId = driverDetailsDict["stripeCustomerId"] as? String ?? ""
            if (currentStatus == false) {
                if Utility.isEqualtoString(stripeCustomerId, ""){
                    let addBankAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNoBankAccountAdded, preferredStyle: .alert)
                    addBankAlert.view.tintColor = Constants.AppColour.kAppGreenColor
                    let actionYes = UIAlertAction(title: Constants.AppAlertAction.kAddBank, style: .default) { (action) in
                        self.dismiss(animated: true, completion: nil)
                        let storyBoard = UIStoryboard.init(name: "EarningsAndTrips", bundle: Bundle.main)
                        let referEarnVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kPayoutDetailsView) as! PayoutDetailsViewController
                        
                        self.show(referEarnVC, sender: self)
                    }
                    let actionCancel = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default) { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    addBankAlert.addAction(actionCancel)
                    addBankAlert.addAction(actionYes)
                    self.present(addBankAlert, animated: true, completion: nil)
                }
                else{
                    self.fetchAddedcarList(authToken: authToken)
                }
            } else {
                let offlineAlert = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kGoOffline, preferredStyle: .alert)
                offlineAlert.view.tintColor = Constants.AppColour.kAppGreenColor
                let actionYes = UIAlertAction(title: Constants.AppAlertAction.kYESButton, style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                    self.changeDriverStatus(status: currentStatus, token: authToken)
                }
                let actionCancel = UIAlertAction(title: Constants.AppAlertAction.kNo, style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                offlineAlert.addAction(actionCancel)
                offlineAlert.addAction(actionYes)
                self.present(offlineAlert, animated: true, completion: nil)
            }
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // MARK:- SideMenu Button Tap-----
    @IBAction func hambargerBtnAction(_ sender: Any) {
        if self.bookingsPopups != nil && self.appDelegate.isWithInTrip{
            self.bookingsPopups?.isHidden = true
        }
        let ObjMenuViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSideMenuStoryboardId) as! SideMenuViewController
        ObjMenuViewController.sideMenuObjDelegate = self as SideMenuDelegate
        //ObjMenuViewController.view.layoutIfNeeded()
        self.view.addSubview(ObjMenuViewController.view)
        self.addChild(ObjMenuViewController)
        
       // self.mapView.bringSubviewToFront(ObjMenuViewController.view)
    }
    
    // MARK:- Settings Button Tap---
    @IBAction func settingBtnAction(_ sender: Any) {
        let selectedRows = Utility.retrieveIntegerFromUserDefaults(ApiKeyConstants.kUserDefaults.kMapType)
        ActionSheetStringPicker.show(withTitle: "Select Preffered Map", rows: ["Google Maps","MapBox"], initialSelection: selectedRows, doneBlock: {
            picker, selectedRow, selectedString in
            if(selectedRow == 0) {
                Utility.saveIntegerInUserDefaults(0, key: ApiKeyConstants.kUserDefaults.kMapType)
                self.isMapBox = false
                self.mapboxView.isHidden = true
                self.mapboxView.remove(self.routeLine)
                //self.clearMap()
                self.allAnnotations.removeAll()
                self.mapView.delegate = self
                self.mapView.isHidden = false
                self.initializeGSMMap()
                self.setUserMarker(userposition: self.userposition)
            } else {
                Utility.saveIntegerInUserDefaults(1, key: ApiKeyConstants.kUserDefaults.kMapType)
                self.isMapBox = true
                self.mapboxView.delegate = self
                self.mapboxView.isHidden = false
                self.mapView.isHidden = true
                //self.mapView.clear()
                self.oldPolyLine.map = nil
                self.allCarMarker.removeAll()
                self.initializeMapBox()
            }
            
            if self.appDelegate.lattitude != "0.0" && self.appDelegate.longitude != "0.0"{
                if(self.isMapBox) {
                    self.setCameraPositionOnMapBox(userposition: CLLocationCoordinate2D(latitude: Double(self.appDelegate.lattitude)!, longitude: Double(self.appDelegate.longitude)!))
                }  else {
                    self.focusOnCurrentLocationForGoogleMap()
                }
            }
            
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    // MARK:- Check For Zone---
    private func checkForZoneInfo(){
        var driverDetailsDict = [String : Any]()
        
        if appDelegate.appDelHomeVcRef == nil{
            appDelegate.appDelHomeVcRef = Database.database().reference()
        }
        
        if Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
            driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kZoneId).observe(.value, with: { (snapshot) in
                if snapshot.exists(){
                    if (snapshot.value! as? String ?? "" != ""){
                        debugPrint("Zone Id =",snapshot.value as? String ?? "")
                        self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                                if snapshot.exists(){
                                    let snapShot : [String : Any] = snapshot.value! as? [String : Any] ?? [:]
                                    self.appDelegate.isWithInZone = true
                                    self.regionName = (snapShot["zoneName"]! as? String ?? "").capitalized
                                    self.regionDescription = (snapShot["zoneDescription"]! as? String ?? "")
                                    
                                    if self.appDelegate.isWithInTrip == false{
                                        self.showRegionView(isHidden: false, regionName: self.regionName, regionDetails: self.regionDescription, isWithInRegion: true)
                                    }
                                    else{
                                        self.showRegionView(isHidden: true, regionName: self.regionName, regionDetails: self.regionDescription, isWithInRegion: true)
                                    }
                                }
                            })
                        
                    }
                    else{
                        self.appDelegate.isWithInZone = false
                        //                    if self.appDelegate.isWithInRegion == true{
                        self.showRegionView(isHidden: true, regionName: "", regionDetails: "", isWithInRegion: false)
                        //                    }
                    }
                }
            })
        }
    }
    
    
    // MARK:- Configure Firebase Database
    private func configureDatabase()  {
        // Need To Uncomment when firebase from backend done
        if appDelegate.appDelHomeVcRef == nil{
            appDelegate.appDelHomeVcRef = Database.database().reference()
        }
        if Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            debugPrint("Id xxxxxxxx =",driverDetailsDict[ApiKeyConstants.kid] as? String ?? "")
            
          self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kisOnline).observe(.value, with: { (snapshot) in
                if snapshot.exists(){
                    if(snapshot.value! as? Int ?? 0 == 1){
                        self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kNewRequestId).observe(.value, with: { (snapshot) in
                            if snapshot.exists(){
                                debugPrint("Request Id:",snapshot.value!)
                                if(snapshot.value! as? String ?? "" != ""){
                                    let requestId = snapshot.value! as? String ?? ""
                                    
                                    self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
                                        if snapshot.exists() {
                                            
                                            self.updatingPopupUIOnRideRequest(snapshot: snapshot.value! as? [String:Any] ?? [:], requestId: requestId)
                                        }
                                    })
                                }
                                else{
                                    self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kTripId).observe( .value, with: { (snapshot) in
                                        if snapshot.exists(){
                                            debugPrint("Trip Id:",snapshot.value!)
                                            if(snapshot.value! as? String ?? "" != ""){
                                                let requestId = snapshot.value! as? String ?? ""
                                                
                                                self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
                                                    
                                                    if snapshot.exists() {
                                                        self.updatingPopupUIOnRideRequest(snapshot: snapshot.value! as? [String:Any] ?? [:], requestId: requestId)
                                                    }
                                                })
                                            }
                                            else{
                                                self.onlineButton.isUserInteractionEnabled = true
                                            }
                                        }
                                    })
                                }
                            }
                            
                        })
                    }
                    else{
                        self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kNewRequestId).observeSingleEvent(of:.value, with: { (snapshot) in
                            if snapshot.exists(){
                                debugPrint("Request Id:",snapshot.value!)
                                if(snapshot.value! as? String ?? "" != ""){
                                    let requestId = snapshot.value! as? String ?? ""
                                    self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
                                        if snapshot.exists() {
                                            self.updatingPopupUIOnRideRequest(snapshot: snapshot.value! as? [String:Any] ?? [:], requestId: requestId)
                                        }
                                    })
                                }
                                else{
                                    self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kTripId).observeSingleEvent(of: .value, with: { (snapshot) in
                                        if snapshot.exists(){
                                            debugPrint("Trip Id:",snapshot.value!)
                                            if(snapshot.value! as? String ?? "" != ""){
                                                let requestId = snapshot.value! as? String ?? ""
                                                self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
                                                    
                                                    if snapshot.exists() {
                                                        self.updatingPopupUIOnRideRequest(snapshot: snapshot.value! as? [String:Any] ?? [:], requestId: requestId)
                                                    }
                                                })
                                            }
                                            else{
                                                self.onlineButton.isUserInteractionEnabled = true
                                            }
                                        }
                                    })
                                }
                            }
                            
                        })
                    }
                }
            
            })
            
        self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kStatus).observeSingleEvent(of:.value, with: { (snapshot) in
                debugPrint("Trip Status :",snapshot.value!)
                if snapshot.exists(){
                    if ((snapshot.value as? String ?? "" == ApiKeyConstants.kCancelled) || (snapshot.value as? String ?? "" == ApiKeyConstants.kRejected)) && (self.appDelegate.isWithInTrip == true){
                        self.endTrip(isEnd: false,tripDetails: [:])
                        //self.initializeView() //Commented for crash issue.
                    }
//                    else if(snapshot.value as? String ?? "" == ApiKeyConstants.kComplete){
//                        self.onlineButton.isUserInteractionEnabled = true
//                    }
                }
            })
        }
    }
    
    // MARK:- Updating Popup UI On Ride Request Methods-----
    func updatingPopupUIOnRideRequest(snapshot:[String:Any],requestId:String){
        
        if self.bookingsPopups == nil{
            
            let snapShot : [String : Any] = snapshot
            let statusOfTrip : String = (snapShot[ApiKeyConstants.kStatus]! as? String ?? "").lowercased()
            let riderInfo : [String:Any] = snapShot[ApiKeyConstants.kRiderInfo] as? [String:Any] ?? [:]
            
            if (riderInfo.keys.count > 0){
                
                self.onlineButton.isUserInteractionEnabled = false
                self.btnShowCarDetails.isHidden = true
                self.showRegionView(isHidden: true, regionName: "", regionDetails: "", isWithInRegion: false)
                Utility.saveStringInUserDefaults("1", key: ApiKeyConstants.kUserDefaults.kWithInTrip)
                let pickUpAddress = riderInfo[ApiKeyConstants.kRiderPickupAddress]
                self.appDelegate.pickUpAddress = pickUpAddress as? String ?? ""
                let pickUpLocation : [String : Any] = riderInfo[ApiKeyConstants.kRiderPickupPoint] as? [String : Any] ?? [:]
                self.appDelegate.pickUpLattitude = pickUpLocation[ApiKeyConstants.kLat] as? String ?? "0.0"
                UserDefaults.standard.set(self.appDelegate.pickUpLattitude, forKey: ApiKeyConstants.kUserDefaults.kPickUpLattitude)
                self.appDelegate.pickUpLongitude = pickUpLocation[ApiKeyConstants.kLng] as? String ?? "0.0"
                UserDefaults.standard.set(self.appDelegate.pickUpLongitude, forKey: ApiKeyConstants.kUserDefaults.kPickUpLongitude)
                debugPrint(self.appDelegate.bookingPopUpCount)
                
                if(self.appDelegate.bookingPopUpCount == 0) {
                    self.appDelegate.isWithInTrip = true
                        if (Utility.isEqualtoString(statusOfTrip, ApiKeyConstants.kPending)){
                            self.appDelegate.playSound()
                        }
                        debugPrint("Hello In A Trip .....")
                        // self.isInitialLoad = false
                        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
                        debugPrint("Current VC =",currentVC)
                        
                        if ((currentVC.isKind(of: HomeViewController.self)) || (currentVC.isKind(of: UIAlertController.self))){
                            if currentVC.isKind(of: UIAlertController.self){
                                currentVC.dismiss(animated: true, completion: {
                                    let currentVC : UIViewController = UIApplication.getTopMostViewController()!
                                    if currentVC.isKind(of: HomeViewController.self){
                                        
                                        self.showBookingPopupOnRideRequest(bookingID: requestId, riderInfo: riderInfo, tripStatus: statusOfTrip)
                                    }
                                    else{
                                        if let viewControllers = self.navigationController?.viewControllers {
                                            var isVCFound = false
                                            for vc in viewControllers {
                                                // some process
                                                if vc.isKind(of: HomeViewController.self) {
                                                    isVCFound = true
                                                    self.navigationController?.popToViewController(vc, animated: true)
                                                    break
                                                }
                                                else{
                                                    isVCFound = false
                                                }
                                            }
                                            if !isVCFound {
                                                let storyBoard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
                                                let homeVc = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kHomeStoryboardId) as! HomeViewController
                                                self.navigationController?.pushViewController(homeVc, animated: true)
                                            }
                                        }
                                    }
                                })
                            }
                            else{
                                //debugPrint("Child VC=",children.first)
                                if children.first(where: { String(describing: $0.classForCoder) == "SideMenuViewController" }) != nil {
                                    children.first?.view.removeFromSuperview()
                                    children.first?.removeFromParent()
                                }
                                self.showBookingPopupOnRideRequest(bookingID: requestId, riderInfo: riderInfo, tripStatus: statusOfTrip)
                            }
                        }
                        else{
                            if let viewControllers = self.navigationController?.viewControllers {
                                var isVCFound = false
                                for vc in viewControllers {
                                    // some process
                                    if vc.isKind(of: HomeViewController.self) {
                                        isVCFound = true
                                        
                                        if ((currentVC.isKind(of: SelectCarPopupViewController.self)) || (currentVC.isKind(of: VerifyPhoneNumberPopupsViewController.self)) || (currentVC.isKind(of: SelectRegionPopupViewController.self)) || (currentVC.isKind(of: CarDetailsPopupViewController.self)) || (currentVC.isKind(of: CountryStatePopupViewController.self)) || (currentVC.isKind(of: EnlargeImageViewController.self)) || (currentVC.isKind(of: DocumentsHelpViewController.self))){
                                            currentVC.dismiss(animated: true, completion: {
                                                
                                                let currentVC : UIViewController = UIApplication.getTopMostViewController()!
                                                debugPrint("Current VC =",currentVC)
                                                if (currentVC.isKind(of: HomeViewController.self)){
                                                    
                                                    self.showBookingPopupOnRideRequest(bookingID: requestId, riderInfo: riderInfo, tripStatus: statusOfTrip)
                                                }
                                                else{
                                                    self.navigationController?.popToViewController(vc, animated: true)
                                                    let currentVC : UIViewController = UIApplication.getTopMostViewController()!
                                                    debugPrint("Current VC =",currentVC)
                                                    if (currentVC.isKind(of: HomeViewController.self)){
                                                        
                                                        self.showBookingPopupOnRideRequest(bookingID: requestId, riderInfo: riderInfo, tripStatus: statusOfTrip)
                                                    }
                                                }
                                            })
                                        }
                                        else{
                                            self.navigationController?.popToViewController(vc, animated: true)
                                        }
                                        break
                                    }
                                    else{
                                        isVCFound = false
                                    }
                                }
                                if !isVCFound {
                                    let storyBoard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
                                    let homeVc = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kHomeStoryboardId) as! HomeViewController
                                    self.navigationController?.pushViewController(homeVc, animated: true)
                                }
                            }
                        }
                  }
            }
            else{
                self.onlineButton.isUserInteractionEnabled = true
            }
            
        }
    }
    
    // MARK:- Show Booking Popup Methods-----
    
    func showBookingPopupOnRideRequest(bookingID:String, riderInfo: [String : Any], tripStatus:String){
        self.onlineButton.isHidden = true
        self.backView.isHidden = true
        self.circleImageView.isHidden = true
        self.userLocationBottomConstraints.constant = 225
        self.bookingsPopups = BookingRequestPopups.instanceFromNib(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
        self.appDelegate.bookingPopUpCount = 1
        self.bookingsPopups?.bookingObjDelegate = self
        self.bookingsPopups?.setupBookingsPopupWithMaintainingStatusOfOngoingTrip(newRequestId: bookingID, riderInfo: riderInfo , tripStatus: tripStatus)
    }
    
    // MARK:- Check Region Methods-----
    func checkRegionStatus(){
        debugPrint("User Position=",userposition)
        
        if appDelegate.appDelHomeVcRef == nil{
            appDelegate.appDelHomeVcRef = Database.database().reference()
        }
        
        if Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            
            let currentStatus = driverDetailsDict[ApiKeyConstants.kStatus] as? Bool ?? false
            if currentStatus && !appDelegate.isWithInTrip {
                self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kServiceArea).observe(.value, with: { (snapshot) in
                    if snapshot.exists(){
                        if (snapshot.value! as? Int ?? 0 == 0){
                            self.appDelegate.isWithInRegion = false
                            self.showRegionView(isHidden: false, regionName: Constants.AppAlertMessage.kOutOfRegion, regionDetails: Constants.AppAlertMessage.kGoBackToRegion, isWithInRegion: false)
                        }
                        else{
                            self.appDelegate.isWithInRegion = true
                            self.checkForZoneInfo()
                        }
                    }
                })
            }
            else{
                if !appDelegate.isWithInTrip{
                    self.checkForZoneInfo()
                }
            }
        }
    }
    
    // MARK:- EndTrip Delegate Methods-----
    func endTrip(isEnd: Bool,tripDetails:[String:Any]) {
        debugPrint("End Trip Delegate Called...")
        
        if(isMapBox) {
            self.clearMapboxMap()
            //self.setMarkerInMapBox(userposition: userposition)
        } else {
            let mapInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            self.mapView.padding = mapInsets
            self.clearGMSMap()
            //self.setUserMarker(userposition: userposition)
        }
        self.userLocationBottomConstraints.constant = 225
        self.appDelegate.stopSound()
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let status = driverDetailsDict[ApiKeyConstants.kStatus] as? Int ?? 0
        if status == 1{
            self.btnShowCarDetails.isHidden = false
        }
        else{
            self.btnShowCarDetails.isHidden = true
        }
        self.appDelegate.isNewRequestNotificationFired = false
        self.appDelegate.isScheduleRequestNotificationFired = false
        self.appDelegate.bookingPopUpCount = 0
        self.bookingsPopups = nil
        //self.homeBookingRef.removeObserver(withHandle: homeRefHandle)
        self.appDelegate.appDelHomeVcRef.removeAllObservers()
        self.configureDatabase()
        self.changeInZoom = 15.0
        btnSOS.isHidden = true
        backView.isHidden = false
        onlineButton.isHidden = false
        circleImageView.isHidden = false
        onlineButton.isUserInteractionEnabled = true
        isInitialLoad = true
        currentTripStatus = "end"
        navigationButton.isHidden = true
        appDelegate.isWithInTrip = false
        Utility.saveStringInUserDefaults("0", key: ApiKeyConstants.kUserDefaults.kWithInTrip)
        checkForZoneInfo()
        
        if(isMapBox) {
            self.drawPolygonMapBox(arrCoOrdinates: appDelegate.dictRegionCoordinates)
            self.drawPolyLineInMapBoxBetweenPickupAndDrop(lat: appDelegate.lattitude, long: appDelegate.longitude, pickUpAddress: "Current Location", tripStatus: "end")
            self.setCameraPositionOnMapBox(userposition: CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!))
        } else {
            self.drawPolygonsGMS(arrCoOrdinates: appDelegate.dictRegionCoordinates)
            self.drawPolyLineBetweenPickupAndDrop(lat: appDelegate.lattitude, long: appDelegate.longitude, pickUpAddress: "Current Location", tripStatus: "end")
            self.focusOnCurrentLocationForGoogleMap()
        }
        
        self.appDelegate.lastLattitude = "0.0"
        self.appDelegate.lastLongitude = "0.0"
        
        if(isEnd){
            isTripStarted = false
            endTripDict = tripDetails
            
            let vc = self.navigationController?.viewControllers.last
            if vc == self {
                self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kTripDetailsSegue, sender: nil)
            }
        }
        self.appDelegate.routeLocationArr.removeAll()
        self.appDelegate.pickupRouteLocationArr.removeAll()
        self.appDelegate.startTripTime = 0
        self.appDelegate.endTripTime = 0
        self.appDelegate.acceptTime = 0
        self.appDelegate.arrivedTime = 0
        UserDefaults.standard.removeObject(forKey: ApiKeyConstants.kUserDefaults.kPickUpLocation)
        UserDefaults.standard.removeObject(forKey: ApiKeyConstants.kUserDefaults.kTripLocation)
        UserDefaults.standard.removeObject(forKey: ApiKeyConstants.kUserDefaults.kStartTime)
        UserDefaults.standard.removeObject(forKey: ApiKeyConstants.kUserDefaults.kEndTime)
        UserDefaults.standard.removeObject(forKey: ApiKeyConstants.kUserDefaults.kAcceptTime)
        UserDefaults.standard.removeObject(forKey: ApiKeyConstants.kUserDefaults.kArrivedTime)
    }
    
    // MARK:- Clear Maps Methods-----
    func clearGMSMap(){
        self.mapView.clear()
        self.oldPolyLine.map = nil
        self.allCarMarker.removeAll()
    }
    
    func clearMapboxMap(){
        self.mapboxView.remove(self.routeLine)
        self.clearMap()
        self.allAnnotations.removeAll()
    }
    // MARK:- Navigation To End Trip Screen-----
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.StoryboardSegueConstants.kTripDetailsSegue {
            let endTripDetails : EndTripDetailsViewController = segue.destination as! EndTripDetailsViewController
            endTripDetails.endTripDetailsDict = endTripDict
        }
    }
    
    // MARK:- Driver Trip Status Change Delegate Methods-----
    func changeTripStatusAndUpdateLocation(dropLattitude:String,dropLongitude:String,dropAddress:String,tripStatus:String) {
        
        if(isMapBox) {
            self.clearMapboxMap()
            
            self.drawPolygonMapBox(arrCoOrdinates: appDelegate.dictRegionCoordinates)
        } else {
            self.clearGMSMap()
            
            self.drawPolygonsGMS(arrCoOrdinates: appDelegate.dictRegionCoordinates)
        }
        
        if(Utility.isEqualtoString(tripStatus, ApiKeyConstants.kAccepted)){
            self.userLocationBottomConstraints.constant = 225
            navigationButton.isHidden = false
            currentTripStatus = tripStatus
            currentDropLat = dropLattitude
            currentDropLong = dropLongitude
            currentDropAddress = dropAddress
            if(isMapBox) {
                self.drawPolyLineInMapBoxBetweenPickupAndDrop(lat: dropLattitude, long: dropLongitude, pickUpAddress: dropAddress, tripStatus: ApiKeyConstants.kAccepted)
            } else {
                drawPolyLineBetweenPickupAndDrop(lat: dropLattitude, long: dropLongitude, pickUpAddress: dropAddress, tripStatus: ApiKeyConstants.kAccepted)
            }
        }
        else if(Utility.isEqualtoString(tripStatus, ApiKeyConstants.kArrived)){
            self.userLocationBottomConstraints.constant = 225
            navigationButton.isHidden = true
            currentTripStatus = tripStatus
            currentDropLat = dropLattitude
            currentDropLong = dropLongitude
            currentDropAddress = dropAddress
            if(isMapBox) {
                self.drawPolyLineInMapBoxBetweenPickupAndDrop(lat: dropLattitude, long: dropLongitude, pickUpAddress: dropAddress, tripStatus: ApiKeyConstants.kArrived)
            } else {
                drawPolyLineBetweenPickupAndDrop(lat: dropLattitude, long: dropLongitude, pickUpAddress: dropAddress, tripStatus: ApiKeyConstants.kArrived)
            }
        }
        else if(Utility.isEqualtoString(tripStatus, ApiKeyConstants.kIntransit)){
            self.userLocationBottomConstraints.constant = 225
            currentTripStatus = tripStatus
            navigationButton.isHidden = false
            isTripStarted = true
            currentDropLat = dropLattitude
            currentDropLong = dropLongitude
            currentDropAddress = dropAddress
            btnSOS.isHidden = false
            if(isMapBox) {
                self.drawPolyLineInMapBoxBetweenPickupAndDrop(lat: dropLattitude, long: dropLongitude, pickUpAddress: dropAddress, tripStatus: ApiKeyConstants.kIntransit)
            } else {
                drawPolyLineBetweenPickupAndDrop(lat: dropLattitude, long: dropLongitude, pickUpAddress: dropAddress, tripStatus: ApiKeyConstants.kIntransit)
            }
        }
        else{
            self.userLocationBottomConstraints.constant = 225
            //            isDropDelegateCalled = true
            if(isMapBox) {
                self.drawPolyLineInMapBoxBetweenPickupAndDrop(lat: dropLattitude, long: dropLongitude, pickUpAddress: dropAddress, tripStatus: "")
            } else {
                drawPolyLineBetweenPickupAndDrop(lat: dropLattitude, long: dropLongitude, pickUpAddress: dropAddress, tripStatus: "")
            }
        }
    }
    
    // MARK:- Start & Stop Animation Methods-----
    func startAnimation(){
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 15.0// Speed
        rotation.repeatCount = Float.greatestFiniteMagnitude// Repeat forever.
        circleImageView.layer.add(rotation, forKey: "Spin")
    }
    
    func removeAnimation() {
        circleImageView.layer.removeAnimation(forKey: "Spin")
    }
    
    // MARK:- Sidemenu delegate method -----
    func sideMenuRemoved(isSideMenuRemoved: Bool) {
        if isSideMenuRemoved{
            //self.appDelegate.isSideMenuOpen = false
            onlineOfflineDriver()
            if !appDelegate.isWithInTrip {
                checkForZoneInfo()
            }
            
            if self.bookingsPopups != nil && appDelegate.isWithInTrip{
                self.bookingsPopups?.isHidden = false
            }
        }
    }
    
    // MARK:- Online Offline Status Change Methods (Called After api Calling)-----
    func onlineOfflineDriver(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let status = driverDetailsDict[ApiKeyConstants.kStatus] as? Int ?? 0
        //self.locationManager.startUpdatingLocation()
        if status == 1 {
            self.appDelegate.arrServices.removeAll()
            self.appDelegate.arrServices = UserDefaults.standard.array(forKey: ApiKeyConstants.kUserDefaults.kCarDetailsServices) as? [[String : AnyObject]] ?? []
            self.appDelegate.selectedCarDict.removeAll()
            self.appDelegate.selectedCarDict = UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kCarDetailsDictionary) as? [String : AnyObject] ?? [:]
            
            self.appDelegate.carCurrentRegionName = UserDefaults.standard.value(forKey: ApiKeyConstants.kUserDefaults.kCarDetailsRegion) as? String ?? "NA"
            let plateNumber = self.appDelegate.selectedCarDict[ApiKeyConstants.CarDetails.kLicensePlateNo] as? String ?? ""
            
            self.btnShowCarDetails.setTitle(plateNumber.uppercased(), for: .normal)
            self.btnShowCarDetails.isHidden = false
            startAnimation()
            onlineButton.backgroundColor = Constants.AppColour.kAppRedColor
            onlineButton.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 22.0)
            onlineButton.titleLabel?.lineBreakMode = .byWordWrapping
            onlineButton.titleLabel?.textAlignment = .center
            onlineButton.titleLabel?.numberOfLines = 0
            onlineButton.setTitle("Go\nOffline", for: .normal)
            onlineButton.layer.cornerRadius = onlineButton.frame.height/2
            onlineButton.clipsToBounds = true
            circleImageView.image = UIImage(named: "offlineCircle")
            circleImageView.contentMode = .scaleAspectFit
            UIApplication.shared.isIdleTimerDisabled = true
            debugPrint("Region=",appDelegate.dictRegionCoordinates)
            settingButton.isHidden = true
            debugPrint("OnlineOffline")
            if ((appDelegate.lattitude != "0.0") && (appDelegate.longitude != "0.0")){
                if appDelegate.appDelHomeVcRef == nil{
                    appDelegate.appDelHomeVcRef = Database.database().reference()
                }
                debugPrint("Lat=",appDelegate.lattitude)
                debugPrint("Lon=",appDelegate.longitude)
                userposition = CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
//                    self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.klattitude).setValue(self.appDelegate.lattitude)
//                    self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.klongitude).setValue(self.appDelegate.longitude)
                    self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.ktimeStamp).setValue(Utility.currentTimeInMiliseconds())
                    
                    let values = [ApiKeyConstants.klattitude:self.appDelegate.lattitude, ApiKeyConstants.klongitude:self.appDelegate.longitude]
                    debugPrint("Values=",values)
                    self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").updateChildValues(values)
                })
            }
            
            if(isMapBox) {
                if(arrPolygonMapBox.count > 0) {
                    for polygon in self.arrPolygonMapBox {
                        self.mapboxView.remove(polygon)
                    }
                    arrPolygonMapBox.removeAll()
                }
                self.drawPolygonMapBox(arrCoOrdinates: appDelegate.dictRegionCoordinates)
                
            } else {
                if(arrPolygon.count > 0) {
                    for polygon in self.arrPolygon{
                        polygon.map = nil
                    }
                    arrPolygon.removeAll()
                }
                self.drawPolygonsGMS(arrCoOrdinates: appDelegate.dictRegionCoordinates)
                
            }
            
            if (!appDelegate.isWithInTrip) {
                checkRegionStatus()
            }
            
        }
        else {
            self.btnShowCarDetails.isHidden = true
            removeAnimation()
            onlineButton.backgroundColor = Constants.AppColour.kAppGreenColor
            onlineButton.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 23.0)
            onlineButton.titleLabel?.lineBreakMode = .byWordWrapping
            onlineButton.titleLabel?.textAlignment = .center
            onlineButton.titleLabel?.numberOfLines = 0
            onlineButton.setTitle("Go\nOnline", for: .normal)
            onlineButton.layer.cornerRadius = onlineButton.frame.height/2
            onlineButton.clipsToBounds = true
            circleImageView.image = UIImage(named: "counter")
            UIApplication.shared.isIdleTimerDisabled = false
            settingButton.isHidden = false
            onlineButton.isUserInteractionEnabled = true
            
            if(isMapBox) {
                for polygon in self.arrPolygonMapBox{
                    self.mapboxView.remove(polygon)
                }
                self.arrPolygonMapBox.removeAll()
            } else {
                for polygon in self.arrPolygon{
                    polygon.map = nil
                }
                self.arrPolygon.removeAll()
            }
            
            if (!appDelegate.isWithInTrip) {
                checkRegionStatus()
            }
            
        }
        let tokenId = driverDetailsDict[ApiKeyConstants.kid] as? String ?? ""
        self.updateFirebaseDb(status: status, authToken: tokenId)
    }
    
    
    // MARK:- Driver Status Api Call Methods-----
    func changeDriverStatus(status:Bool,token:String) {
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        let onlineOfflineUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kOnlineOfflineStatusApi
        
        let dictBodyParams : [String : AnyObject] = [ApiKeyConstants.kStatus : status ? 0 as AnyObject : 1 as AnyObject, ApiKeyConstants.klattitude : self.appDelegate.lattitude as AnyObject, ApiKeyConstants.klongitude : self.appDelegate.longitude as AnyObject]
        
        debugPrint("Header : ",dictHeaderParams)
        debugPrint("Body : ",dictBodyParams)
        debugPrint("Url : ",onlineOfflineUrl)
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Loading...")
        }
        Utility.removeAppCookie()
        APIWrapper.requestPUTURL(onlineOfflineUrl, params: dictBodyParams as [String : AnyObject], headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        var driverDetailsDict = [String : Any]()
                        if Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
                            driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                        }
                        driverDetailsDict[ApiKeyConstants.kStatus] = dictBodyParams[ApiKeyConstants.kStatus]
                        debugPrint(driverDetailsDict)
                        Utility.saveToUserDefaultsWithKeyandDictionary(driverDetailsDict, key: ApiKeyConstants.kUserDefaults.kDriverDetails)
                        
                        
                        if(self.isMapBox) {
                            for polygon in self.arrPolygonMapBox{
                                self.mapboxView.remove(polygon)
                            }
                            self.arrPolygonMapBox.removeAll()
                        } else {
                            for polygon in self.arrPolygon{
                                polygon.map = nil
                            }
                            self.arrPolygon.removeAll()
                        }
                        
                        var dictResult      = [String: AnyObject]()
                        var dictRegion      = [[String : AnyObject]]()
                        var currentRegion   = [String : AnyObject]()
                        
                        if !status {
                            dictResult = (dictResponse![ApiKeyConstants.kResult] as? [String: AnyObject] ?? [:])
                            dictRegion      = (dictResult["regionInfo"] as? [[String : AnyObject]] ?? [])
                            currentRegion   = dictResult["currentRegion"] as? [String : AnyObject] ?? [:]
                            
                            self.appDelegate.arrServices     = (dictResult["services"] as? [[String : AnyObject]] ?? [])
                            self.appDelegate.carCurrentRegionName = currentRegion["name"] as? String ?? "NA"
                            
                            UserDefaults.standard.set(self.appDelegate.arrServices, forKey: ApiKeyConstants.kUserDefaults.kCarDetailsServices)
                            UserDefaults.standard.set(self.appDelegate.carCurrentRegionName, forKey: ApiKeyConstants.kUserDefaults.kCarDetailsRegion)
                            UserDefaults.standard.set(self.appDelegate.selectedCarDict, forKey: ApiKeyConstants.kUserDefaults.kCarDetailsDictionary)
                            
                            if(dictRegion.count > 0) {
                                self.appDelegate.dictRegionCoordinates.removeAll()
                            }
                            
                            for index in 0..<dictRegion.count {
                                let dictGeometry = (dictRegion[index]["geometry"]) as? [String: AnyObject] ?? [:]
                                
                                let polygonCords = dictGeometry["coordinates"] as? [[AnyObject]] ?? [[]]
                                let arrPloygonCOrds = polygonCords[0]
                                
                                print("Cords ------------- ", arrPloygonCOrds)
                                self.appDelegate.dictRegionCoordinates.append(arrPloygonCOrds)
                            }
                            
                            if self.appDelegate.dictRegionCoordinates.count > 0{
                                UserDefaults.standard.set(self.appDelegate.dictRegionCoordinates, forKey: ApiKeyConstants.kUserDefaults.kRegionCord)
                            }
                            debugPrint("Cord =",self.appDelegate.dictRegionCoordinates)
                            let tokenId = driverDetailsDict[ApiKeyConstants.kid] as? String ?? ""
                            self.updateFirebaseDb(status: 1, authToken: tokenId)
                        }
                        
                        self.onlineOfflineDriver()
                        
                        if !status {
                            
                            if(self.appDelegate.selectedCarDict.count > 0) {
                                
                                let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                                self.carDetailsPopup = storyBoard.instantiateViewController(withIdentifier: "CarDetailsPopupViewController") as! CarDetailsPopupViewController
                                self.carDetailsPopup.tableServicesDataArr    = self.appDelegate.arrServices
                                self.carDetailsPopup.carColor                = (self.appDelegate.selectedCarDict[ApiKeyConstants.CarDetails.kColor] as? String ?? "").capitalized
                                self.carDetailsPopup.carName                 = self.appDelegate.selectedCarDict[ApiKeyConstants.CarDetails.kModel] as? String ?? ""
                                self.carDetailsPopup.carManufractureName     = self.appDelegate.selectedCarDict[ApiKeyConstants.CarDetails.kManufacturer] as? String ?? ""
                                self.carDetailsPopup.plateNumber             = (self.appDelegate.selectedCarDict[ApiKeyConstants.CarDetails.kLicensePlateNo] as? String ?? "").uppercased()
                                if Utility.isEqualtoString(self.appDelegate.carCurrentRegionName, "NA"){
                                    self.carDetailsPopup.regionName = self.appDelegate.carCurrentRegionName
                                }
                                else{
                                    self.carDetailsPopup.regionName = self.appDelegate.carCurrentRegionName.capitalized
                                }
                                //self.appDelegate.serviceTypePopup = true
                                self.btnShowCarDetails.setTitle(self.carDetailsPopup.plateNumber.uppercased(), for: .normal)
                                self.carDetailsPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                                self.present(self.carDetailsPopup, animated: true, completion: nil)
                            }
                        }
                        
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
            debugPrint("Error :",error)
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
        
    }
    
    func updateCarServiceType(){
        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"] 
        let bodyParams : [String : String] = [ApiKeyConstants.klattitude : self.appDelegate.lattitude, ApiKeyConstants.klongitude : self.appDelegate.longitude]
        debugPrint(bodyParams)
        Utility.removeAppCookie()
        let carServiceUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetCarServiceType
        
        APIWrapper.requestPOSTURL(carServiceUrl, params: bodyParams, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        debugPrint(dictResponse!)
                        self.appDelegate.arrServices.removeAll()
                        self.appDelegate.arrServices = (dictResponse![ApiKeyConstants.kResult] as? [[String : AnyObject]] ?? [])
                        UserDefaults.standard.set(self.appDelegate.arrServices, forKey: ApiKeyConstants.kUserDefaults.kCarDetailsServices)
                        
                        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                        self.carDetailsPopup = storyBoard.instantiateViewController(withIdentifier: "CarDetailsPopupViewController") as! CarDetailsPopupViewController
                        self.carDetailsPopup.tableServicesDataArr    = self.appDelegate.arrServices
                        self.carDetailsPopup.carColor                = (self.appDelegate.selectedCarDict[ApiKeyConstants.CarDetails.kColor] as? String ?? "").capitalized
                        self.carDetailsPopup.carName                 = self.appDelegate.selectedCarDict[ApiKeyConstants.CarDetails.kModel] as? String ?? ""
                        self.carDetailsPopup.carManufractureName     = self.appDelegate.selectedCarDict[ApiKeyConstants.CarDetails.kManufacturer] as? String ?? ""
                        self.carDetailsPopup.plateNumber             = (self.appDelegate.selectedCarDict[ApiKeyConstants.CarDetails.kLicensePlateNo] as? String ?? "").uppercased()
                        let currentRegion = dictResponse!["currentRegion"] as? [String : AnyObject] ?? [:]
                        self.appDelegate.carCurrentRegionName = currentRegion["name"] as? String ?? "NA"
                        if Utility.isEqualtoString(self.appDelegate.carCurrentRegionName, "NA"){
                            self.carDetailsPopup.regionName = self.appDelegate.carCurrentRegionName
                        }
                        else{
                            self.carDetailsPopup.regionName = self.appDelegate.carCurrentRegionName.capitalized
                        }
                        
                        //self.appDelegate.serviceTypePopup = true
                        self.btnShowCarDetails.setTitle(self.carDetailsPopup.plateNumber.uppercased(), for: .normal)
                        self.carDetailsPopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                        self.present(self.carDetailsPopup, animated: true, completion: nil)
                        
                    } else {
                        self.btnShowCarDetails.setTitle(self.carDetailsPopup.plateNumber.uppercased(), for: .normal)
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
                    }
                }
                else{
                    self.btnShowCarDetails.setTitle(self.carDetailsPopup.plateNumber.uppercased(), for: .normal)
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
                }
            }
            else{
                self.btnShowCarDetails.setTitle(self.carDetailsPopup.plateNumber.uppercased(), for: .normal)
                Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
            }
        })
        { (error) -> Void in
            self.btnShowCarDetails.setTitle(self.carDetailsPopup.plateNumber.uppercased(), for: .normal)
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
        }
    }
    // MARK:- Get Car List Api Call Methods-----
    func fetchAddedcarList(authToken:String) {
        
        let token = "Bearer " + authToken
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
        let fetchCarListUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetAddedCarList
        
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
                        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                        let controller = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSelectCarStoryboardId) as! SelectCarViewController
                        controller.tableDataArr = carsArray
                        controller.isFromHome  = true
                        controller.callback    = { message in
                            let isOnlineStatus = message[ApiKeyConstants.kisOnline] as? Bool ?? false
                            self.appDelegate.selectedCarDict.removeAll()
                            self.appDelegate.selectedCarDict = message[ApiKeyConstants.CarDetails.kCarDict] as? [String:AnyObject] ?? [:]
                            self.changeDriverStatus(status: !isOnlineStatus, token: authToken)
                        }
                        self.present(controller, animated: true, completion: nil)
                    } else {
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNoCarAvailable, Button_Title: Constants.AppAlertAction.kOKButton, self)
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
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
}

// MARK:- CLLocationManagerDelegate Methods ------
extension HomeViewController : CLLocationManagerDelegate {
    
    func getCurrentLocation() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = 20
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.delegate = self as CLLocationManagerDelegate
        if !(isMapBox) {
            self.mapView.isMyLocationEnabled = true
        }
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK:- Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        appDelegate.lastLocation = userLocation
        var lastDistance : CLLocationDistance = 0.0
        //userLocation?.horizontalAccuracy
        if appDelegate.startLocation == nil {
            appDelegate.startLocation = locations.first
        } else if let location = locations.last {
            if appDelegate.lattitude != "0.0" && appDelegate.longitude != "0.0"{
                
                let myEarlierLocation = CLLocation(latitude: Double(appDelegate.lattitude)! , longitude: Double(appDelegate.longitude)!)
                lastDistance = myEarlierLocation.distance(from: location)
            }
            else{
                lastDistance = 0.0
            }
            debugPrint(lastDistance)
        }
        
        appDelegate.lastLocation = locations.last
        
        
        if isInitialLoad && !self.appDelegate.isWithInTrip {
//            Jeet
            var long = Double((userLocation?.coordinate.longitude)!)
            var lat = Double((userLocation?.coordinate.latitude)!)
            long = Double(round(100000*long)/100000)
            lat = Double(round(100000*lat)/100000)
//            Jeet
            appDelegate.lattitude = String(lat)
            appDelegate.longitude = String(long)
            appDelegate.lastLattitude = appDelegate.lattitude
            appDelegate.lastLongitude = appDelegate.longitude
            self.updatedLocationInFireBase(userLocation: userLocation!)
            if appDelegate.endTriplattitude == "0.0" && appDelegate.endTriplongitude == "0.0"{
                
                
                if(!isMapBox) {
                    self.oldPolyLine.map = nil
                    self.allCarMarker.removeAll()
                } else {
                    self.mapboxView.remove(self.routeLine)
                    self.allAnnotations.removeAll()
                }
                
                appDelegate.endTriplongitude = appDelegate.longitude
                appDelegate.endTriplattitude = appDelegate.lattitude
            }
            
            if(isMapBox) {
                self.setCameraPositionOnMapBox(userposition: CLLocationCoordinate2D(latitude: Double((userLocation?.coordinate.latitude
                    )!), longitude: Double((userLocation?.coordinate.longitude)!)))
            } else {
                let mapInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
                self.mapView.padding = mapInsets
                let camera = GMSCameraPosition.camera(withLatitude: (userLocation?.coordinate.latitude)!,
                                                      longitude: (userLocation?.coordinate.longitude)!, zoom: changeInZoom)
                self.mapView?.animate(to: camera)
            }
            
            isInitialLoad = false
            //            self.locationManager.stopUpdatingLocation()
        }
//        Jeet
//        var long = Double((userLocation?.coordinate.longitude)!)
//        var lat = Double((userLocation?.coordinate.latitude)!)
//
//        long = Double(round(100000*long)/100000)
//        lat = Double(round(100000*lat)/100000)
//        appDelegate.lattitude = String(long)
//        appDelegate.longitude = String(lat)
//        Jeet
        appDelegate.lattitude = String((userLocation?.coordinate.latitude)!)
        appDelegate.longitude = String((userLocation?.coordinate.longitude)!)
        appDelegate.lastLattitude = appDelegate.lattitude
        appDelegate.lastLongitude = appDelegate.longitude
        userposition = CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!)
        debugPrint("Current Location=",userposition)
        if(isMapBox) {
            self.setMarkerInMapBox(userposition: userposition)
        } else {
            self.setUserMarker(userposition: userposition)
        }
        
        if (!appDelegate.isWithInTrip) {
            checkRegionStatus()
        }
        
//        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { (timer) in
            if(lastDistance > 10) {
                debugPrint("Firebase Location update",lastDistance)
                lastDistance = 0
                print("---------\(userLocation!)")
                
                self.updatedLocationInFireBase(userLocation: userLocation!)
                if self.appDelegate.isWithInTrip{
                    if self.isTripStarted {
                        let dict : [String : Any] = [ApiKeyConstants.kLat : Double((userLocation?.coordinate.latitude)!) , ApiKeyConstants.klongitude : Double((userLocation?.coordinate.longitude)!)]
                        self.appDelegate.routeLocationArr += [dict as AnyObject]
                        UserDefaults.standard.set(self.appDelegate.routeLocationArr, forKey: ApiKeyConstants.kUserDefaults.kTripLocation)
                    }
                    else{
                        let dict : [String : Any] = [ApiKeyConstants.kLat : Double((userLocation?.coordinate.latitude)!) , ApiKeyConstants.klongitude : Double((userLocation?.coordinate.longitude)!)]
                        self.appDelegate.pickupRouteLocationArr += [dict as AnyObject]
                        UserDefaults.standard.set(self.appDelegate.pickupRouteLocationArr, forKey: ApiKeyConstants.kUserDefaults.kPickUpLocation)
                    }
//                    if self.tripDistance > 1000{
//                        if (self.isMapBox){
//                            if self.directionsRoute!.coordinateCount > 0{
//                                let routeCoordinates = self.directionsRoute?.coordinates!
//
//                                self.mapboxView?.setVisibleCoordinates(routeCoordinates!, count: self.directionsRoute!.coordinateCount, edgePadding: .init(top: 30, left: 60, bottom: 290, right: 60), animated: true)
//
//                            }
//                        }
//                        else{
//                            var bounds = GMSCoordinateBounds()
//                            for marker in self.allCarMarker
//                            {
//                                bounds = bounds.includingCoordinate(marker.position)
//                            }
//                            let update = GMSCameraUpdate.fit(bounds, withPadding: 70)
//                            self.mapView.animate(with: update)
//                        }
//                    }
//                    else{
//                        self.changeInZoom = 15.0
//                        if(self.isMapBox) {
//                            self.setCameraPositionOnMapBox(userposition: self.userposition)
//                        } else {
//                            self.focusOnCurrentLocationForGoogleMap()
//                        }
//                    }
//                }
//                else{
//                    self.changeInZoom = 15.0
//                    if(self.isMapBox) {
//                        self.setCameraPositionOnMapBox(userposition: self.userposition)
//                    } else {
//                        self.focusOnCurrentLocationForGoogleMap()
//                    }
                }
//               Jeet
                var long = Double((userLocation?.coordinate.longitude)!)
                var lat = Double((userLocation?.coordinate.latitude)!)
                long = Double(round(100000*long)/100000)
                lat = Double(round(100000*lat)/100000)
                appDelegate.lattitude = String(lat)
                appDelegate.longitude = String(long)
                appDelegate.lastLattitude = appDelegate.lattitude
                appDelegate.lastLongitude = appDelegate.longitude
//                self.appDelegate.lattitude = String((userLocation?.coordinate.latitude)!)
//                self.appDelegate.longitude = String((userLocation?.coordinate.longitude)!)
//             Jeet
                
                
                
//                self.updateTravelledPath(currentLoc: CLLocationCoordinate2DMake((userLocation?.coordinate.latitude)!, (userLocation?.coordinate.longitude)!))
                
                
            }
//        if UIApplication.shared.applicationState == .background {
//            print("Location Change In Background =",userLocation!)
//        }
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error)
        if isLocationCheckDoneOnce == 0 {
            isLocationCheckDoneOnce = 1
            switch (CLLocationManager.authorizationStatus()) {
            case .authorizedAlways:
                debugPrint("Location Allowed.")
                if let viewWithTag = self.view.viewWithTag(1029) {
                    viewWithTag.removeFromSuperview()
                }
                break
            case .authorizedWhenInUse:
                if let viewWithTag = self.view.viewWithTag(1029) {
                    viewWithTag.removeFromSuperview()
                }
                break
            case .denied, .notDetermined, .restricted:
                Utility.isLocationEnabled(targetView: self.view, targetedVC: self, message: Constants.AppAlertMessage.kAllowLocationService, actionEnabled: true, btnMessage: Constants.AppAlertAction.kTurnOn)
                break
            default:
                break
            }
        }
    }
}


// MARK:- Google Map Related task
extension HomeViewController : GMSMapViewDelegate {
    
    //Mapview delegate
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if mapView.camera.zoom > 15.0{
            self.changeInZoom = mapView.camera.zoom
        }

        debugPrint("map zoom is ",String(self.changeInZoom))
    }
    
    func focusOnCurrentLocationForGoogleMap(){
        let mapInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.mapView.padding = mapInsets
        let camera = GMSCameraPosition.camera(withLatitude: Double(appDelegate.lattitude)!,
                                              longitude: Double(appDelegate.longitude)!, zoom: changeInZoom)
        self.mapView?.animate(to: camera)
    }
    
    func initializeGSMMap() {
        
        self.getCurrentLocation()
        
        if appDelegate.lastLattitude != "0.0" && appDelegate.lastLongitude != "0.0"{
            appDelegate.lattitude = appDelegate.lastLattitude
            appDelegate.longitude = appDelegate.lastLongitude
            userposition = CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!)
        }
        
        //polygon.map = nil
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        
    }
    
    func setUserMarker(userposition: CLLocationCoordinate2D) {
        if userMarker.map == nil {
            userMarker = GMSMarker(position: userposition)
            userMarker.icon = UIImage(named:"carIcon")
            //userMarker.title = "Current Location"
            userMarker.map = self.mapView
            allCarMarker.append(userMarker)
            userMarker.appearAnimation = GMSMarkerAnimation.none
        } else {
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            userMarker.position = userposition
            userMarker.icon = UIImage(named:"carIcon")
            //userMarker.title = "Current Location"
            CATransaction.commit()
        }
    }
     
    func setPickUpPointMarker(userposition: CLLocationCoordinate2D){
        if initialMarker.map == nil {
            initialMarker = GMSMarker(position: userposition)
            initialMarker.icon = UIImage(named: "initialMarker")
            initialMarker.map = self.mapView
            allCarMarker.append(initialMarker)
            initialMarker.appearAnimation = GMSMarkerAnimation.none
        }
        else {
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            userMarker.position = userposition
            userMarker.icon = UIImage(named:"initialMarker")
            //userMarker.title = "Current Location"
            CATransaction.commit()
        }
    }
    
    // Draw Polyline Between Source & Destination-----
    func drawPolyLineBetweenPickupAndDrop(lat:String,long:String,pickUpAddress:String,tripStatus:String)->Void{
        SVProgressHUD.show()
        debugPrint(appDelegate.lattitude,appDelegate.longitude)
        userposition = CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!)
        
        if !(Utility.isEqualtoString(tripStatus, "") || Utility.isEqualtoString(tripStatus, "end")){
            self.setPickUpPointMarker(userposition: userposition)
        }
        
        self.setUserMarker(userposition: userposition)
        
        if Utility.isEqualtoString(tripStatus, ApiKeyConstants.kAccepted){
            let position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
            userLocationMarker.map = nil
            userLocationMarker = GMSMarker(position: position)
            userLocationMarker.icon = UIImage(named:"userLocation")
            //userLocationMarker.title = pickUpAddress
            userLocationMarker.map = self.mapView
            allCarMarker.append(userLocationMarker)
        }
        else if(Utility.isEqualtoString(tripStatus, ApiKeyConstants.kArrived) || Utility.isEqualtoString(tripStatus, ApiKeyConstants.kIntransit)){
            let position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
            dropLocationMarker.map = nil
            dropLocationMarker = GMSMarker(position: position)
            dropLocationMarker.icon = UIImage(named:"dropLocation")
            //dropLocationMarker.title = pickUpAddress
            dropLocationMarker.map = self.mapView
            allCarMarker.append(dropLocationMarker)
        }
        
        let originCord = CLLocation(latitude: Double(appDelegate.lattitude)! , longitude: Double(appDelegate.longitude)!)
        let origin = "\(originCord.coordinate.latitude),\(originCord.coordinate.longitude)"
        debugPrint("Origin",originCord.coordinate.latitude)
        
        let destCord = CLLocation(latitude: Double(lat)! , longitude: Double(long)!)
        let distance : CLLocationDistance = originCord.distance(from: destCord)
        self.tripDistance = distance
        
        let destination = "\(destCord.coordinate.latitude),\(destCord.coordinate.longitude)"
        debugPrint("Dest",destCord.coordinate.latitude)
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Constants.SocialLoginKeys.kGoogleMapsApiKey)"
        debugPrint(url)
        
        Alamofire.request(url).responseJSON { response in
            
            guard let jsonResponce = try? JSON(data: response.data!) else {
                //                failure("error")
                return
                
            }
            let routes = jsonResponce["routes"].arrayValue
            self.oldPolyLine.map = nil
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                self.path = GMSPath(fromEncodedPath: points!)!
                
            }
            self.oldPolyLine = GMSPolyline(path: self.path)
            var strokecolor = UIColor()
            
            if Utility.isEqualtoString(tripStatus, ApiKeyConstants.kAccepted){
                strokecolor = Constants.AppColour.kAppBlackColor
            }
            else{
                strokecolor = Constants.AppColour.kAppPolyLineGreenColor
            }
            self.oldPolyLine.strokeColor = strokecolor
            self.oldPolyLine.strokeWidth = 3.0
            self.oldPolyLine.map = self.mapView
            SVProgressHUD.dismiss()
            if tripStatus == "end"{
                self.oldPolyLine.map = nil
                self.changeInZoom = 15.0
                let mapInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
                self.mapView.padding = mapInsets
                let camera = GMSCameraPosition.camera(withLatitude: Double(self.appDelegate.lattitude)!,
                                                      longitude: Double(self.appDelegate.longitude)!, zoom: self.changeInZoom)
                self.mapView?.animate(to: camera)
            }
            else{
                /*if distance <= 70{
                    let firstLocation = (self.allCarMarker.first)!.position
                    var bounds = GMSCoordinateBounds(coordinate: firstLocation, coordinate: firstLocation)
                    
                    for marker in self.allCarMarker {
                        bounds = bounds.includingCoordinate(marker.position)
                    }
                    self.gmsBounds = bounds
                    let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(190.0))
                    self.mapView.animate(with: update)
                    
                    /*let mapInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 290.0, right: 0.0)
                    self.mapView.padding = mapInsets
                    let bounds = GMSCoordinateBounds(path: self.path)
                    let update = GMSCameraUpdate.fit(bounds)
                    self.mapView.animate(with: update)*/
                    //self.changeInZoom = 15.0
                    //let camera = GMSCameraPosition.camera(withLatitude: Double(self.appDelegate.lattitude)!,longitude: Double(self.appDelegate.longitude)!, zoom: self.changeInZoom)
                    //self.mapView?.animate(to: camera)
                }
                else{*/
//                    var bounds = GMSCoordinateBounds()
//                    for marker in self.allCarMarker
//                    {
//                        bounds = bounds.includingCoordinate(marker.position)
//                    }
                    //self.changeInZoom = 15.0
                
                
                    let mapInsets = UIEdgeInsets(top: 100.0, left: 20.0, bottom: 290.0, right: 20.0)
                    self.mapView.padding = mapInsets
                    let bounds = GMSCoordinateBounds(path: self.path)
                    self.gmsBounds = bounds
                    let update = GMSCameraUpdate.fit(bounds)
                    self.mapView.animate(with: update)
                //}
//                    self.changeInZoom = 12.8
            
            }
        }
    }
    
    // MARK:- Draw Region -----
    func drawPolygonsGMS(arrCoOrdinates : [[AnyObject]]){
        self.mapView.delegate = self
        let rect = GMSMutablePath()
        self.arrPolygon.removeAll()
        for index in 0..<arrCoOrdinates.count{
            
            print("INDEX COUNT _______________", index)
            let mainCords = arrCoOrdinates[index]
            // let subCords = mainCords[0] as! [AnyObject]
            
            for arrcords in mainCords {
                let objcord = arrcords as? [AnyObject] ?? []
                let lat = Double(objcord[1] as? CGFloat ?? 0.0)
                let long = Double(objcord[0] as? CGFloat ?? 0.0)
                let cordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
                rect.add(cordinate)
            }
            
            let polygon = GMSPolygon()
            
            polygon.path = rect
            rect.removeAllCoordinates()
            polygon.fillColor = Constants.AppColour.kAppPolygonGreenColor
            polygon.strokeColor = Constants.AppColour.kAppGreenColor
            polygon.strokeWidth = 2
            polygon.map = self.mapView
            
            self.arrPolygon.append(polygon)
        }
    }
}

// MARK:- MapBox Related Task

extension HomeViewController : MGLMapViewDelegate {
    
    func clearMap() {
        for annotation in allAnnotations {
            self.mapboxView.removeAnnotation(annotation)
        }
        
        if(arrPolygonMapBox.count > 0) {
            for polygon in self.arrPolygonMapBox {
                self.mapboxView.remove(polygon)
            }
            arrPolygonMapBox.removeAll()
        }
    }
    
    func initializeMapBox() {
        //mapboxView.setUserTrackingMode(.follow, animated: true)
        self.getCurrentLocation()
        
        mapboxView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //mapboxView.tintColor = .darkGray
        //mapboxView.styleURL = MGLStyle.streetsStyleURL
        
        // Set the map’s center coordinate and zoom level.
        if appDelegate.lastLattitude != "0.0" && appDelegate.lastLongitude != "0.0" {
            
            appDelegate.lattitude = appDelegate.lastLattitude
            appDelegate.longitude = appDelegate.lastLongitude
            
            self.setCameraPositionOnMapBox(userposition: CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!))
            
            self.setMarkerInMapBox(userposition: CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!))
        }
        
    }
    
    
    func drawPolygonMapBox(arrCoOrdinates : [[AnyObject]]){
        self.mapboxView.delegate = self
        var rect = [CLLocationCoordinate2D]()
        self.arrPolygonMapBox.removeAll()
        
        for index in 0..<arrCoOrdinates.count{
            
            print("INDEX COUNT _______________", index)
            let mainCords = arrCoOrdinates[index]
            // let subCords = mainCords[0] as! [AnyObject]
            
            for arrcords in mainCords {
                let objcord = arrcords as? [AnyObject] ?? []
                let lat = Double(objcord[1] as? CGFloat ?? 0.0)
                let long = Double(objcord[0] as? CGFloat ?? 0.0)
                let cordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
                rect.append(cordinate)
            }
            
            let polygonMapBox = MGLPolygon()
            
            polygonMapBox.setCoordinates(&rect, count: UInt(rect.count))
            self.mapboxView.addAnnotation(polygonMapBox)
            rect.removeAll()
            self.arrPolygonMapBox.append(polygonMapBox)
        }
    }
    
    func setCameraPositionOnMapBox(userposition : CLLocationCoordinate2D) {
        mapboxView.setCenter(userposition, zoomLevel: Double(changeInZoom), animated: true)
    }
    
    func setMarkerInMapBox(userposition: CLLocationCoordinate2D) {
        
        if (markerMapBox.tag != 1) {
            /// Initialize and add the point annotation.
            markerMapBox.coordinate = userposition
            markerMapBox.tag = 1
            mapboxView.addAnnotation(markerMapBox)
        } else {
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            markerMapBox.coordinate = userposition
            CATransaction.commit()
        }
    }
    
    func setPickUpMarkerInMapBox(userposition: CLLocationCoordinate2D) {
        
        if (markerMapBox.tag != 4) {
            /// Initialize and add the point annotation.
            markerMapBox.coordinate = userposition
            markerMapBox.tag = 4
            mapboxView.addAnnotation(markerMapBox)
            allAnnotations.append(markerMapBox)
        } else {
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            markerMapBox.coordinate = userposition
            CATransaction.commit()
        }
    }
    
    func drawPolyLineInMapBoxBetweenPickupAndDrop(lat:String,long:String,pickUpAddress:String,tripStatus:String)->Void {
        SVProgressHUD.show()
        
        debugPrint(appDelegate.lattitude,appDelegate.longitude)
        userposition = CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!)
        
        if !(Utility.isEqualtoString(tripStatus, "") || Utility.isEqualtoString(tripStatus, "end")){
            self.setPickUpMarkerInMapBox(userposition: userposition)
        }
        
        self.setMarkerInMapBox(userposition: userposition)
        
        if Utility.isEqualtoString(tripStatus, ApiKeyConstants.kAccepted){
            let position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
            let marker = CustomPointAnnotation()
            marker.coordinate = position
            //marker.title = pickUpAddress
            markerMapBox.tag = 2
            mapboxView.addAnnotation(marker)
            allAnnotations.append(marker)
        }
            
        else if(Utility.isEqualtoString(tripStatus, ApiKeyConstants.kArrived) || Utility.isEqualtoString(tripStatus, ApiKeyConstants.kIntransit)){
            
            let position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
            let marker = CustomPointAnnotation()
            marker.coordinate = position
            //marker.title = pickUpAddress
            markerMapBox.tag = 3
            mapboxView.addAnnotation(marker)
            allAnnotations.append(marker)
        }
        
        
        let wp1 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: Double(appDelegate.lattitude)!, longitude: Double(appDelegate.longitude)!), name: "")
        let wp2 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!), name: pickUpAddress)
        wp1.allowsArrivingOnOppositeSide = false
        wp2.allowsArrivingOnOppositeSide = false
        let options = NavigationRouteOptions(waypoints: [wp1, wp2], profileIdentifier: .automobileAvoidingTraffic)
        options.includesSteps = true
        options.includesVisualInstructions = true
        options.includesSpokenInstructions = true
        
        Directions(accessToken: appDelegate.MAPBOX_ACCESS_TOKEN).calculate(options) { (waypoints, routes, error) in
            guard error == nil else {
                print("Error calculating directions: \(error!)")
                return
            }
            
            
            self.directionsRoute = routes?.first
            
            if let route = routes?.first, let leg = route.legs.first {
                print("Route via \(leg):")
                self.tripDistance = route.distance
                let distanceFormatter = LengthFormatter()
                let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
                
                let travelTimeFormatter = DateComponentsFormatter()
                travelTimeFormatter.unitsStyle = .short
                let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
                
                print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
                SVProgressHUD.dismiss()
                
                for step in leg.steps {
                    print("\(step.instructions) [\(step.maneuverType) \(step.maneuverDirection)]")
                    if step.distance > 0 {
                        let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
                        print("— \(step.transportType) for \(formattedDistance) —")
                    }
                }
                
                if route.coordinateCount > 0 {
                    // Convert the route’s coordinates into a polyline.
                    self.mapboxView.remove(self.routeLine)
                    var routeCoordinates = route.coordinates!
                    self.currentRouteCoordinates = routeCoordinates
                    self.routeCordsCount = route.coordinateCount
                    self.routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
                    // Add the polyline to the map and fit the viewport to the polyline.
                    self.mapboxView.addAnnotation(self.routeLine)
                    
                    self.mapboxView.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: .init(top: 100, left: 20, bottom: 290, right: 20), animated: true)
                    /*if route.distance > 50{
                     
//                        self.changeInZoom = 12.9
                    }
                    else{
                        self.changeInZoom = 15.0
                        self.setCameraPositionOnMapBox(userposition: CLLocationCoordinate2D(latitude: Double(self.appDelegate.lattitude)!, longitude: Double(self.appDelegate.longitude)!))
                    }*/
                    
                    if tripStatus == "end" {
                        self.changeInZoom = 15.0
                        self.mapboxView.remove(self.routeLine)
                        self.setCameraPositionOnMapBox(userposition: CLLocationCoordinate2D(latitude: Double(self.appDelegate.lattitude)!, longitude: Double(self.appDelegate.longitude)!))
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 1.0
    }
    
    private func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLShape) -> CGFloat {
        return 3.0
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        if Utility.isEqualtoString(currentTripStatus, ApiKeyConstants.kAccepted){
            return Constants.AppColour.kAppBlackColor
        }
        else{
            return Constants.AppColour.kAppPolyLineGreenColor
        }
    }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor.init(red: 59.0/255.0, green: 133.0/255.0, blue: 47.0/255.0, alpha: 0.2)
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    // Allow callout view to appear when an annotation is tapped.
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        if ((annotation as! CustomPointAnnotation).tag == 1) {
            var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "carIcon")
            
            if annotationImage == nil {
                // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
                var image = UIImage(named: "carIcon")!
                
                image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
                
                // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "carIcon")
            }
            
            return annotationImage
        } else if ((annotation as! CustomPointAnnotation).tag == 2) {
            var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "userLocation")
            
            if annotationImage == nil {
                // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
                var image = UIImage(named: "userLocation")!
                
                image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
                
                // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "userLocation")
            }
            
            return annotationImage
        }
        else if ((annotation as! CustomPointAnnotation).tag == 4) {
            var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "initialMarker")
            
            if annotationImage == nil {
                // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
                //var image = UIImage(named: "initialMarker")! // change by piyali
                
                var image = UIImage(named: "carIcon")!
                
                image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
                
                // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "initialMarker")
            }
            
            return annotationImage
        }
        else {
            var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "dropLocation")
            
            if annotationImage == nil {
                // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
                var image = UIImage(named: "dropLocation")!
                
                image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
                
                // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "dropLocation")
            }
            
            return annotationImage
        }
        
    }
}


extension HomeViewController{
    
    // MARK:- Driver Online/Offline Status Update Methods-----
    func updateFirebaseDb(status:Int, authToken:String ){
        // Need To Uncomment when firebase from backend done
        debugPrint("updateFirebaseDb")
        if appDelegate.appDelHomeVcRef == nil{
            appDelegate.appDelHomeVcRef = Database.database().reference()
        }
        
        debugPrint("Lat=",appDelegate.lattitude)
        debugPrint("Lon=",appDelegate.longitude)
    self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(authToken).child(ApiKeyConstants.kisOnline).setValue(status)
//    self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(authToken).child(ApiKeyConstants.klattitude).setValue(self.appDelegate.lattitude)
//    self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(authToken).child(ApiKeyConstants.klongitude).setValue(self.appDelegate.longitude)
        
        let values = [ApiKeyConstants.klattitude:self.appDelegate.lattitude, ApiKeyConstants.klongitude:self.appDelegate.longitude]
    
     self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(authToken).updateChildValues(values)
    self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(authToken).child(ApiKeyConstants.ktimeStamp).setValue(Utility.currentTimeInMiliseconds())
    }
    
    // MARK:- Driver Continuous Location Update To Firebase Methods-----
    func updatedLocationInFireBase(userLocation : CLLocation){
        debugPrint("updatedLocationInFireBase")
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kDriverDetails) != nil{
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            debugPrint(self.appDelegate.appDelHomeVcRef)
            if appDelegate.appDelHomeVcRef == nil{
                appDelegate.appDelHomeVcRef = Database.database().reference()
            }
//            Jeet
            var long = Double((userLocation.coordinate.longitude))
            var lat = Double((userLocation.coordinate.latitude))
           
           long = Double(round(100000*long)/100000)
           lat = Double(round(100000*lat)/100000)
           appDelegate.lattitude = String(lat)
           appDelegate.longitude = String(long)
           appDelegate.lastLattitude = appDelegate.lattitude
           appDelegate.lastLongitude = appDelegate.longitude
//            Jeet
//            self.appDelegate.lattitude = String((userLocation.coordinate.latitude))
//            self.appDelegate.longitude = String((userLocation.coordinate.longitude))
            
            debugPrint("Lat=",appDelegate.lattitude)
            debugPrint("Lon=",appDelegate.longitude)
        
            self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.ktimeStamp).setValue(Utility.currentTimeInMiliseconds())
            //self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.klattitude).setValue(self.appDelegate.lattitude)
            //self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.klongitude).setValue(self.appDelegate.longitude)
            
           let values = [ApiKeyConstants.klattitude:self.appDelegate.lattitude, ApiKeyConstants.klongitude:self.appDelegate.longitude]
            self.appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").updateChildValues(values)
        }
    }
    
    // MARK:- Show Region View Method------
    func showRegionView(isHidden : Bool, regionName : String, regionDetails : String, isWithInRegion : Bool){
        if isHidden == false{
            regionView.isHidden = false
            if isWithInRegion{
                appDelegate.isWithInRegion = true
                regionNameLabel.text = "Welcome To \(regionName)"
                regionNameLabel.font = UIFont(name: "Roboto-Medium", size: 20.0)
                regionDescriptionLabel.text = regionDetails
                regionView.backgroundColor = Constants.AppColour.kAppGreenColor
            }
            else{
                appDelegate.isWithInRegion = false
                regionNameLabel.text = regionName
                regionNameLabel.font = UIFont(name: "Roboto-Medium", size: 15.0)
                regionDescriptionLabel.text = regionDetails
                regionView.backgroundColor = Constants.AppColour.kAppLightRedColor
            }
        }
        else{
            regionView.isHidden = true
        }
    }
    
    //MARK:- Remove Travelled Path-----
//    func updateTravelledPath(currentLoc: CLLocationCoordinate2D){
//        var index = 0
//        for i in 0..<self.path.count(){
//            let pathLat = Double(self.path.coordinate(at: i).latitude)
//            let pathLong = Double(self.path.coordinate(at: i).longitude)
//
//            let currentLat = Double(currentLoc.latitude)
//            let currentLong = Double(currentLoc.longitude)
//
//            if currentLat == pathLat && currentLong == pathLong{
//                index = Int(i)
//                break   //Breaking the loop when the index found
//            }
//        }
//
//        //Creating new path from the current location to the destination
//        let newPath = GMSMutablePath()
//        for i in index..<Int(self.path.count()){
//            newPath.add(self.path.coordinate(at: UInt(i)))
//        }
//        self.path = newPath
//        self.oldPolyLine.map = nil
//        self.oldPolyLine = GMSPolyline(path: self.path)
//        self.oldPolyLine.strokeColor = UIColor.darkGray
//        self.oldPolyLine.strokeWidth = 3.0
//        self.oldPolyLine.map = self.mapView
//    }
    
    
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



