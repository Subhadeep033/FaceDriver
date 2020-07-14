//
//  EndTripDetailsViewController.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 07/02/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Cosmos
import SVProgressHUD
import Kingfisher
import Reachability

class TimeDistanceCell : UITableViewCell{
    @IBOutlet weak var payableAmountLabel: UILabel!
    @IBOutlet weak var tripDurationLabel: UILabel!
    @IBOutlet weak var tripDistanceLabel: UILabel!
    @IBOutlet weak var tripAmountLabel: UILabel!
}
class SeparatorCell : UITableViewCell{
    @IBOutlet weak var dividerLineImageView: UIImageView!
}
class PickDropCell : UITableViewCell{
    @IBOutlet weak var pickDropImageViewTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var pickDropImageView: UIImageView!
    @IBOutlet weak var pickDropHeaderLabel: UILabel!
    @IBOutlet weak var pickDropLineImageView: UIImageView!
    @IBOutlet weak var pickDropAddressLabel: UILabel!
    //@IBOutlet weak var underlineImageHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var underLineImageBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var underLineImageLabel: UILabel!
}
class ReceiptCell : UITableViewCell{
    @IBOutlet weak var underLineLabel: UILabel!
    @IBOutlet weak var underLineLabelTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var underLineLabelHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var fareTypeLabel: UILabel!
    @IBOutlet weak var fareValueLabel: UILabel!
}
class RatingCell : UITableViewCell{
    var completionBlock: Constants.TextViewCompletionBlock?
    var completionBlockShouldChange: Constants.TextViewShouldChangeCompletionBlock?
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var riderProfileImage: UIImageView!
    @IBOutlet weak var ratingView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    public func setTextViewDelegate(){
        feedbackTextView.delegate = self
        // MARK:- Textview Delegates ------
    }
    
}

extension RatingCell : UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Constants.AppColour.kAppLightGreyColor {
            textView.text = ""
            textView.textColor = Constants.AppColour.kAppBlackColor
        }
        _ = completionBlock!(textView,.textViewDidBeginEditing)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.AppAlertMessage.kThankYouNote
            textView.textColor = Constants.AppColour.kAppLightGreyColor
        }
        _ = completionBlock!(textView,.textViewDidEndEditing)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        guard let _ = completionBlockShouldChange else { return true }
        var txt: String = ""
        if let textString =  textView.text as NSString? {
            txt = (textString.replacingCharacters(in: range, with: text) as NSString) as String
        }
        if completionBlockShouldChange!(textView, txt) != nil {
            return completionBlockShouldChange!(textView, txt)!
        }
        return true
    }
}


class EndTripDetailsViewController: UIViewController {
    
    @IBOutlet weak var endTripTableView: UITableView!
    var endTripDetailsDict = [String : Any]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var completeTripHeaderLabel: UILabel!
    var riderImage : String = ""
    var endTripFareBreakup = [String]()
    fileprivate var ratingReviewDict = [String:Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
            if (Reachibility.isConnectedToNetwork()){
                riderImage = endTripDetailsDict[ApiKeyConstants.kImage] as? String ?? ""
                let tripId = endTripDetailsDict[ApiKeyConstants.kTripId] as? String ?? ""
                self.getTripInfo(tripId: tripId)
            }
            else{
                Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
            }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        endTripFareBreakup = ["RECEIPT","Fare","CO2 Offset","FD Fees","Subtotal","HST","Toll","Final Payout"]
        
        self.endTripTableView.estimatedRowHeight    = 20
        self.endTripTableView.rowHeight             = UITableView.automaticDimension
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- Keyboard Observer Method---
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    //MARK:- All Button Actions----
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonTap(_ sender: Any) {
        if Reachibility.isConnectedToNetwork(){
            callRatingReviewApi()
        }
        else{
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kNetworkError, Button_Title: Constants.AppAlertAction.kOKButton, self)
        }
    }
    
