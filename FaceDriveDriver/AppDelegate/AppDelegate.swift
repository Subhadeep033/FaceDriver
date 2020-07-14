//
//  AppDelegate.swift
//  FaceDriveDriver
//
//  Created by Prasanna Gupta on 22/01/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import UserNotifications
import GoogleMaps
import GooglePlaces
import AVFoundation
import Fabric
import Intercom
import Firebase
import FirebaseDatabase
import Reachability
import IQKeyboardManagerSwift
import FirebaseMessaging


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var player: AVAudioPlayer?  // To play sound
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var locationManager = CLLocationManager()
    var lattitude = "0.0"
    var longitude = "0.0"
    var pickUpAddress = ""
    var dropAddress = ""
    var tripEndAddress = ""
    var startTripTime = 0
    var endTripTime = 0
    var acceptTime = 0
    var arrivedTime = 0
    var resultTokenAvailable = 0
    var startTriplattitude = "0.0"
    var startTriplongitude = "0.0"
    var endTriplattitude = "0.0"
    var endTriplongitude = "0.0"
    var dropTriplattitude = "0.0"
    var dropTriplongitude = "0.0"
    var pickUpLattitude = "0.0"
    var pickUpLongitude = "0.0"
    var dialCountryCode = ""
    var routeLocationArr = [AnyObject]()
    var pickupRouteLocationArr = [AnyObject]()
    var countryCode = ""
    var currentEnvironment = ""
    let INTERCOM_APP_ID = "hzibb56s" //"sw6poyqb"
    let INTERCOM_API_KEY = "ios_sdk-9ae582321e8ea60b1706370d85b495d754cc047f" //"ios_sdk-005d7e64f4fccc9090248d33e4210e991e07fdb4"
    let MAPBOX_ACCESS_TOKEN = "pk.eyJ1IjoiZmFjZWRyaXZlIiwiYSI6ImNqd25sNG1tbDBsZHY0YnIycmxwcXo5bGQifQ.5LhiHSMn6AkjR2cpxbglvQ"
    // dev - "pk.eyJ1IjoiamF5ZGVlcDEyMzQiLCJhIjoiY2p2Y2MzbGEwMDByNjN5cDZqazFocWlrcyJ9.KOvkz13BoMM5nwn9j1OM-w"
    var bookingPopUpCount: Int = 0
    //var isSideMenuOpen : Bool = false
    //    var isNewRequestNotificationCalled : Int = 0
    var appDelRef : DatabaseReference!
    var appDelHomeVcRef : DatabaseReference!
    var startLocation : CLLocation!
    var lastLocation : CLLocation!
    var lastLattitude = "0.0"
    var lastLongitude = "0.0"
    let reachibility = try! Reachability()
    var dictRegionCoordinates = [[AnyObject]]()
    var isWithInZone = Bool()
    var isWithInTrip = Bool()
    var isWithInRegion = Bool()
    var isNewRequestNotificationFired = Bool()
    var isScheduleRequestNotificationFired = Bool()
    
    var selectedCarDict = [String : AnyObject]()
    var carCurrentRegionName = String()
    var arrServices     = [[String:AnyObject]]()
    
    var arrApiResponse = [[String:AnyObject]]()
    
    lazy var dialCode:String = {
        
        let currentLocale = NSLocale.current.regionCode
        var str_dialCode = ""
        debugPrint("Code ------------ \(currentLocale ?? "")")
        
        if currentLocale != nil {
            countryCode = "\(currentLocale ?? "CA")" //String(format: "%@", currentLocale!)
            
            if !(countryCode == "IN") {
                countryCode = "CA"
            }
            
            UserDefaults.standard.set(countryCode, forKey: "countryCode")
            UserDefaults.standard.synchronize()
            str_dialCode = Utility.getCountryCodes(countyRegion: countryCode)
            return str_dialCode
        }
        return str_dialCode
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
       /* let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        let fileopts = FirebaseOptions(contentsOfFile: filePath!)
        fileopts?.databaseURL = "https://facedrive-aws-demo.firebaseio.com/"    //AWS Server
       // fileopts?.databaseURL = "https://facedrive-prod.firebaseio.com/"
        FirebaseApp.configure(options: fileopts!)*/
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = false
        Fabric.sharedSDK().debug = true
        resultTokenAvailable = 0
        GMSServices.provideAPIKey(Constants.SocialLoginKeys.kGoogleMapsApiKey)
        GMSPlacesClient.provideAPIKey(Constants.SocialLoginKeys.kGoogleMapsApiKey)
        
        GIDSignIn.sharedInstance().clientID = Constants.SocialLoginKeys.kGoogleClientId
        GIDSignIn.sharedInstance().delegate = self as? GIDSignInDelegate
        
        // Keyboard manager
        IQKeyboardManager.shared.enable = true
        
        // Intercom
        Intercom.setApiKey(INTERCOM_API_KEY, forAppId: INTERCOM_APP_ID)
        Intercom.setLauncherVisible(false)
        
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kPickUpLocation) != nil)
        {
            pickupRouteLocationArr = UserDefaults.standard.array(forKey: ApiKeyConstants.kUserDefaults.kPickUpLocation)! as [AnyObject]
            debugPrint(pickupRouteLocationArr)
        }
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kTripLocation) != nil)
        {
            routeLocationArr = UserDefaults.standard.array(forKey: ApiKeyConstants.kUserDefaults.kTripLocation)! as [AnyObject]
            debugPrint(routeLocationArr)
        }
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kAcceptTime) != nil){
            acceptTime = UserDefaults.standard.integer(forKey: ApiKeyConstants.kUserDefaults.kAcceptTime)
        }
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kArrivedTime) != nil){
            arrivedTime = UserDefaults.standard.integer(forKey: ApiKeyConstants.kUserDefaults.kArrivedTime)
        }
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kStartTime) != nil){
            startTripTime = UserDefaults.standard.integer(forKey: ApiKeyConstants.kUserDefaults.kStartTime)
        }
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kEndTime) != nil){
            endTripTime = UserDefaults.standard.integer(forKey: ApiKeyConstants.kUserDefaults.kEndTime)
        }
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kRegionCord) != nil){
            // change _ piyali
            dictRegionCoordinates = UserDefaults.standard.array(forKey: ApiKeyConstants.kUserDefaults.kRegionCord)! as? [[AnyObject]] ?? [[]]
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kUserLastLattitude) != nil{
            lastLattitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kUserLastLattitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kUserLastLongitude) != nil{
            lastLongitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kUserLastLongitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kStartTripLattitude) != nil{
            startTriplattitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kStartTripLattitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kStartTripLongitude) != nil{
            startTriplongitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kStartTripLongitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kEndTripLattitude) != nil{
            endTriplattitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kEndTripLattitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kEndTripLongitude) != nil{
            endTriplongitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kEndTripLongitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kPickUpLattitude) != nil{
            pickUpLattitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kPickUpLattitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kPickUpLongitude) != nil{
            pickUpLongitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kPickUpLongitude) ?? "0.0"
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachibility)
        do{
            try reachibility.startNotifier()
        }catch{
            debugPrint("could not start reachability notifier")
        }
                
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, error) in
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
        }
        
        //get application instance ID
