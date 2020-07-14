//
//  StatusViewController.swift
//  Facedriver
//
//  Created by DAT-Asset-194 on 10/09/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SVProgressHUD
class StatusViewController: UIViewController {
    
    @IBOutlet weak var ptcStatusTextView: UITextView!
    var isFromPageView = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.getDriverProfieDetails()
    }
    
    @IBAction func getStartedTap(_ sender: Any) {
        let alertController = UIAlertController(title: Constants.AppAlertMessage.kAlertTitle, message: "" as String, preferredStyle: UIAlertController.Style.alert)
        alertController.setMessageAlignment(.left, message: Constants.AppAlertMessage.kSubmitMessage)
        alertController.view.tintColor = Constants.AppColour.kAppGreenColor
        let cancelAction = UIAlertAction(title: Constants.AppAlertAction.kOKButton, style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            debugPrint("Cancel")
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSubmitMessage, Button_Title: Constants.AppAlertAction.kOKButton, self)
    }
    
    public func getDriverProfieDetails() {
        
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        Utility.removeAppCookie()
        let profileDetailsUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kDriverProfile
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Getting Driver Details...")
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
                        if resultDict[ApiKeyConstants.kIsApproved] != nil {
                            if resultDict[ApiKeyConstants.kIsApproved] as? Bool == false {
                                self.checkPTCStatus()
                            }
                            else{
                                let storyBoard = UIStoryboard.init(name: "Home", bundle: Bundle.main)
                                let homeVc = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kHomeStoryboardId) as! HomeViewController
                                self.navigationController?.pushViewController(homeVc, animated: true)
                            }
                        }
                        else{
                            self.checkPTCStatus()
                        }
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
    
    func checkPTCStatus(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let ptcStatus = driverDetailsDict[ApiKeyConstants.kUserDefaults.kPTCStatus] as? String ?? ""
        ptcStatusTextView.textAlignment = .left
        switch ptcStatus {
            
        case ApiKeyConstants.PTCStatus.kForReview:
            ptcStatusTextView.text = Constants.AppAlertMessage.kReviewStatus
            //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kReviewStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kEConsentSent:
            ptcStatusTextView.text = Constants.AppAlertMessage.eConsentStatus
            //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.eConsentStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kAbstractReady:
            ptcStatusTextView.text = Constants.AppAlertMessage.kAbstractReadyStatus
            //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kAbstractReadyStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kFingerPrintsRequired:
            ptcStatusTextView.text = Constants.AppAlertMessage.kFingerprintsRequiredStatus
            //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kFingerprintsRequiredStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kAbstractRejected:
            ptcStatusTextView.text = Constants.AppAlertMessage.kAbstractRejectedStatus
            //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kAbstractRejectedStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kPTCPending,ApiKeyConstants.PTCStatus.kPTCSubmissionReady:
            ptcStatusTextView.text = Constants.AppAlertMessage.kPTCSubmissionReadyStatus
            //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kPTCSubmissionReadyStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kOrientationReady:
            ptcStatusTextView.text = Constants.AppAlertMessage.kOrientationReadyStatus
            //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kOrientationReadyStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kHamiltonWaitingList:
            ptcStatusTextView.text = Constants.AppAlertMessage.kWaitingListHamilton
            //Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kWaitingListHamilton, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        default:
            ptcStatusTextView.text = Constants.AppAlertMessage.kDefaultPTCMessage
            
            break;
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
