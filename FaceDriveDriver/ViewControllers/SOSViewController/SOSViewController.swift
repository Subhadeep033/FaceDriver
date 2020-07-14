//
//  SOSViewController.swift
//  Facedriver
//
//  Created by DAT-Asset-259 on 16/08/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit

class SOSTableViewCell: UITableViewCell{
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var emergencyNumberLabel: UILabel!
    @IBOutlet weak var btnCall: UIButton!
}

class SOSViewController: UIViewController {
    var callback : ((String) -> Void)?
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var sosTableView: UITableView!
    private var sosDetailsArray = [[String:String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        // Do any additional setup after loading the view.
        dialogView.layer.cornerRadius = 20.0
        dialogView.clipsToBounds = true
        sosDetailsArray = [[ApiKeyConstants.kHeaderLabel : "Emergency Call",ApiKeyConstants.kContactNumber : "911"],[ApiKeyConstants.kHeaderLabel : "Help and support",ApiKeyConstants.kContactNumber : "1-888-300-2228"]]
        sosTableView.reloadData()
    }
    
    @IBAction func dismissPopupTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SOSViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return sosDetailsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return sosTableView.frame.height/2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sosCell : SOSTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kSOSCellId) as! SOSTableViewCell
        
        let sosDict = sosDetailsArray[indexPath.row]
        
        sosCell.headerLabel.text = sosDict[ApiKeyConstants.kHeaderLabel] ?? ""
        sosCell.emergencyNumberLabel.text = sosDict[ApiKeyConstants.kContactNumber] ?? ""
        
        sosCell.btnCall.layer.cornerRadius = 10.0
        sosCell.btnCall.clipsToBounds = true
        sosCell.btnCall.tag = indexPath.row
        sosCell.btnCall.addTarget(self, action: #selector(emergencyCallBtnTap(sender:)), for: .touchUpInside)
        
        return sosCell
    }
    
    @objc func emergencyCallBtnTap(sender:UIButton!) {
        let contactNumber = sosDetailsArray[sender.tag][ApiKeyConstants.kContactNumber] ?? ""
        self.callback?(contactNumber)
        self.dismiss(animated: true, completion: nil)
    }
}
