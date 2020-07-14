//
//  InitialViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 4/18/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import Reachability
import SVProgressHUD

var getDriverDetailsCallback : ((Bool) -> Void)?
class InitialViewController: UIViewController {
    
    fileprivate var userToken = String()
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        if Reachibility.isConnectedToNetwork(){
            getDriverProfieDetails()
        }
        else{
            // No Network.
        }
        
        getDriverDetailsCallback = {(details) in
            if (details){
                if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
                    self.signInButton.isHidden = true
                    self.signUpButton.isHidden = true
                    
                    let driverDetailsDict : [String : Any] = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                    self.userToken = driverDetailsDict[ApiKeyConstants.kid] as? String ?? ""
                    if self.appDelegate.appDelRef == nil {
                        self.appDelegate.appDelRef = Database.database().reference()
                    }
                    
              self.appDelegate.appDelRef.child(ApiKeyConstants.kFirebaseTableName).child(driverDetailsDict[ApiKeyConstants.kid] as? String ?? "").child(ApiKeyConstants.kToken).observe(.value, with: { (snapshot) in
                        print("Token:",snapshot.value as? String ?? "", driverDetailsDict[ApiKeyConstants.kToken] as? String ?? "")
                        
                        if Utility.isEqualtoString(driverDetailsDict[ApiKeyConstants.kToken] as? String ?? "", snapshot.value as? String ?? "") {
                            
                            if driverDetailsDict[ApiKeyConstants.kIsApproved] != nil {
                                if driverDetailsDict[ApiKeyConstants.kIsApproved] as? Bool == false {
                                    let storyBoard = UIStoryboard.init(name: "DriverInfo", bundle: Bundle.main)
                                    let addNewCarVc = storyBoard.instantiateViewController(withIdentifier: "AddNewCarConditionViewController") as! AddNewCarConditionViewController
                                    self.show(addNewCarVc, sender: self)
                                    
                                } else {
                                    let storyBoard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
                                    let homeVc = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kHomeStoryboardId) as! HomeViewController
                                    let navigationController = UINavigationController(rootViewController: homeVc)
                                    navigationController.isNavigationBarHidden = true
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.window?.rootViewController = navigationController
                                }
                            } else {
                                let storyBoard = UIStoryboard.init(name: "DriverInfo", bundle: Bundle.main)
                                let addNewCarVc = storyBoard.instantiateViewController(withIdentifier: "AddNewCarConditionViewController") as! AddNewCarConditionViewController
                                
                                self.show(addNewCarVc, sender: self)
                            }
                        } else {
                            self.logout()
                        }
                    })
                } else {
                    self.goToInitialPage()
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.setScreenName("Initial", screenClass: String(describing: self) )
    }
    
    func goToInitialPage(){
        self.signInButton.isHidden = false
        self.signUpButton.isHidden = false
        self.signUpButton.layer.cornerRadius = self.signUpButton.frame.height/2
        self.signUpButton.layer.borderColor = Constants.AppColour.kAppGreenColor.cgColor
        self.signUpButton.layer.borderWidth = 1.0
        self.signInButton.layer.cornerRadius = self.signInButton.frame.height/2
    }
    // MARK:- Service Call
    
    public func getDriverProfieDetails() {
        if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
            
            let authToken = "Bearer " + token
            let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                      "cache-control": "no-cache"]
            Utility.removeAppCookie()
            let profileDetailsUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kDriverProfile
            DispatchQueue.main.async {
                SVProgressHUD.setContainerView(self.view)
                //            SVProgressHUD.show(withStatus: "Getting Driver Details...")
            }
            
            APIWrapper.requestPOSTURL(profileDetailsUrl, params: [:], headers: dictHeaderParams, success: { (JSONResponse) in
                let jsonValue = JSONResponse
                let dictResponse = jsonValue.dictionaryObject
                debugPrint(dictResponse!)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                        if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                            var resultDict : [String : Any] = dictResponse![ApiKeyConstants.kResult] as? [String : Any] ?? [:]
                            resultDict[ApiKeyConstants.kToken] = token
                            resultDict = Utility.recursiveNullRemoveFromDictionary(responseDict: resultDict)
                            debugPrint(resultDict)
                            Utility.saveToUserDefaultsWithKeyandDictionary(resultDict , key: ApiKeyConstants.kUserDefaults.kDriverDetails)
                            getDriverDetailsCallback?(true)
                        } else {
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
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
        }
        else {
            self.goToInitialPage()
        }
    }
    
    // MARK:- Logout Api Called ----
    func logout() {

        //     Logout Api call.
        if(Reachibility.isConnectedToNetwork()){
            if UserDefaults.standard.object(forKey: ApiKeyConstants.kUserDefaults.kDriverDetails) != nil {
                let driverDetailsDict : [String : Any] = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                let userAuthToken = driverDetailsDict[ApiKeyConstants.kid] as? String ?? ""
                if Utility.isEqualtoString(userAuthToken, self.userToken){
                    let storyBoard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
                    let menuVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSideMenuStoryboardId) as! SideMenuViewController
                    menuVC.logoutApiCalled(token: driverDetailsDict[ApiKeyConstants.kToken] as? String ?? "",isForceLogout:true)
                }
            }
            else{
                
            }
        }
        else{
            //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    // MARK:- All Button Actions-----
    @IBAction func signInButtonTap(_ sender: Any) {
        let signInController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSignInStoryboardId) as! SignInViewController
        let navigationController = UINavigationController(rootViewController: signInController)
        navigationController.isNavigationBarHidden = true
        appDelegate.window?.rootViewController = navigationController
    }
    
    // MARK:- SignUp Button Tap -----
    @IBAction func signUpButtonTap(_ sender: Any) {
        let signInController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSignInStoryboardId) as! SignInViewController
        let signUpOptionController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kSignUpOptionStoryboardId) as! SignUpOptionViewController
        let rootViewController = appDelegate.window!.rootViewController as! UINavigationController
        rootViewController.viewControllers.insert(signInController, at: 0)
        rootViewController.pushViewController(signUpOptionController, animated: true)
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