    func callRatingReviewApi(){
        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(currentVC.view)
            SVProgressHUD.show(withStatus: "Loading...")
        }
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": authToken]
        //let ratingCell:RatingCell = endTripTableView.cellForRow(at: IndexPath(row: 0, section: 6)) as? RatingCell ?? UITableViewCell
        let tripRatingApi = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kRatingReviewApi
//        if (Utility.isEqualtoString(ratingCell.feedbackTextView.text, Constants.AppAlertMessage.kThankYouNote)){
//            ratingCell.feedbackTextView.text = ""
//        }
        let dictForApiCall = [ApiKeyConstants.kTrip_id : endTripDetailsDict[ApiKeyConstants.kTripId] as? String ?? "", ApiKeyConstants.kTripRating : self.ratingReviewDict[ApiKeyConstants.kRating] as? Double ?? 0.0,ApiKeyConstants.kTripReview : self.ratingReviewDict[ApiKeyConstants.kFeedback] as? String ?? ""] as [String:Any]
        Utility.removeAppCookie()
        APIWrapper.requestPUTURL(tripRatingApi, params: dictForApiCall as [String : AnyObject], headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            
            debugPrint(dictResponse!)
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        self.navigationController?.popViewController(animated: true)
//                        self.updateAverageRating()
                    }
                    else{
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                    }
                }
                else{
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, self)
                }
            }
            else{
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
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
    // MARK:- Get Trip Info For Rider End Trip -----
    func getTripInfo(tripId : String){
        let currentVC : UIViewController = UIApplication.getTopMostViewController()!
        DispatchQueue.main.async {
            SVProgressHUD.setContainerView(currentVC.view)
            SVProgressHUD.show(withStatus: "Loading...")
        }
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
        
        let authToken = "Bearer " + token
        let dictHeaderParams:[String : String] = ["Authorization": authToken,
                                                  "cache-control": "no-cache"]
        let bodyParams : [String : String] = [ApiKeyConstants.kTrip_id : tripId]
        Utility.removeAppCookie()
        let fcmTokenUrl = ApiConstants.kBaseUrl.baseUrl + ApiConstants.kApisEndPoint.kGetTripInfo
        
        APIWrapper.requestPOSTURL(fcmTokenUrl, params: bodyParams, headers: dictHeaderParams, success: { (JSONResponse) in
            let jsonValue = JSONResponse
            let dictResponse = jsonValue.dictionaryObject
            debugPrint(dictResponse!)
            
            if(dictResponse![ApiKeyConstants.kInValidSession] as? Int ?? 0 == 1){
                if(dictResponse![ApiKeyConstants.kSuccess] as? Int ?? 0 == 1){
                    if(dictResponse![ApiKeyConstants.kStatus] as? Int ?? 0 == 1){
                        self.endTripDetailsDict = dictResponse![ApiKeyConstants.kFareBreakUp] as? Dictionary ?? [:]
                        self.endTripDetailsDict[ApiKeyConstants.kTripTime] = dictResponse![ApiKeyConstants.kTotal_time] as? Int ?? 0
                        self.endTripDetailsDict[ApiKeyConstants.kTripDistance] = dictResponse![ApiKeyConstants.kTotal_km] as? Double ?? 0.0
                        self.endTripDetailsDict[ApiKeyConstants.kImage] = self.riderImage
                        self.endTripDetailsDict[ApiKeyConstants.kTripId] = tripId
                        //self.initializeUI()
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        self.endTripTableView.reloadData()
                    } else {
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: dictResponse![ApiKeyConstants.kMessage] as? String ?? Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
                    }
                }
                else{
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kSomeThingWentWrong, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
                }
            }
            else{
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                Utility.showAlertForSessionExpired(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kInvalidSession, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
            }
        })
        { (error) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            Utility.ShowAlert(title: Constants.AppAlertMessage.kAlertTitle, message: Constants.AppAlertMessage.kTryAgain, Button_Title: Constants.AppAlertAction.kOKButton, currentVC)
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

extension EndTripDetailsViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) || (section == 1) || (section == 3) || (section == 5) || (section == 6){
            return 1
        }
        else if (section == 4){
            return endTripFareBreakup.count
        }
        else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 1) || (indexPath.section == 3) || (indexPath.section == 5){
            let separatorCell: SeparatorCell
            separatorCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kDividerCellId, for: indexPath) as! SeparatorCell
            return separatorCell
        }
        else if (indexPath.section == 0){
            let timeDistanceCell: TimeDistanceCell
            timeDistanceCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kTimeDistanceCellId, for: indexPath) as! TimeDistanceCell
            let driverFareDetails : [String:Any] = endTripDetailsDict[ApiKeyConstants.kDriverPayment] as? [String:Any] ?? [:]
            timeDistanceCell.payableAmountLabel.text = "YOUR EARNINGS"
            timeDistanceCell.tripAmountLabel.text = String(format: "$ %.2f", driverFareDetails[ApiKeyConstants.kFinalPayment] as? Double ?? 0.0)
            timeDistanceCell.tripDistanceLabel.text = String(format: "%.2fKm", endTripDetailsDict[ApiKeyConstants.kTripDistance] as? Double ?? 0.0)
            timeDistanceCell.tripDurationLabel.text = "TIME TAKEN : \(endTripDetailsDict[ApiKeyConstants.kTripTime] ?? 0)MIN"
            
            return timeDistanceCell
        }
        else if (indexPath.section == 2){
            let pickDropCell: PickDropCell
            pickDropCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kPickupDropCellId, for: indexPath) as! PickDropCell
            
            if (indexPath.row == 0){
                pickDropCell.pickDropImageView.image = UIImage(named: "userLocation")
                pickDropCell.pickDropHeaderLabel.text = "Pick Up Location"
                pickDropCell.pickDropAddressLabel.text = appDelegate.pickUpAddress
                pickDropCell.pickDropImageViewTopConstraints.constant = 10.0
                pickDropCell.underLineImageBottomConstraints.constant = 10.0
                pickDropCell.pickDropLineImageView.image = UIImage(named: "pickUpDropImg")
                pickDropCell.underLineImageLabel.isHidden = false
                
            }
            else{
                pickDropCell.pickDropImageView.image = UIImage(named: "dropLocation")
                pickDropCell.pickDropHeaderLabel.text = "Drop Location"
                pickDropCell.pickDropAddressLabel.text = appDelegate.tripEndAddress
                pickDropCell.pickDropImageViewTopConstraints.constant = 0
                pickDropCell.underLineImageBottomConstraints.constant = 0
                pickDropCell.underLineImageLabel.isHidden = true
                pickDropCell.pickDropLineImageView.image = UIImage(named: "")
            }
            return pickDropCell
        }
        else if (indexPath.section == 4){
            let receiptCell: ReceiptCell
            receiptCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kReceiptCellId, for: indexPath) as! ReceiptCell
            let driverFareDetails : [String:Any] = endTripDetailsDict[ApiKeyConstants.kDriverPayment] as? [String:Any] ?? [:]
            if (indexPath.row == 0){
                receiptCell.fareTypeLabel.text = endTripFareBreakup[indexPath.row]
                receiptCell.fareTypeLabel.font = UIFont(name: "Roboto-Medium", size: 15.0)
                receiptCell.fareValueLabel.text = ""
                receiptCell.underLineLabelTopConstraints.constant = 6.0
                receiptCell.underLineLabelHeightConstraints.constant = 1.0
            }
            else if (indexPath.row == 1){
                receiptCell.fareTypeLabel.text = endTripFareBreakup[indexPath.row]
                receiptCell.fareValueLabel.text = String(format: "$ %.2f", driverFareDetails[ApiKeyConstants.kFare] as? Double ?? 0.0)
                receiptCell.underLineLabelTopConstraints.constant = 0
                receiptCell.underLineLabelHeightConstraints.constant = 0
            }
            else if (indexPath.row == 2){
                receiptCell.fareTypeLabel.text = endTripFareBreakup[indexPath.row]
                receiptCell.fareValueLabel.text = String(format: "$ %.2f", driverFareDetails[ApiKeyConstants.kCarbonOffsetFee] as? Double ?? 0.0)
                receiptCell.underLineLabelTopConstraints.constant = 0
                receiptCell.underLineLabelHeightConstraints.constant = 0
            }
            else if (indexPath.row == 3){
                receiptCell.fareTypeLabel.text = endTripFareBreakup[indexPath.row]
                receiptCell.fareValueLabel.text = String(format: "$ %.2f", driverFareDetails[ApiKeyConstants.kFDFees] as? Double ?? 0.0)
                receiptCell.underLineLabelTopConstraints.constant = 0
                receiptCell.underLineLabelHeightConstraints.constant = 0
            }
            else if (indexPath.row == 4){
                receiptCell.fareTypeLabel.text = endTripFareBreakup[indexPath.row]
                receiptCell.fareValueLabel.text = String(format: "$ %.2f", driverFareDetails[ApiKeyConstants.kSubTotal] as? Double ?? 0.0)
                receiptCell.underLineLabelTopConstraints.constant = 0
                receiptCell.underLineLabelHeightConstraints.constant = 0
            }
            else if (indexPath.row == 5){
                receiptCell.fareTypeLabel.text = endTripFareBreakup[indexPath.row]
                receiptCell.fareValueLabel.text = String(format: "$ %.2f", driverFareDetails[ApiKeyConstants.kHST] as? Double ?? 0.0)
                receiptCell.underLineLabelTopConstraints.constant = 0
                receiptCell.underLineLabelHeightConstraints.constant = 0
            }
            else if (indexPath.row == 6){
                receiptCell.fareTypeLabel.text = endTripFareBreakup[indexPath.row]
                receiptCell.fareValueLabel.text = String(format: "$ %.2f", driverFareDetails[ApiKeyConstants.kToll] as? Double ?? 0.0)
                receiptCell.underLineLabelTopConstraints.constant = 6.0
                receiptCell.underLineLabelHeightConstraints.constant = 1.0
            }
            else{
                receiptCell.fareTypeLabel.text = endTripFareBreakup[indexPath.row]
                receiptCell.fareTypeLabel.font = UIFont(name: "Roboto-Medium", size: 15.0)
                receiptCell.fareValueLabel.text = String(format: "$ %.2f", driverFareDetails[ApiKeyConstants.kFinalPayment] as? Double ?? 0.0)
                receiptCell.fareValueLabel.font = UIFont(name: "Roboto-Medium", size: 15.0)
                receiptCell.underLineLabelTopConstraints.constant = 2.0
                receiptCell.underLineLabelHeightConstraints.constant = 0
            }
            return receiptCell
        }
        else {
            let ratingCell: RatingCell
            ratingCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kRatingCellId, for: indexPath) as! RatingCell
            let urlString = endTripDetailsDict[ApiKeyConstants.kImage]
            let url = URL(string: urlString as? String ?? "")
            ratingCell.riderProfileImage.kf.indicatorType = .activity
            ratingCell.riderProfileImage.kf.setImage(with: url, placeholder: UIImage(named: "profileImagePlaceholder"), options: nil, progressBlock: nil) { (result) in
                
            }
            ratingCell.feedbackTextView.text = Constants.AppAlertMessage.kThankYouNote
            ratingCell.feedbackTextView.textColor = Constants.AppColour.kAppLightGreyColor
            ratingCell.setTextViewDelegate()
            ratingCell.completionBlockShouldChange = { (textView, candidateString ) in
                if (Utility.isEqualtoString(candidateString, Constants.AppAlertMessage.kThankYouNote)){
                    ratingCell.feedbackTextView.text = Constants.AppAlertMessage.kThankYouNote
                    ratingCell.feedbackTextView.textColor = Constants.AppColour.kAppLightGreyColor
                    self.ratingReviewDict[ApiKeyConstants.kFeedback] = ""
                }
                else{
                    self.ratingReviewDict[ApiKeyConstants.kFeedback] = candidateString
                    ratingCell.feedbackTextView.textColor = Constants.AppColour.kAppLightBlackColor
                }
                return true
            }
            
            ratingCell.completionBlock = { (textView, textViewDelegateType) in
                DispatchQueue.main.async {
                    switch textViewDelegateType {
                    case .textViewDidBeginEditing:
                        textView.becomeFirstResponder()
                        break;
                    case.textViewDidEndEditing:
                        textView.resignFirstResponder()
                        break;
                    default:
                        break;
                    }
                }
                return true
            }
            
            ratingCell.ratingView.didFinishTouchingCosmos = {
                    rating in
                self.ratingReviewDict[ApiKeyConstants.kRating] = ratingCell.ratingView.rating
            }
            
            return ratingCell
        }
    }
}
