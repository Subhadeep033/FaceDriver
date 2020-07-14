//
//  CountryCodePopups.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 22/02/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Reachability

protocol CountryCodeDelegate {
    func selectedCountryCode(countryDetails:[String:Any])
}

fileprivate var tableDataCountry = [[String:String]]()
fileprivate var tableSearchDataCountry = [[String:String]]()
fileprivate var search:String = ""

class CountryCodePopups: UIView,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var countryListTableView: UITableView!
    @IBOutlet weak var searchCountryTextField: UITextField!
    var countryCodeObjDelegate : CountryCodeDelegate?
    
    class func instanceFromNib() -> CountryCodePopups{
        return UINib(nibName: "CountryCodePopups", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! CountryCodePopups
        
    }
    
    func setupCountryCodePopups(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView))
        tapGestureRecognizer.delegate = self
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
        
        if let path = Bundle.main.path(forResource: "countryCodes", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                let json = try JSONSerialization.jsonObject(with: jsonData) as? [[String:String]] ?? [[:]]
                debugPrint(json)
                tableDataCountry = json
                tableDataCountry.remove(at: 0)
                tableSearchDataCountry = tableDataCountry
                
            } catch {
                // handle error
                let nsError = error as NSError
                debugPrint("Error = ",nsError.localizedDescription)
            }
        }
        searchCountryTextField.setLeftPaddingPoints(20)
        searchCountryTextField.delegate = self
        countryListTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.TableCellId.kCountryCodePopupCellID)
        countryListTableView.delegate = self
        countryListTableView.dataSource = self
        searchCountryTextField.becomeFirstResponder()
        self.show(animated:true)
    }
}
    
    extension CountryCodePopups{
        func show(animated:Bool){
            
            self.backgroundView.alpha = 1
            self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
            UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)
            
            
            if animated {
                UIView.animate(withDuration: 0.33, animations: {
                    self.backgroundView.alpha = 1
                })
                
                UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: UIView.AnimationOptions(rawValue: 0), animations: {
                    self.dialogView.center = self.center
                    //self.dialogView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    debugPrint("Dialog Frame:",self.dialogView.frame)
                }, completion: { (completed) in
                    
                })
            }else{
                self.backgroundView.alpha = 1
                self.dialogView.center  = self.center
            }
            
            countryListTableView.reloadData()
        }
        
        func dismiss(animated:Bool){
            if animated {
                UIView.animate(withDuration: 0.33, animations: {
                    self.backgroundView.alpha = 0
                }, completion: { (completed) in
                    
                })
                UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIView.AnimationOptions(rawValue: 0), animations: {
                    self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
                }, completion: { (completed) in
                    self.removeFromSuperview()
                })
            }else{
                self.removeFromSuperview()
            }
            
        }
        
        @objc func didTappedOnBackgroundView(){
            dismiss(animated: true)
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            if touch.view!.isDescendant(of: self.dialogView){
                return false
            }
            else{
                return true
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if string.isEmpty
            {
                search = String(textField.text?.dropLast() ?? "")
            }
            else
            {
                search=textField.text!+string
            }
            
            debugPrint(search)
            
            let searchPredicate = NSPredicate(format: "SELF.name CONTAINS[c] %@", search)
            let arr = (tableDataCountry as NSArray).filtered(using: searchPredicate)
            
            debugPrint ("array = \(arr)")
            
            if arr.count > 0
            {
             tableSearchDataCountry.removeAll(keepingCapacity: true)
                tableSearchDataCountry = arr as? [[String : String]] ?? []
            }
            else
            {
                tableSearchDataCountry=tableDataCountry
            }
            
            countryListTableView.reloadData()
            return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        // MARK:- TableView Delegate & DataDource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return tableSearchDataCountry.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let countryCodeTableCell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kCountryCodePopupCellID)!
            
            countryCodeTableCell.imageView?.image = UIImage.init(named: "\(tableSearchDataCountry[indexPath.row]["code"] ?? "").png")
            countryCodeTableCell.textLabel?.text = "+\(tableSearchDataCountry[indexPath.row]["dial_code"] ?? "")    " + tableSearchDataCountry[indexPath.row][ApiKeyConstants.kDriverName]!
            
            countryCodeTableCell.textLabel?.font = UIFont(name: "Roboto-Light", size: 13.0)
            
            countryCodeTableCell.selectionStyle = .none
            
            return countryCodeTableCell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedDict = tableSearchDataCountry[indexPath.row]
            countryCodeObjDelegate?.selectedCountryCode(countryDetails: selectedDict)
            self.dismiss(animated: true)
        }
        
        // MARK:- Network Change Observer Methods-----
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
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */


