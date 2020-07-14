//
//  ReferEarnViewController.swift
//  Facedriver
//
//  Created by DAT-Asset-259 on 02/05/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import SVProgressHUD

class ReferEarnViewController: UIViewController {

    @IBOutlet weak var promoDescriptionLabel: UILabel!
    @IBOutlet weak var sharePromoCodeButton: UIButton!
    var referalMessage = String()
    @IBOutlet weak var inviteFriendsLabel: UILabel!
    @IBOutlet weak var shareCodeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        convertToAttributedString()
        fetchReferalCode()
        sharePromoCodeButton.layer.borderColor = Constants.AppColour.kAppBorderColor.cgColor
        sharePromoCodeButton.layer.borderWidth = 2.0
        // Do any additional setup after loading the view.
    }
    
    // MARK:- Attributed String Method ------
    func convertToAttributedString(){
        let inviteAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: Constants.AppColour.kAppGreenColor,
            .font: UIFont(name: "Roboto-Medium", size: 22.0)! ]
        let frndAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: Constants.AppColour.kAppGreenColor,
            .font: UIFont(name: "Roboto-Medium", size: 22.0)! ]
        let inviteAttStr = NSMutableAttributedString(string: "Invite", attributes: inviteAttributes)
        let frndAttStr = NSMutableAttributedString(string: " Friends", attributes: frndAttributes)
        inviteAttStr.append(frndAttStr)
        self.inviteFriendsLabel.attributedText = inviteAttStr
        
        let shareAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: Constants.AppColour.kAppGreenColor,
            .font: UIFont(name: "Roboto-Light", size: 19.0)! ]
        let codeAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: Constants.AppColour.kAppGreenColor,
            .font: UIFont(name: "Roboto-Light", size: 19.0)! ]
        let shareAttStr = NSMutableAttributedString(string: "Share Your", attributes: shareAttributes)
        let codeAttStr = NSMutableAttributedString(string: " Invite Code", attributes: codeAttributes)
        shareAttStr.append(codeAttStr)
        self.shareCodeLabel.attributedText = shareAttStr
    }
    
    // MARK:- PromoCode Button Action-----
    @IBAction func sharePromoCodeTap(_ sender: Any) {
        
        let textToShare = [ referalMessage ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK:- Back Button Action-----
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:- ReferalCode Api Called-----
    func fetchReferalCode() {
        
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        let referalUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kReferalCode
        
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Getting Referal Code...")
        }
        
        APIWrapper.requestGETURL(referalUrl, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1) {
                    let referDict = dictResponse![ApiKeyConstants.kResult] as? [String:Any] ?? [:]
                    self.sharePromoCodeButton.setTitle(referDict[ApiKeyConstants.kReferalCode] as? String, for: .normal)
                    self.promoDescriptionLabel.text = referDict[ApiKeyConstants.kReferalDescription] as? String
//                    let currencySymbol = Utility.getCurrencySymbolFromCurrencyCode(currencyCode: referDict[ApiKeyConstants.kCurrency] as? String ?? "")
//                    let referAmount = referDict[ApiKeyConstants.kReferalAmount] as? String ?? ""
//                    let referLink = referDict[ApiKeyConstants.kReferalLink] as? String ?? ""
                    self.referalMessage = referDict[ApiKeyConstants.kSharedMessage] as? String ?? ""
                    debugPrint("ReferMessage :",self.referalMessage)
                    
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
}