//        InstanceID.instanceID().instanceID { (result, error) in
//            if let error = error {
//                print("Error fetching remote instance ID: \(error)")
//            } else if let result = result {
//                print("Remote instance ID token: \(result.token)")
//                let dataDict:[String: String] = ["token": result.token]
//                NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
//                Utility.saveToUserDefaultsWithKeyandDictionary([ApiKeyConstants.kUserDefaults.DeviceToken : result.token], key: ApiKeyConstants.kUserDefaults.kDeviceToken)
//            }
//        }
        
        application.registerForRemoteNotifications()
        
//        var isReturn : Bool = false
        if Utility.retrieveStringFromUserDefaults(ApiKeyConstants.kUserDefaults.kWithInTrip) == "0"{
            _ = try? isUpdateAvailable { (update, version , error) in 
                if let error = error {
                    print(error)
//                    self.initializeAppDelegate()
//                    isReturn = true
                } else if let update = update {
                    print(update)
                    if update
                    {
                        guard let info = Bundle.main.infoDictionary,
                            let currentVersion = info["CFBundleShortVersionString"] as? String  else {
                                //                            throw VersionError.invalidBundleInfo
                                return
                        }
                        let updatedVersion = Int(version ?? "0")
                        let currentAppVersion = Int(currentVersion )
                        if currentAppVersion != 0 && updatedVersion != 0
                        {
                            if updatedVersion != currentAppVersion! + 1
                            {
                                print("Optional update")
                                let alertController = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle + "Update!", message: Constants.AppAlertMessage.kOptionalUpdateMessage, preferredStyle: UIAlertController.Style.alert)
                                let updateAction = UIAlertAction(title: "Update", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                                    print("Update")
                                    alertController.dismiss(animated: true, completion: nil)
//                                    isReturn = false
                                    let appStoreURL = URL(string: "itms-apps://itunes.apple.com/us/app/facedriver/id1155543740")
                                    UIApplication.shared.open(appStoreURL ?? URL(string:"https://www.apple.com/in/ios/app-store/")!, completionHandler: { (success) in
                                        print("Settings opened: \(success)") // Prints true
                                    })
                                }
                                let cancelAction = UIAlertAction(title: "Not now", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                                    print("Cancel")
                                    alertController.dismiss(animated: true, completion: nil)
//                                    self.initializeAppDelegate()
//                                    isReturn = true
                                }
                                alertController.view.tintColor = Constants.AppColour.kAppGreenColor
                                alertController.addAction(cancelAction)
                                alertController.addAction(updateAction)
                            UIApplication.shared.delegate?.window??.rootViewController!.present(alertController, animated: true, completion: nil)
                            }
                            else
                            {
                                print("Force update")
                                let alertController = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle + "Update!", message: Constants.AppAlertMessage.kForceUpdateMessage, preferredStyle: UIAlertController.Style.alert)
                                let updateAction = UIAlertAction(title: "Update", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                                    print("Cancel")
                                    alertController.dismiss(animated: true, completion: nil)
                                    let appStoreURL = URL(string: "itms-apps://itunes.apple.com/us/app/facedriver/id1155543740")
                                    UIApplication.shared.open(appStoreURL ?? URL(string:"https://www.apple.com/in/ios/app-store/")!, completionHandler: { (success) in
                                        print("Settings opened: \(success)") // Prints true
                                    })
                                }
                                alertController.view.tintColor = Constants.AppColour.kAppGreenColor
                                alertController.addAction(updateAction)
                                UIApplication.shared.delegate?.window??.rootViewController!.present(alertController, animated: true, completion: nil)
                            }
                        }
                        else{
//                            self.initializeAppDelegate()
//                            isReturn = true
                        }
                    }
                    else{
//                        self.initializeAppDelegate()
//                        isReturn = true
                    }
                }
            }
        }
        else{
//            initializeAppDelegate()
//            isReturn = true
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if pickupRouteLocationArr.count > 0 {
            UserDefaults.standard.set(pickupRouteLocationArr, forKey: ApiKeyConstants.kUserDefaults.kPickUpLocation)
        }
        if routeLocationArr.count > 0 {
            UserDefaults.standard.set(routeLocationArr, forKey: ApiKeyConstants.kUserDefaults.kTripLocation)
        }
        if dictRegionCoordinates.count > 0 {
            UserDefaults.standard.set(dictRegionCoordinates, forKey: ApiKeyConstants.kUserDefaults.kRegionCord)
        }
        if arrApiResponse.count > 0{
            UserDefaults.standard.set(arrApiResponse, forKey: ApiKeyConstants.kUserDefaults.kApiResponse)
        }
        if lastLocation != nil{
            lastLattitude = String(lastLocation.coordinate.latitude)
            lastLongitude = String(lastLocation.coordinate.longitude)
            UserDefaults.standard.set(lastLattitude, forKey: ApiKeyConstants.kUserDefaults.kUserLastLattitude)
            UserDefaults.standard.set(lastLongitude, forKey: ApiKeyConstants.kUserDefaults.kUserLastLongitude)
        }
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kApiResponse) != nil)
        {
            arrApiResponse = UserDefaults.standard.array(forKey: ApiKeyConstants.kUserDefaults.kApiResponse)! as! [[String : AnyObject]]
        }
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kPickUpLocation) != nil)
        {
            pickupRouteLocationArr = UserDefaults.standard.array(forKey: ApiKeyConstants.kUserDefaults.kPickUpLocation)! as [AnyObject]
        }
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kTripLocation) != nil)
        {
            routeLocationArr = UserDefaults.standard.array(forKey: ApiKeyConstants.kUserDefaults.kTripLocation)! as [AnyObject]
        }
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kStartTime) != nil){
            startTripTime = UserDefaults.standard.integer(forKey: ApiKeyConstants.kUserDefaults.kStartTime)
        }
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kEndTime) != nil){
            endTripTime = UserDefaults.standard.integer(forKey: ApiKeyConstants.kUserDefaults.kEndTime)
        }
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kAcceptTime) != nil){
            acceptTime = UserDefaults.standard.integer(forKey: ApiKeyConstants.kUserDefaults.kAcceptTime)
        }
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kArrivedTime) != nil){
            arrivedTime = UserDefaults.standard.integer(forKey: ApiKeyConstants.kUserDefaults.kArrivedTime)
        }
        if (UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kRegionCord) != nil){
            dictRegionCoordinates = UserDefaults.standard.array(forKey: ApiKeyConstants.kUserDefaults.kRegionCord)! as? [[AnyObject]] ?? [[]]
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kUserLastLattitude) != nil{
            lastLattitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kUserLastLattitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kUserLastLongitude) != nil{
            lastLongitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kUserLastLongitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kStartTripLattitude) != nil{
            startTriplattitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kStartTripLattitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kStartTripLongitude) != nil{
            startTriplongitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kStartTripLongitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kEndTripLattitude) != nil{
            endTriplattitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kEndTripLattitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kEndTripLongitude) != nil{
            endTriplongitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kEndTripLongitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kPickUpLattitude) != nil{
            pickUpLattitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kPickUpLattitude) ?? "0.0"
        }
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kPickUpLongitude) != nil{
            pickUpLongitude = UserDefaults.standard.string(forKey: ApiKeyConstants.kUserDefaults.kPickUpLongitude) ?? "0.0"
        }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        /*return GIDSignIn.sharedInstance()?.handle(url as URL?,sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
        annotation: options[UIApplication.OpenURLOptionsKey.annotation]) || ApplicationDelegate.shared.application(app, open: url, options: options)*/
        
        return GIDSignIn.sharedInstance()!.handle(url as URL?)
    }
    
    // MARK:- For ios 8 and earlier ---
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var _: [String: AnyObject] = [UIApplication.OpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,UIApplication.OpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
    
       /* return GIDSignIn.sharedInstance().handle(url,sourceApplication: sourceApplication,
        annotation: annotation) || ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)*/
        
        return GIDSignIn.sharedInstance()!.handle(url as URL?)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .sound])
        debugPrint("Push notification received: \(notification.request.content.userInfo)")
        debugPrint(notification.request.content.userInfo[ApiKeyConstants.kTitle] as? String ?? "")
        if (Utility.isEqualtoString(notification.request.content.userInfo[ApiKeyConstants.kTitle] as? String ?? "", "Trip Cancelled")){
            self.stopSound()
        }
        
