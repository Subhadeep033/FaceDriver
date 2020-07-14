//
//  AddNewCarConditionViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 5/2/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Reachability


class AddNewCarConditionViewController: UIViewController {
    
    var isFromPageView = Bool()
    @IBOutlet weak var txtviewWelcomeMsg: UITextView!
    @IBOutlet weak var logoHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var textViewTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var logoTopConstraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initializeView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.txtviewWelcomeMsg.scrollRangeToVisible(NSRange(location: 0, length: 0))
        }
    }
    
    func initializeView() {
        
        if (isFromPageView){
            let infoMessage = Utility.retrieveStringFromUserDefaults( ApiKeyConstants.kUserDefaults.kInfoMessage)
            logoTopConstraints.constant = 20
            logoHeightConstraints.constant = 0
            textViewTopConstraints.constant = 0
            txtviewWelcomeMsg.attributedText = infoMessage.htmlToAttributedString
            txtviewWelcomeMsg.contentOffset.y = 0
            doneBtn.setTitle("Get Started", for: .normal)
            self.checkPTCStatus()
        }
        else{
            let welcomeStr = Utility.retrieveStringFromUserDefaults(ApiKeyConstants.kUserDefaults.kWelcomeMessage)
            txtviewWelcomeMsg.layer.borderColor = Constants.AppColour.kAppLightGreyColor.cgColor
            txtviewWelcomeMsg.layer.borderWidth = 1.0
            logoTopConstraints.constant = 60
            logoHeightConstraints.constant = 50
            textViewTopConstraints.constant = 50
            txtviewWelcomeMsg.attributedText = welcomeStr.htmlToAttributedString
            txtviewWelcomeMsg.contentOffset.y = 0
            doneBtn.setTitle("I Agree", for: .normal)
        }
    }
    //MARK:- Button Action
    
    @IBAction func doneButtonTap(_ sender: UIButton) {
        if (isFromPageView){
            let pageController = self.parent as! PageViewController
            pageController.scrollToIndex(index: 1, animated: true)
            NotificationCenter.default.post(name: NSNotification.Name("load"), object: nil)
        }
        else{
            let storyBoard = UIStoryboard.init(name: "DriverInfo", bundle: Bundle.main)
            let carListVC = storyBoard.instantiateViewController(withIdentifier: "AddNewCarPageViewController") as! AddNewCarPageViewController
            self.show(carListVC, sender: self)
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
    
    func checkPTCStatus(){
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let ptcStatus = driverDetailsDict[ApiKeyConstants.kUserDefaults.kPTCStatus] as? String ?? ""
        
        switch ptcStatus {
            
        case ApiKeyConstants.PTCStatus.kForReview:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kReviewStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kEConsentSent:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.eConsentStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kAbstractReady:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kAbstractReadyStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kFingerPrintsRequired:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kFingerprintsRequiredStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kAbstractRejected:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kAbstractRejectedStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kPTCPending,ApiKeyConstants.PTCStatus.kPTCSubmissionReady:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kPTCSubmissionReadyStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kOrientationReady:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kOrientationReadyStatus, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        case ApiKeyConstants.PTCStatus.kHamiltonWaitingList:
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kWaitingListHamilton, Button_Title: Constants.AppAlertAction.kOKButton, self)
            break;
            
        default:
            break;
        }
    }
}
