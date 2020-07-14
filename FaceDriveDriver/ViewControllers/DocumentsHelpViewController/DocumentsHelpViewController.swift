//
//  DocumentsHelpViewController.swift
//  Facedriver
//
//  Created by DAT-Asset-259 on 26/09/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit

class DocumentsHelpViewController: UIViewController {
    var documentsHelpDetails : [String:String] = [String:String]()
    @IBOutlet weak var documentsTypeTitleLabel: UILabel!
    @IBOutlet weak var documentsTypeDetailsLabel: UILabel!
    @IBOutlet weak var documentsImageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bankNumberLabel: UILabel!
    @IBOutlet weak var popupheightConstraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        let docsTag = documentsHelpDetails[ApiKeyConstants.kDocumentsTag] ?? ""
        self.initialLoad(docsTag: docsTag)
        // Do any additional setup after loading the view.
    }
    

    @IBAction func dismissButtonTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func initialLoad(docsTag : String)  {
        switch docsTag {
        case "0":
            documentsTypeTitleLabel.text = documentsHelpDetails[ApiKeyConstants.kTitle]
            documentsTypeDetailsLabel.text = Constants.AppAlertMessage.kDriverLicense
            bankNumberLabel.text = ""
            doneButton.setTitle("Done", for: .normal)
            documentsImageView.image = UIImage(named: "licenseFrontImage")
            popupheightConstraints.constant = 500
            break
            
        case "1":
            documentsTypeTitleLabel.text = documentsHelpDetails[ApiKeyConstants.kTitle]
            documentsTypeDetailsLabel.text = Constants.AppAlertMessage.kDriverLicense
            bankNumberLabel.text = ""
            doneButton.setTitle("Done", for: .normal)
            documentsImageView.image = UIImage(named: "licenseBackImage")
            popupheightConstraints.constant = 500
            break
            
        case "2":
            documentsTypeTitleLabel.text = documentsHelpDetails[ApiKeyConstants.kTitle]
            documentsTypeDetailsLabel.text = Constants.AppAlertMessage.kWorkEligibility
            bankNumberLabel.text = ""
            doneButton.setTitle("Done", for: .normal)
            documentsImageView.image = UIImage(named: "proofOfWork")
            popupheightConstraints.constant = 500
            break
            
        case "3":
            documentsTypeTitleLabel.text = documentsHelpDetails[ApiKeyConstants.kTitle]
            documentsTypeDetailsLabel.text = Constants.AppAlertMessage.kVehicleInsurance
            bankNumberLabel.text = ""
            doneButton.setTitle("Done", for: .normal)
            documentsImageView.image = UIImage(named: "vehicleInsurance")
            popupheightConstraints.constant = 500
            break
            
        case "4":
            documentsTypeTitleLabel.text = documentsHelpDetails[ApiKeyConstants.kTitle]
            documentsTypeDetailsLabel.text = Constants.AppAlertMessage.kVehicleRegistration
            bankNumberLabel.text = ""
            doneButton.setTitle("Done", for: .normal)
            documentsImageView.image = UIImage(named: "vehicleRegistration")
            popupheightConstraints.constant = 500
            break
            
        case "5":
            documentsTypeTitleLabel.text = documentsHelpDetails[ApiKeyConstants.kTitle]
            documentsTypeDetailsLabel.text = Constants.AppAlertMessage.kVehicleInspection
            bankNumberLabel.text = ""
            doneButton.setTitle("Done", for: .normal)
            documentsImageView.image = UIImage(named: "vehicleInspection")
            popupheightConstraints.constant = 500
            break
            
        case "6":
            documentsTypeTitleLabel.text = documentsHelpDetails[ApiKeyConstants.kTitle]
            documentsTypeDetailsLabel.text = ""
            bankNumberLabel.text = "Transit (Branch) Number."
            doneButton.setTitle("Done", for: .normal)
            documentsImageView.image = UIImage(named: "transitNumber")
            popupheightConstraints.constant = 350
            break
            
        case "7":
            documentsTypeTitleLabel.text = documentsHelpDetails[ApiKeyConstants.kTitle]
            documentsTypeDetailsLabel.text = ""
            bankNumberLabel.text = "Financial Institution Number."
            doneButton.setTitle("Done", for: .normal)
            documentsImageView.image = UIImage(named: "institutionNumber")
            popupheightConstraints.constant = 350
            break
            
        case "8":
            documentsTypeTitleLabel.text = documentsHelpDetails[ApiKeyConstants.kTitle]
            documentsTypeDetailsLabel.text = ""
            bankNumberLabel.text = "Account Number"
            doneButton.setTitle("Done", for: .normal)
            documentsImageView.image = UIImage(named: "accountNumber")
            popupheightConstraints.constant = 350
            break
            
        case "9":
            documentsTypeTitleLabel.text = documentsHelpDetails[ApiKeyConstants.kTitle]
            documentsTypeDetailsLabel.text = ""
            bankNumberLabel.text = "SIN Number"
            doneButton.setTitle("Done", for: .normal)
            documentsImageView.image = UIImage(named: "sinNumber")
            popupheightConstraints.constant = 350
            break
            
        default:
            break
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
