//
//  Utility.swift
//  WildArk
//
//  Created by Subhadeep Chakraborty on 10/16/17.
//  Copyright © 2017 Digital Aptech. All rights reserved.
//

import UIKit
import CoreLocation
import Intercom
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
import Kingfisher



class Utility: NSObject {
   
    
//    //MARK: Rotating UIView
//    class func rotateView(targetView: UIView, duration: Double = 0.9) {
////        Stop rotation by dclaring the Stoprotation to true
//         let appdelegate = UIApplication.shared.delegate as! AppDelegate
//        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
//            targetView.transform = targetView.transform.rotated(by: CGFloat(Double.pi))
//        }) { finished in
//            (appdelegate.StopRotation) ? (debugPrint("Animation Stopped")):(self.rotateView(targetView: targetView, duration: duration))
//
//        }
//    }
//    //    MARK: Casting of Function CGRect(x:,y:,width:,height:)
  class  func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
//    class func SetUpHeaderView(targetView:UIView , targetedVC:UIViewController) ->HeaderView
//    {
//        let Objheaderview = HeaderView.instanceFromNib()
//        Objheaderview.frame=Utility.CGRectMake(0, 0, Constant.Values.Frames.FULLWIDTH, Constant.Values.Frames.MENUHEADERHEIGHT)
//        Objheaderview.delegate=targetedVC as? HeaderMenuDelegate
//        targetView.addSubview(Objheaderview)
//        return Objheaderview
//    }
    
    // MARK: Get OS Version ----
    class func getDeviceOSVersion() -> String{
        return ProcessInfo().operatingSystemVersionString
    }
    
    //    MARK: ShowAlert ----
    class func ShowAlert(title:String,message:String,Button_Title:String,_ controller:UIViewController)
    {
        let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: UIAlertController.Style.alert)
        alertController.view.tintColor = Constants.AppColour.kAppGreenColor
        let cancelAction = UIAlertAction(title: Button_Title as String, style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            debugPrint("Cancel")
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    class func showAlertForSessionExpired(title:String,message:String,Button_Title:String,_ controller:UIViewController)
    {
        let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: UIAlertController.Style.alert)
        alertController.view.tintColor = Constants.AppColour.kAppGreenColor
        let cancelAction = UIAlertAction(title: Button_Title as String, style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let storyBoard = UIStoryboard.init(name: "Home", bundle: nil)
            let homeVc = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kHomeStoryboardId) as! HomeViewController
            homeVc.locationManager.stopUpdatingLocation()
            self.removeAllObserversWhenLogout()
            
            let menuVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSideMenuStoryboardId) as! SideMenuViewController
            if menuVC.sideMenuRef != nil {
                menuVC.sideMenuRef.removeAllObservers()
            }
            self.removeAppCookie()
            self.removeFromUserDefaultsWithKeyandDictionary(ApiKeyConstants.kUserDefaults.kDriverDetails)
            let initialController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kInitialViewStoryBoardId) as! InitialViewController
            let navigationController = UINavigationController(rootViewController: initialController)
            navigationController.isNavigationBarHidden = true
            appDelegate.window?.rootViewController = navigationController
        }
        alertController.addAction(cancelAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    // MARK:- Remove All Observers ------
    class func removeAllObserversWhenLogout(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        if appDelegate.appDelRef != nil{
            appDelegate.appDelRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kToken).removeAllObservers()
        }
        if appDelegate.appDelHomeVcRef != nil{
            appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kZoneId).removeAllObservers()
            appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").removeAllObservers()
            appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kisOnline).removeAllObservers()
            appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kNewRequestId).removeAllObservers()
            appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kTripId).removeAllObservers()
            appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kStatus).removeAllObservers()
            appDelegate.appDelHomeVcRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kServiceArea).removeAllObservers()
        }
    }
    
    class func showAlertForPermissionDenied(title:String,message:String,_ controller:UIViewController){
        let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: UIAlertController.Style.alert)
        alertController.view.tintColor = Constants.AppColour.kAppGreenColor
        let goToSettings = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (result : UIAlertAction) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(goToSettings)
        alertController.addAction(cancel)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    // MARK:- Intercom registration
    class func RegisterInIntercom() {
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        
        let userid = driverDetailsDict[ApiKeyConstants.kid] as? String
        Intercom.registerUser(withUserId: userid ?? "")
        
        let userAttributes = ICMUserAttributes()
        userAttributes.name = Utility.trimmingString(driverDetailsDict[ApiKeyConstants.kFirst_Name] as? String ?? "")
        userAttributes.email = Utility.trimmingString(driverDetailsDict[ApiKeyConstants.kEmail] as? String ?? "")
        userAttributes.customAttributes = ["User type" : "Driver"]
        Intercom.updateUser(userAttributes)
        Utility.saveStringInUserDefaults("1", key: ApiKeyConstants.kUserDefaults.kIntercomLogin)
        
    }
    
    class func updateInterComUser(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let userAttributes = ICMUserAttributes()
        userAttributes.name = Utility.trimmingString(driverDetailsDict[ApiKeyConstants.kFirst_Name] as? String ?? "")
        userAttributes.email = Utility.trimmingString(driverDetailsDict[ApiKeyConstants.kEmail] as? String ?? "")
        userAttributes.customAttributes = ["User type" : "Driver"]
        Intercom.updateUser(userAttributes)
    }
    
    //    MARK: Save to user defaults ----
    
    class func saveStringInUserDefaults (_ value:String , key:String)
    {
        UserDefaults.standard.set(value, forKey: key)
    }
    class func retrieveStringFromUserDefaults (_ key:String) -> String
    {
        let retrievedString = UserDefaults.standard.string(forKey: key)
        return retrievedString ?? ""
        
    }
    
    class func saveIntegerInUserDefaults (_ value:Int , key:String)
    {
        UserDefaults.standard.set(value, forKey: key)
    }
    class func retrieveIntegerFromUserDefaults (_ key:String) -> Int
    {
        let retrievedInt = UserDefaults.standard.integer(forKey: key)
        return retrievedInt
        
    }
    
    class func convertTimeStampToDateTime(timeStamp:Double)-> String{
        let timestamp = timeStamp / 1000
        let date = NSDate(timeIntervalSince1970: timestamp)

        let dayTimePeriodFormatter = DateFormatter()
        
        dayTimePeriodFormatter.dateFormat = "dd, MMM yyyy HH:mm a"
        let timeZone = NSTimeZone.local
        let timeZoneName = timeZone.identifier
        debugPrint("TimeZone",timeZoneName)
        dayTimePeriodFormatter.timeZone = (NSTimeZone(name: timeZoneName)! as TimeZone)

        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
    }
    
    class func convertTimeStampToDate(timeStamp:Double)-> String{
        let timestamp = timeStamp / 1000
        let date = NSDate(timeIntervalSince1970: timestamp)
        
        let dayTimePeriodFormatter = DateFormatter()
        
        dayTimePeriodFormatter.dateFormat = "dd/MM/yyyy"
        let timeZone = NSTimeZone.local
        let timeZoneName = timeZone.identifier
        debugPrint("TimeZone",timeZoneName)
        dayTimePeriodFormatter.timeZone = (NSTimeZone(name: timeZoneName)! as TimeZone)
        
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
    }
    //    MARK: Email Validation ----
   class func isValidEmail(testStr:String) -> Bool {
        // debugPrint("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    class func isValidPhoneNumber (testStr:String) -> Bool{
        let phoneRegEx = "^[0-9]{8,14}$"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        print(phoneTest.evaluate(with: testStr))
        return phoneTest.evaluate(with: testStr)
    }
    
    class func isValidCharacterSet (str:String) -> Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ")
        if str.rangeOfCharacter(from: characterset.inverted) != nil {
            return true
        }
        else{
            return false
        }
    }
    
   class func addParallaxToView(vw: UIView) {
        let amount = 100
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        vw.addMotionEffect(group)
    }
    
    //    MARK: String Comparision ----
    class func isEqualtoString (_ firstString: String , _ secondString: String) -> Bool {
        let x = firstString
        let y = secondString
        return (x == y)
    }
    
    //    MARK: Url Validation ----
    class func isValidUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    //    MARK: Image Resize ----
   class func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func recursiveNullRemoveFromDictionary(responseDict:[String:Any]) -> Dictionary<String,Any>{
        var dictionary = responseDict
        let nullString : String = ""
        for key in dictionary.keys{
            let value = dictionary[key]
            
            if let values = value as? Dictionary<String, Any>{
                dictionary[key] = self.recursiveNullRemoveFromDictionary(responseDict: values)
            }
            else if let dataArray = value as? Array<Any>{
                var newArray = dataArray
                for i in 0..<dataArray.count{
                    let value2 = dataArray[i]
                    
                    if let values2 = value2 as? Dictionary<String,Any>{
                        newArray[i] = self.recursiveNullRemoveFromDictionary(responseDict: values2)
                    }
                    else if value2 is NSNull{
                        newArray[i] = nullString
                    }
                }
                dictionary[key] = newArray
            }
            else if value is NSNull{
                dictionary[key] = nullString
            }
        }
        return dictionary
    }
    //    MARK: Save to user defaults ----
    class func saveToUserDefaultsWithKeyandDictionary(_ value:[String:Any] ,key:String) -> Void {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
//    class func saveToUserDefaults(_ value:[[String:Any]] ,key:String) -> Void {
//        UserDefaults.standard.set(value, forKey: key)
//        UserDefaults.standard.synchronize()
//    }
    //    MARK: Remove from user defaults ----
    class func removeFromUserDefaultsWithKeyandDictionary(_ key:String) -> Void {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    //    MARK: Retrieve from user defaults ----
    class func retrieveDictionarybyKey (_ key: String) -> [String:Any]? {
        let dic_Value = UserDefaults.standard.dictionary(forKey: key)
        return dic_Value
    }
    
    //    MARK: Empty String Checking ----
    class func IsEmtyString(_ text:String?) -> Bool {
        if text != nil && text != "null" {
          return (text!.trimmingCharacters(in: .whitespaces).isEmpty)
            
        }
        else
        {
            return false
        }
    }
    
    class func trimmingString(_ targetedStr:String) -> String {
        let myString = targetedStr
        let trimmedString = myString.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedString
    }
    
    class func openViewControllerBasedOnIdentifier(_ strIdentifier:String , _ targetVC: UIViewController){
        let destViewController : UIViewController? = targetVC.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
        targetVC.navigationController!.pushViewController(destViewController!, animated: true)
        
    }
    class func changeTimeToMilliSeconds(date:Date) -> Int{
        let since1970 = date.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    class func currentTimeInMiliseconds() -> Int {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
 
    class func distanceOfTrip(locationPoints : [AnyObject]) -> Double{
        var distance = 0.0
        if locationPoints.count > 1{
            
            for i in 0...locationPoints.count-2{
                let myEarlierLocation = CLLocation(latitude: locationPoints[i][ApiKeyConstants.kLat] as? Double ?? 0.0 , longitude: locationPoints[i][ApiKeyConstants.klongitude] as? Double ?? 0.0)
                let myNewLocation = CLLocation(latitude: locationPoints[i+1][ApiKeyConstants.kLat] as? Double ?? 0.0 , longitude: locationPoints[i+1][ApiKeyConstants.klongitude] as? Double ?? 0.0)
                let tempDistance = myEarlierLocation.distance(from: myNewLocation)
                distance += tempDistance
            }
            return distance
        }
        else{
            return distance
        }
    }
    
    
    
    //    MARK: Encoded String Cords Method ----
    class func getEncodedStringWithCoordinates(locationPoint : [AnyObject], completion: @escaping (String) -> ()){
        method(locationPoints: locationPoint, completion: { (success) in
            print("Second line of code executed")
            completion(success)
        })
    }
        
        
    class func method(locationPoints: [AnyObject], completion: @escaping (String) -> ()) {
            var encodedString = ""
            var locationsString = ""
            debugPrint("Location Point=",locationPoints.count)
            debugPrint("Location Array=",locationPoints)
            if locationPoints.count > 2{
                let originCord = CLLocation(latitude: (locationPoints[0][ApiKeyConstants.kLat] as? Double ?? 0.0) , longitude: (locationPoints[0][ApiKeyConstants.klongitude] as? Double ?? 0.0))
                let origin = "\(originCord.coordinate.latitude),\(originCord.coordinate.longitude)"
                
                let destCord = CLLocation(latitude: (locationPoints[locationPoints.count-1][ApiKeyConstants.kLat] as? Double ?? 0.0) , longitude: (locationPoints[locationPoints.count-1][ApiKeyConstants.klongitude] as? Double ?? 0.0))
                let destination = "\(destCord.coordinate.latitude),\(destCord.coordinate.longitude)"
                
                for i in 1...locationPoints.count-2{
                    let stopCord = "\(locationPoints[i][ApiKeyConstants.kLat] as? Double ?? 0.0),\(locationPoints[i][ApiKeyConstants.klongitude] as? Double ?? 0.0)"
                    if Utility.isEqualtoString(locationsString, "") {
                        locationsString += "\(stopCord)"
                    }
                    else{
                        locationsString += "|\(stopCord)"
                    }
                }
                debugPrint("Origin =",origin)
                debugPrint("Destination =",destination)
                debugPrint("Location Str =",locationsString)
                var url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&sensor=false&waypoints=\(locationsString)|&units=metric&key=\(Constants.SocialLoginKeys.kGoogleMapsApiKey)"
                url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                debugPrint(url)
                
                Alamofire.request(url).responseJSON { response in
                    
                    guard let jsonResponce = try? JSON(data: response.data!) else {
                        //                failure("error")
                        return
                        
                    }
                    debugPrint(jsonResponce)
                    let routes = jsonResponce["routes"].arrayValue
                    if routes.count > 0
                    {
                        let dicInfo = routes[0].dictionary
                        
                        let dicPolyLine = dicInfo?["overview_polyline"]?.dictionary
                        let encodedPolyLine = dicPolyLine?["points"]?.stringValue
                        
                        debugPrint("Encoded Polyline :---- \(encodedPolyLine ?? "")")
                        encodedString = encodedPolyLine ?? ""
                        completion(encodedString)
                    }
                    else{
                        encodedString = ""
                        completion(encodedString)
                    }
                    
                }
            }
            else{
                let originCord = CLLocation(latitude: (locationPoints[0][ApiKeyConstants.kLat] as? Double ?? 0.0) , longitude: (locationPoints[0][ApiKeyConstants.klongitude] as? Double ?? 0.0))
                let origin = "\(originCord.coordinate.latitude),\(originCord.coordinate.longitude)"
                
                let destCord = CLLocation(latitude: (locationPoints[locationPoints.count-1][ApiKeyConstants.kLat] as? Double ?? 0.0) , longitude: (locationPoints[locationPoints.count-1][ApiKeyConstants.klongitude] as? Double ?? 0.0))
                let destination = "\(destCord.coordinate.latitude),\(destCord.coordinate.longitude)"
                
                debugPrint("Origin =",origin)
                debugPrint("Destination =",destination)
                debugPrint("Location Str =",locationsString)
                var url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&sensor=false&units=metric&key=\(Constants.SocialLoginKeys.kGoogleMapsApiKey)"
                url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                debugPrint(url)
                
                Alamofire.request(url).responseJSON { response in
                    
                    guard let jsonResponce = try? JSON(data: response.data!) else {
                        //                failure("error")
                        return
                        
                    }
                    debugPrint(jsonResponce)
                    let routes = jsonResponce["routes"].arrayValue
                    if routes.count > 0
                    {
                        let dicInfo = routes[0].dictionary
                        
                        let dicPolyLine = dicInfo?["overview_polyline"]?.dictionary
                        let encodedPolyLine = dicPolyLine?["points"]?.stringValue
                        
                        debugPrint("Encoded Polyline :---- \(encodedPolyLine ?? "")")
                        encodedString = encodedPolyLine ?? ""
                        completion(encodedString)
                    }
                    else{
                        encodedString = ""
                        completion(encodedString)
                    }
                }
        }
//        var val = 0
//        var value = 0
//        var previousCord = CLLocationCoordinate2DMake(0, 0)
//
//        if locationPoints.count > 0{
//
//            for i in 0...locationPoints.count-1{
//                val = Int(round((locationPoints[i][ApiKeyConstants.kLat] as? Double ?? 0.0 - previousCord.latitude) * 1e5))
//                val = (val < 0) ? ~(val << 1) : (val << 1)
//
//                while (val >= 0x20) {
//                    value = (0x20|(val & 31)) + 63;
//                    encodedString += String(format: "%c", value)
//                    val >>= 5;
//                }
//                encodedString += String(format: "%c", val + 63)
//
//                val = Int(round((locationPoints[i][ApiKeyConstants.klongitude] as? Double ?? 0.0 - previousCord.longitude) * 1e5))
//                val = (val < 0) ? ~(val << 1) : (val << 1)
//
//                while (val >= 0x20) {
//                    value = (0x20|(val & 31)) + 63;
//                    encodedString += String(format: "%c", value)
//                    val >>= 5;
//                }
//                encodedString += String(format: "%c", val + 63)
//                let myEarlierLocation = CLLocation(latitude: locationPoints[i][ApiKeyConstants.kLat] as? Double ?? 0.0 , longitude: locationPoints[i][ApiKeyConstants.klongitude] as? Double ?? 0.0)
//                previousCord = myEarlierLocation.coordinate
//            }
//            return encodedString
//        }
//        else{
//            return encodedString
//        }
    }
    
    // Create Json File ----
    class func createAPIResponseFile(dict : [String:AnyObject]) {
        // Get the url of Persons.json in document directory
//        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//        let fileUrl = documentDirectoryUrl.appendingPathComponent("ApiResponse.json")
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.arrApiResponse.append(dict)
        debugPrint("Api Response =",appdelegate.arrApiResponse)
        UserDefaults.standard.set(appdelegate.arrApiResponse, forKey: ApiKeyConstants.kUserDefaults.kApiResponse)
        // Transform array into data and save it into file
//        do {
//            let data = try JSONSerialization.data(withJSONObject: appdelegate.arrApiResponse, options: [])
//            try data.write(to: fileUrl, options: [])
//        } catch {
//            print(error)
//        }
    }
    
    class func resizeImage(image: UIImage, width : Float) -> Data {
        var actualHeight: Float = Float(image.size.height)
        var actualWidth: Float = Float(image.size.width)
        var imgRatio: Float = actualWidth / actualHeight
        let maxHeight: Float = width * imgRatio
        let maxWidth: Float = width
        let maxRatio: Float = maxWidth / maxHeight
        //let compressionQuality: Float = 0.5
        //50 percent compression
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRectMake(0.0, 0.0, CGFloat(actualWidth), CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img!.jpegData(compressionQuality: 0.5)
        UIGraphicsEndImageContext()
        return imageData!
    }
    
    class func goBackToSignInVC(_ targetVC : UIViewController) {
        for controller in targetVC.navigationController!.viewControllers as Array {
            if controller.isKind(of: SignInViewController.self) {
                targetVC.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    class func removeAppCookie(){
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
    }
    
//    class func isValidPhoneNumber(targetString : String) -> Bool{
//        let phoneRegEx = "[0-9]"
//        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
//        return phoneTest.evaluate(with: targetString)
//    }
    
    class func getCountryCodes(countyRegion:String) -> String{
        var dialCode = String()
        if let path = Bundle.main.path(forResource: "countryCodes", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                let json = try JSONSerialization.jsonObject(with: jsonData) as? [[String:String]] ?? [[:]]
                debugPrint(json)
                let countryArr = json
                let searchPredicate = NSPredicate(format: "SELF.code CONTAINS[c] %@", countyRegion)
                let arr = (countryArr as NSArray).filtered(using: searchPredicate)
                if arr.count > 0 {
                    let dict : [String:String] = arr[0] as? [String : String] ?? [:]
                    dialCode = dict["dial_code"] ?? "1"
                    return dialCode
                }
            } catch {
                // handle error
                let nsError = error as NSError
                debugPrint("Error = ",nsError.localizedDescription)
            }
        }
        return dialCode
    }
    
    class func isPlusDevice() -> Bool{
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
                return false
            case 1334:
                print("iPhone 6/6S/7/8")
                return false
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                return true
            case 2436:
                print("iPhone X, XS")
                return false
            case 2688:
                print("iPhone XS Max")
                return true
            case 1792:
                print("iPhone XR")
                return false
            default:
                print("Unknown")
                return false
            }
        }
        else{
            return false
        }
    }
    
    class func setUpRegionView(targetView:UIView, targetedVC:UIViewController) -> RegionToastView{
        let objRegionView = RegionToastView.instanceFromNib()
        objRegionView.frame = Utility.CGRectMake(20, 80, Constants.DeviceSize.FULLWIDTH - 40, Constants.StaticSizes.REGIONVIEWHEIGHT)
        targetView.addSubview(objRegionView)
        return objRegionView
    }
    
    class func isDriverInRegion(targetView:UIView, targetedVC:UIViewController, titleMessage: String, bodyMessage: String, withInRegion: Bool, isPopUpShown: Bool){
        var regionView = RegionToastView()
        if isPopUpShown{
            if let viewWithTag = targetView.viewWithTag(1050){
                debugPrint(viewWithTag)
//                viewWithTag.removeFromSuperview()
//                regionView = Utility.setUpRegionView(targetView: targetView, targetedVC: targetedVC)
//                regionView.tag = 1050
                regionView = viewWithTag as! RegionToastView
                regionView.regionHeaderLabel.text = titleMessage
                regionView.regionDetailsLabel.text = bodyMessage
                if withInRegion{
                    regionView.backgroundColor = Constants.AppColour.kAppGreenColor
                }
                else{
                    regionView.backgroundColor = Constants.AppColour.kAppRedColor
                }
            }
            else{
                regionView = Utility.setUpRegionView(targetView: targetView, targetedVC: targetedVC)
                regionView.tag = 1050
                regionView.regionHeaderLabel.text = titleMessage
                regionView.regionDetailsLabel.text = bodyMessage
                
            }
            if withInRegion{
                regionView.backgroundColor = Constants.AppColour.kAppGreenColor
            }
            else{
                regionView.backgroundColor = Constants.AppColour.kAppRedColor
            }
        }
        else{
            if let viewWithTag = targetView.viewWithTag(1050){
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
    class func SetUpToastView(targetView:UIView , targetedVC:UIViewController , message:String , actionEnabled:Bool, buttonText:String) ->CustomToastView
    {
        let ObjCustomView = CustomToastView.instanceFromNib()
        ObjCustomView.frame = Utility.CGRectMake(0,Constants.DeviceSize.FULLHEIGHT , Constants.DeviceSize.FULLWIDTH , Constants.StaticSizes.TOASTVIEW)
        UIView.animate(withDuration: 0.33, animations: {
            ObjCustomView.frame = Utility.CGRectMake(0,Constants.DeviceSize.FULLHEIGHT - Constants.StaticSizes.TOASTVIEW , Constants.DeviceSize.FULLWIDTH , Constants.StaticSizes.TOASTVIEW)
        })
        ObjCustomView.lbl_toastMessage.text = message
        ObjCustomView.btn_toastMessage.setTitle(buttonText, for: .normal)
        if actionEnabled {
            ObjCustomView.btn_toastMessage.isUserInteractionEnabled = true
            ObjCustomView.btn_toastMessage.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
            targetView.addSubview(ObjCustomView)
        }
        else
        {
            ObjCustomView.btn_toastMessage.isUserInteractionEnabled = false
            ObjCustomView.removeFromSuperview()
        }
        //        ObjCustomView.delegate=targetedVC as? CustomToastView
        
        return ObjCustomView
    }
    
    class func isNetworkEnabled(targetView:UIView , targetedVC:UIViewController , message:String , networkEnabled:Bool , btnMessage: String){
        var toastView = CustomToastView()
        
        if networkEnabled {
            if let viewWithTag = targetView.viewWithTag(1030){
                viewWithTag.removeFromSuperview()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    toastView = Utility.SetUpToastView(targetView: targetView, targetedVC: targetedVC, message: message, actionEnabled: true, buttonText: btnMessage)
                    toastView.tag = 1030
                    toastView.lbl_toastMessage.text = message
                    toastView.backgroundColor = Constants.AppColour.kAppGreenColor
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        if let tagView = targetView.viewWithTag(1030){
                            tagView.removeFromSuperview()
                        }
                    })
                }
            }
        }
        else
        {
            toastView = Utility.SetUpToastView(targetView: targetView, targetedVC: targetedVC, message: message, actionEnabled: true, buttonText: btnMessage)
            toastView.tag = 1030
            toastView.lbl_toastMessage.text = message
            toastView.backgroundColor = Constants.AppColour.kAppRedColor
        }
    }
    
    class func isLocationEnabled (targetView:UIView , targetedVC:UIViewController , message:String , actionEnabled:Bool , btnMessage: String)
    {
        var view_toast = CustomToastView()
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                if let viewWithTag = targetView.viewWithTag(1029) {
                    //                    print("Tag 100")
                    viewWithTag.removeFromSuperview()
                } else {
                    //                    print("tag not found")
                }
                view_toast = Utility.SetUpToastView(targetView: targetView, targetedVC: targetedVC, message: message, actionEnabled: actionEnabled, buttonText: btnMessage)
                view_toast.tag = 1029
                if actionEnabled
                {
                    view_toast.btn_toastMessage.setTitle(btnMessage, for: .normal)
                }
                else
                {
                    view_toast.btn_toastMessage.setTitle("", for: .normal)
                }
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                if let viewWithTag = targetView.viewWithTag(1029) {
                    //                    print("Tag 100")
                    viewWithTag.removeFromSuperview()
                } else {
                    //                    print("tag not found")
                }
            }
        } else {
            print("Location services are not enabled")
            view_toast = Utility.SetUpToastView(targetView: targetView, targetedVC: targetedVC, message: message, actionEnabled: actionEnabled, buttonText: btnMessage)
            view_toast.tag = 1029
            if actionEnabled
            {
                view_toast.btn_toastMessage.setTitle(btnMessage, for: .normal)
            }
            else
            {
                view_toast.btn_toastMessage.setTitle("", for: .normal)
            }
            //            print("Location Check Git")
        }
    }
    
    @objc class func handleSettings(){
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
        }
    }
    
    class func getCurrencySymbolFromCurrencyCode(currencyCode : String) -> String{
        let localeIdentifier = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.currencyCode.rawValue: currencyCode])
        let locale = NSLocale(localeIdentifier: localeIdentifier)
        let currencySymbol = locale.object(forKey: NSLocale.Key.currencySymbol) as? String ?? ""
        return currencySymbol
    }
    
    class func convertToJsonString(dic : [String:Any]) -> String{
        let jsonData = try? JSONSerialization.data(withJSONObject: dic, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)!
        return jsonString
    }
    
    class func getCurrentDate(now:Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM,YYYY"
        
        let dateString = formatter.string(from:now)
        NSLog("%@", dateString)
        let dateArr = dateString.split(separator: " ")
        var stringDate = String()
        if ((dateArr[0] == "1") || (dateArr[0] == "31")){
            stringDate = String(format:"%@st %@",dateArr[0] as CVarArg,dateArr[1] as CVarArg)
        }
        else if (dateArr[0] == "2"){
            stringDate = String(format:"%@nd %@",dateArr[0] as CVarArg,dateArr[1] as CVarArg)
        }
        else if (dateArr[0] == "3"){
            stringDate = String(format:"%@rd %@",dateArr[0] as CVarArg,dateArr[1] as CVarArg)
        }
        else{
            stringDate = String(format:"%@th %@",dateArr[0] as CVarArg,dateArr[1] as CVarArg)
        }
        return stringDate
    }
    
    class func getCurrentDateInFormattedString(now:Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        
        let dateString = formatter.string(from:now)
        NSLog("%@", dateString)
        return dateString
    }
    
    class func getCurrentEnvironment(){
        if ApiConstants.kBaseUrl.baseUrl.contains("prod2") {
            saveStringInUserDefaults("Prod",key:ApiKeyConstants.kUserDefaults.kCurrentEnvironment)
        }
        else if ApiConstants.kBaseUrl.baseUrl.contains("dev.fdv2") {
            saveStringInUserDefaults("Dev",key:ApiKeyConstants.kUserDefaults.kCurrentEnvironment)
        }
        else if ApiConstants.kBaseUrl.baseUrl.contains("fdv2aws") {
            saveStringInUserDefaults("AWS",key:ApiKeyConstants.kUserDefaults.kCurrentEnvironment)
        }
        else{
            saveStringInUserDefaults("Demo",key:ApiKeyConstants.kUserDefaults.kCurrentEnvironment)
        }
    }
}

extension UIButton {
    func loadingIndicator(show: Bool) {
        if show {
            let indicator = UIActivityIndicatorView()
            indicator.style = .gray
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            for view in self.subviews {
                if let indicator = view as? UIActivityIndicatorView {
                    indicator.stopAnimating()
                    indicator.removeFromSuperview()
                }
            }
        }
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = leftPaddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        if self.tag == 131{
            let rightImagView = UIImageView(frame: CGRect(x: 5, y: 12, width: 6, height: 11))
            rightImagView.image = UIImage(named: "nextArrowGrey")
            rightImagView.contentMode = UIView.ContentMode.scaleAspectFit
            rightPaddingView.addSubview(rightImagView)
        }
        self.rightView = rightPaddingView
        self.rightViewMode = .always
    }
}

extension GMSPolygon {
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        
        if self.path != nil {
            if GMSGeometryContainsLocation(coordinate, self.path!, true) {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
    

    func isEqualToImage() -> Bool {
        
        return self.pngData() == UIImage(named: "docsIcon")!.pngData()
        
    }
        
}
//extension Dictionary {
//    func nullKeyRemoval() -> Dictionary {
//        var dict = self
//
//        let keysToRemove = Array(dict.keys).filter { dict[$0] is NSNull }
//        for key in keysToRemove {
//            dict[key] = "" as? Value
//        }
//
//        return dict
//    }
//}

//Milliseconds to date
extension Int {
    func dateFromMilliseconds() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self)/1000)
    }
}

extension String
{
    func isNullString() -> Bool {
        
        let outputString = self
        
        let x: AnyObject = NSNull()
        
        if ((outputString == x as? String) || (outputString.count == 0) || (outputString == " ") || (outputString == "") || (outputString == "(NULL)") || (outputString == "<NULL>") || (outputString == "<null>") || (outputString == "(null)")) {
            return true
        } else {
            return false
        }
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }

}

extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        
        return arrayOrdered
    }
}

extension UIApplication {
    class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}

extension Date {
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 0, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 6, to: sunday)
    }
}

extension UINavigationController
{
    func containsViewController(ofKind kind: AnyClass) -> Bool
    {
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }
}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    @IBInspectable
    var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
}

public extension UIAlertController {
    
    func setMessageAlignment(_ alignment : NSTextAlignment, message : String) {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = alignment
        
        let messageText = NSMutableAttributedString(
            string: message ,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        
        self.setValue(messageText, forKey: "attributedMessage")
    }
}

public extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String {
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
}
