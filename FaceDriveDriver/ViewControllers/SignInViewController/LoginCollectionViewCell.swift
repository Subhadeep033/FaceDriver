//
//  LoginCollectionViewCell.swift
//  Facedriver
//
//  Created by Subhadeep Chakraborty on 1/14/19.
//  Copyright © 2019 DAT-Asset-115-DAPL. All rights reserved.
//

import UIKit
protocol EmailPassCheckDelegate {
    func checkEmail(_ valid:Bool)
    func checkPassword(_ valid:Bool)
}
class LoginCollectionViewCell: UICollectionViewCell,UITextFieldDelegate {
    var delegate: EmailPassCheckDelegate?
    @IBOutlet var txtFld_password: UITextField!
    @IBOutlet var txtFld_email: UITextField!
    
    @IBOutlet var btn_forgotPassword: UIButton!
    @IBOutlet var btn_eyeOpenClose: UIButton!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txtFld_email {
          if Utility.IsEmtyString(txtFld_email.text) || !Utility.isValidEmail(testStr: txtFld_email.text!)
          {
            delegate?.checkEmail(false)
          }else
          {
            delegate?.checkEmail(true)
            txtFld_email.resignFirstResponder()
            txtFld_password.becomeFirstResponder()
          }
        }else if textField == txtFld_password
            {
                if Utility.IsEmtyString(txtFld_password.text) || txtFld_password.text?.count ?? 0 < 5
                {
                    delegate?.checkPassword(false)
                }else
                {
                    delegate?.checkPassword(true)
                    txtFld_password.resignFirstResponder()
                }
            }
        
        return true
    }
}