//        self.handleLocalNotification(notificationID: notification.request.identifier)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                
                print("Remote instance ID token: \(result.token)")
                
                if self.resultTokenAvailable == 0{
                    self.resultTokenAvailable = 1
                    let dataDict:[String: String] = ["token": result.token]
                    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
                    Utility.saveToUserDefaultsWithKeyandDictionary([ApiKeyConstants.kUserDefaults.DeviceToken : result.token], key: ApiKeyConstants.kUserDefaults.kDeviceToken)
                    if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
                        //            DispatchQueue.global(qos: .background).async {
                        self.updateFCMToken(fcmToken: result.token)
                        //            }
                    }
                }
            }
        }
//        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
//        debugPrint("Token =",token)
//
//
//        let dataDict:[String: String] = ["token": token]
//        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
//        Utility.saveToUserDefaultsWithKeyandDictionary([ApiKeyConstants.kUserDefaults.DeviceToken : token], key: ApiKeyConstants.kUserDefaults.kDeviceToken)
//        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
////            DispatchQueue.global(qos: .background).async {
//                self.updateFCMToken(fcmToken: token)
////            }
//        }
    }
    
    // Push notification received
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void){
        debugPrint("Received: \(response)")
//        self.handleLocalNotification(notificationID: response.notification.request.identifier)
        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        NSLog("[RemoteNotification] didRefreshRegistrationToken: \(fcmToken)")
        let dataDict:[String: String] = [ApiKeyConstants.kToken: fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        Utility.saveToUserDefaultsWithKeyandDictionary([ApiKeyConstants.kUserDefaults.DeviceToken : fcmToken], key: ApiKeyConstants.kUserDefaults.kDeviceToken)
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
//            DispatchQueue.global(qos: .background).async {
                self.updateFCMToken(fcmToken: fcmToken)
//            }
        }
    }
    
    // iOS9, called when presenting notification in foreground
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NSLog("[RemoteNotification didReceiveRemoteNotification for iOS9: \(userInfo)")
        if UIApplication.shared.applicationState == .active {
            //TODO: Handle foreground notification
        } else {
            //TODO: Handle background notification
        }
    }
    
    // MARK:- Sound Effects
    func playSound(){
        guard let url = Bundle.main.url(forResource: "new_request", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player?.numberOfLoops = -1
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func stopSound(){
        player?.stop()
    }
    
    //    MARK: Create Notification ----
//    func createLocalNotifications(title:String, subTitle:String, message:String, notificationIdentifier:String){
//        if Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) != nil{
//            let content = UNMutableNotificationContent()
//            
//            //adding title, subtitle, body and badge
//            content.title = title
//            content.subtitle = subTitle
//            content.body = message
//            content.sound = UNNotificationSound.default
//            //        content.badge = 1
//            
//            //getting the notification trigger
//            //it will be called after 5 seconds
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//            
//            //getting the notification request
//            let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
//            UNUserNotificationCenter.current().delegate = self
//            //adding the notification to notification center
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//        }
//    }
    
//    func handleLocalNotification(notificationID : String){
//        let currentVC : UIViewController = self.window!.rootViewController!
//        debugPrint(currentVC)
//        if Utility.isEqualtoString(notificationID, Constants.NotificationConstant.kEndTripNotificationID){
//            if currentVC.isKind(of: EndTripDetailsViewController.self){
//                debugPrint("Do Nothing")
//            }
//            else{
//                debugPrint("Do Nothing")
//            }
//        }
//        else if Utility.isEqualtoString(notificationID, Constants.NotificationConstant.kSignUpNotificationID){
//            if currentVC.isKind(of: SignUpViewController.self){
//                debugPrint("Do Nothing")
//            }
//            else{
//                debugPrint("Do Nothing")
//            }
//        }
//        else if Utility.isEqualtoString(notificationID, Constants.NotificationConstant.kNewRequestNotificationID) || Utility.isEqualtoString(notificationID, Constants.NotificationConstant.kScheduleRequestNotificationID) || Utility.isEqualtoString(notificationID, Constants.NotificationConstant.kCancelTripNotificationID){
//            if currentVC.isKind(of: HomeViewController.self){
//                debugPrint("Do Nothing")
//            }
//            else{
//                debugPrint("Do Nothing")
//            }
//        }
//        else{
//            debugPrint("Do Nothing")
//        }
//    }
    
    func isUpdateAvailable(completion: @escaping (Bool?, String? , Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw Constants.VersionError.invalidBundleInfo
        }
        //        log.debug(currentVersion)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw Constants.VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw Constants.VersionError.invalidResponse
                }
                
                completion(version != currentVersion, version , nil)
            } catch {
                completion(nil, "" , error)
            }
        }
        task.resume()
        return task
    }
    
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
    
    func updateFCMToken(fcmToken : String){
        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        let bodyParams : [String : String] = [ApiKeyConstants.kDeviceToken : fcmToken,ApiKeyConstants.kDeviceType : "iOS"]
        Utility.removeAppCookie()
        let fcmTokenUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kUpdateFcmTokenApi
        
        APIWrapper.requestPOSTURL(fcmTokenUrl, params: bodyParams, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        debugPrint(dictResponse!)
                    } else {
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
                    }
                }
                else{
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
                }
            }
            else{
                Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
            }
        })
        { (error) -> Void in
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
        }
    }
}


