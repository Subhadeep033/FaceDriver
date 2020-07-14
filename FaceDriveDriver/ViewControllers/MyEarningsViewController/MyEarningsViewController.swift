//
//  MyEarningsViewController.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 11/03/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Kingfisher
import Reachability

class PaymentHistoryTableCell : UITableViewCell{
    
    @IBOutlet weak var paymentAmountLabel: UILabel!
    @IBOutlet weak var tripIdLabel: UILabel!
    @IBOutlet weak var paymentModeLabel: UILabel!
    @IBOutlet weak var riderNameLabel: UILabel!
    @IBOutlet weak var paymentHistoryView: UIView!
    @IBOutlet weak var riderImageView: UIImageView!
}
class TimeSpanCell : UITableViewCell {
    @IBOutlet weak var timeSpanLabel: UILabel!
    @IBOutlet weak var selectImageView: UIImageView!
}

class MyEarningsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var timeSpanArr = ["Weekly","Monthly","Yearly","Select Range"]
    
    @IBOutlet weak var timeRangeLabel: UILabel!
    @IBOutlet weak var totalEarningsLabel: UILabel!
    @IBOutlet weak var rangeViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var earningsTable: UITableView!
    @IBOutlet weak var timeSpanTableView: UITableView!
    
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var timeRangeImageView: UIImageView!
    @IBOutlet weak var calenderButtonYConstraints: NSLayoutConstraint!
    @IBOutlet weak var timeRangeView: UIView!

    @IBOutlet weak var timeSpanTableHeightConstraints: NSLayoutConstraint!
    fileprivate var indexPathSelect = [IndexPath]()
    
    @IBOutlet weak var toolviewHeight: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var containerViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    var fromToValueTag = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        timeRangeImageView.layer.cornerRadius = 3
        timeRangeImageView.clipsToBounds = true
        rangeViewHeightConstraints.constant = 0
        tableViewTopConstraints.constant = 0
    }
    
    // MARK:- All Button Action Methods-----
    @IBAction func showDatePickerButtonTap(_ sender: UIButton) {
        fromToValueTag = sender.tag
        showDatePicker()
    }
    
    @IBAction func calenderButtonTap(_ sender: Any) {
        timeSpanTableView.isHidden = !timeSpanTableView.isHidden
        timeSpanTableView.reloadData()
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:- TableView Delegate & DataSource Methods-----
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == earningsTable{
            return 90
        }
        else{
            return 50
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == earningsTable{
            return 5
        }
        else{
            timeSpanTableHeightConstraints.constant = CGFloat(50 * timeSpanArr.count)
            return timeSpanArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == earningsTable {
            let paymentCell : PaymentHistoryTableCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kMyEaringsCell) as! PaymentHistoryTableCell
//            let urlString = driverDetailsDict![ApiKeyConstants.kImage] as? String ?? ""
            let url = URL(string: "")
            paymentCell.riderImageView.kf.indicatorType = .activity
            paymentCell.riderImageView.kf.setImage(with: url, placeholder: UIImage(named: "profileImagePlaceholder"), options: nil, progressBlock: nil) { (result) in
                
                
            }
            paymentCell.riderNameLabel.text = "John Deo"
            paymentCell.riderNameLabel.font = UIFont(name: "Roboto-Bold", size:15)
            paymentCell.tripIdLabel.text = "#34256798"
            paymentCell.tripIdLabel.font = UIFont(name: "Roboto-Light", size:13)
            paymentCell.paymentAmountLabel.text = "$2.99"
            paymentCell.paymentAmountLabel.font = UIFont(name: "Roboto-Bold", size:16)
//            paymentCell.paymentModeLabel.text = "Cash"
            paymentCell.paymentModeLabel.font = UIFont(name: "Roboto-Medium", size:13)
            paymentCell.paymentHistoryView.layer.borderColor = Constants.AppColour.kAppLightGreyColor.cgColor
            paymentCell.paymentHistoryView.layer.borderWidth = 1.0
            paymentCell.paymentHistoryView.layer.cornerRadius = 5.0
            paymentCell.paymentHistoryView.clipsToBounds = true
            
            return paymentCell
        }
        else{
            let timeCell : TimeSpanCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kTimeSpanCellId) as! TimeSpanCell
            timeCell.selectImageView.image = UIImage(named:"")
            timeCell.timeSpanLabel.text = timeSpanArr[indexPath.row]
            timeCell.timeSpanLabel.alpha = 0.5
            debugPrint ("index=",indexPathSelect.count)
            if indexPathSelect.count > 0{
                let result = indexPathSelect.filter { $0==indexPath }
                if result.count > 0{
                    timeCell.selectImageView.image =  UIImage(named:"checkTick")
                    timeCell.timeSpanLabel.alpha = 1.0
                }
                else{
                    timeCell.selectImageView.image = UIImage(named:"")
                }
            }
            
            if indexPath.row == timeSpanArr.count-1{
                timeCell.separatorInset = .zero
                
            }
            return timeCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == timeSpanTableView{
            timeRangeLabel.text = timeSpanArr[indexPath.row]
            if Utility.isEqualtoString(timeRangeLabel.text!, "Select Range"){
                rangeViewHeightConstraints.constant = 55
                tableViewTopConstraints.constant = 20
            }
            else{
                rangeViewHeightConstraints.constant = 0
                tableViewTopConstraints.constant = 0
            }
            if indexPathSelect.count > 0{
                let result = indexPathSelect.filter { $0==indexPath }
                debugPrint(result)
                if result.count > 0{
                }
                else{
                    indexPathSelect.remove(at: 0)
                    debugPrint(indexPathSelect)
                    indexPathSelect.insert(indexPath, at: 0)
                    debugPrint(indexPathSelect)
                }
            }
            else{
                indexPathSelect.insert(indexPath, at: 0)
                debugPrint(indexPathSelect)
            }
            timeSpanTableView.reloadData()
        }
        else{
            goToTripDetails()
        }
    }
    
    // MARK:- Navigate To TripDetails Methods-----
    func goToTripDetails(){
        let storyBoard = UIStoryboard.init(name: "EarningsAndTrips", bundle: Bundle.main)
        let tripDetailsVC = storyBoard.instantiateViewController(withIdentifier: Constants.StoryboardIDConstants.kMyTripsStoryboardDetailsId) as! MyTripsDetailsViewController
        
        self.show(tripDetailsVC, sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK:- DatePicker
    func showDatePicker(){
        // DatePicker
        datePicker.datePickerMode = .date
        if fromToValueTag == 1{
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let date = formatter.date(from: fromDateLabel.text!)
            datePicker.minimumDate = date
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.containerViewHeightConstraints.constant = 250
            self.toolviewHeight.constant = 40
            self.view.layoutIfNeeded()
            
        }) { (completion) in
            
        }
    }
    
    // MARK:- DatePicker Button Action -----
    @IBAction func doneButtonTap(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        if fromToValueTag == 0{

            fromDateLabel.text = formatter.string(from: datePicker.date)
        }
        else{
            toDateLabel.text = formatter.string(from: datePicker.date)
        }

            UIView.animate(withDuration: 0.5, animations: {
                self.containerViewHeightConstraints.constant = 0
                self.toolviewHeight.constant = 0
                self.view.layoutIfNeeded()
            
            }) { (completion) in
            
            }
    }
    
    @IBAction func cancelButtonTap(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.containerViewHeightConstraints.constant = 0
            self.toolviewHeight.constant = 0
            self.view.layoutIfNeeded()
            
        }) { (completion) in
            
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

