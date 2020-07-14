//
//  SignUpOptionViewController.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 27/02/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import SVProgressHUD
import SwiftyJSON
import Reachability

class SignUpOptionViewController: UIViewController,GIDSignInDelegate {
    var socialSignInDict = [String:Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        // Do any additional setup after loading the view.
    }
    
    // MARK:- All Button Actions-----
    @IBAction func signUpWithEmailOrPhone(_ sender: Any) {
        socialSignInDict = [:]
        self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kSignUpSegue, sender: nil)
    }
    
    @IBAction func signUpWithFaceBook(_ sender: Any) {
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Loading...")
        }
        
        let fbLoginManager : LoginManager = LoginManager()
        //fbLoginManager.loginBehavior = FBSDKLoginBehaviorSystemAccount;
        fbLoginManager.logOut()
        fbLoginManager.logIn(permissions: [ApiKeyConstants.kEmail], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    return
                }
                if(fbloginresult.grantedPermissions.contains(ApiKeyConstants.kEmail))
                {
                    self.getFBUserData()
                }
            }
        }
    }
    
    @IBAction func signUpWithGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate=self
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        //GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func signInButtonTap(_ sender: Any) {
        Utility.goBackToSignInVC(self)
    }
    
    //MARK:- Google Delegate
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                     withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            var pic = String()
            if user.profile.hasImage {
                pic = user.profile.imageURL(withDimension: 200)?.absoluteString ?? ""
                debugPrint("Pic",pic as Any)
            }
            debugPrint("\(userId ?? "Not Avialble"),\(idToken ?? "Not Avialble"),\(fullName ?? "Not Avialble"),\(givenName ?? "Not Avialble"),\(familyName ?? "Not Avialble"),\(email?.lowercased() ?? "Not Avialble")")
            socialSignInDict = [ApiKeyConstants.kFirstName : Utility.trimmingString(givenName ?? ""),ApiKeyConstants.kLastName : Utility.trimmingString(familyName ?? ""),ApiKeyConstants.kEmail : Utility.trimmingString(email?.lowercased() ?? ""),ApiKeyConstants.kImage : pic,ApiKeyConstants.kSocialLoginType : "google",ApiKeyConstants.kSocialId:Utility.trimmingString(userId ?? ""),ApiKeyConstants.kToken : Utility.trimmingString(idToken ?? "")]
            self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kSignUpSegue, sender: nil)
        } else {
            debugPrint("\(error ?? "Not Available" as! Error)")
        }
    }
    
    // MARK:- Facebook User Data-----
    func getFBUserData(){
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    
                    debugPrint(result as Any)
                    let FbData = JSON(result as Any)
                    let dic_FB = FbData.dictionaryObject
                    let picture_dic:[String:Any] = dic_FB!["picture"] as? [String : Any] ?? [:]
                    let pictureData_dic:[String:Any] = picture_dic["data"] as? [String : Any] ?? [:]
                    let userImageUrl = pictureData_dic["url"] as? String ?? ""
                    debugPrint("User Image URL :- ",userImageUrl as String)
                    let socialID = dic_FB!["id"] as? String ?? ""
                    let userName = dic_FB![ApiKeyConstants.kDriverName] as? String ?? ""
                    let userMail = dic_FB![ApiKeyConstants.kEmail] as? String ?? ""
                    debugPrint("\(socialID)  \(userName) \(userMail)")
                    self.socialSignInDict = [ApiKeyConstants.kFirstName : Utility.trimmingString(dic_FB![ApiKeyConstants.kFirst_Name] as? String ?? ""),ApiKeyConstants.kLastName : Utility.trimmingString(dic_FB![ApiKeyConstants.kLast_Name] as? String ?? ""),ApiKeyConstants.kEmail : Utility.trimmingString(userMail.lowercased()) ,ApiKeyConstants.kImage : userImageUrl,ApiKeyConstants.kSocialLoginType : "facebook",ApiKeyConstants.kSocialId:socialID ,ApiKeyConstants.kToken : ""]
                    self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kSignUpSegue, sender: nil)
                }
            })
        }
    }
    
    // MARK:- Navigation ----
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == Constants.StoryboardSegueConstants.kSignUpSegue) {
            let signUpViewControllerObj = segue.destination as! SignUpViewController
            signUpViewControllerObj.socialData = socialSignInDict
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
