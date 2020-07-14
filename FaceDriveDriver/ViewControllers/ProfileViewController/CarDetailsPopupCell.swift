//
//  CarDetailsPopupCell.swift
//  FaceDriveDriver
//
//  Created by Rajiv Ghosh on 4/25/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit


class CarDetailsPopupCell: UITableViewCell {

    var completionBlock: Constants.TextFieldCompletionBlock?
    var completionBlockShouldChange: Constants.TextFieldShouldChangeCompletionBlock?
    @IBOutlet weak var txtFldInfo: ACFloatingTextfield!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpTextFieldDelegate() {
        self.txtFldInfo.delegate = self
    }

}

class CarDetailsInfoCell: UITableViewCell {
    
    var completionBlock: Constants.TextFieldCompletionBlock?
    var completionBlockShouldChange: Constants.TextFieldShouldChangeCompletionBlock?
    @IBOutlet weak var txtFldInfo: ACFloatingTextfield!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK:- Set Keyboard Type ------
    func setupTextFieldKeyboardType(id:String) {
        switch id {
        case "firstname" ,"lastname" , "city":
            self.txtFldInfo.autocapitalizationType = .words
            self.txtFldInfo.keyboardType = UIKeyboardType.asciiCapable
            self.txtFldInfo.isSecureTextEntry = false
            
        case "email":
            self.txtFldInfo.keyboardType = UIKeyboardType.emailAddress
            self.txtFldInfo.isSecureTextEntry = false
            
        case "password":
            self.txtFldInfo.keyboardType = UIKeyboardType.default
            self.txtFldInfo.isSecureTextEntry = true
            
        default:
            self.txtFldInfo.keyboardType = UIKeyboardType.asciiCapable
            self.txtFldInfo.isSecureTextEntry = false
        }
        self.txtFldInfo.autocorrectionType = .no
    }
    
    func setUpTextFieldDelegate() {
        self.txtFldInfo.delegate = self
    }
    
}

//MARK:- TextField Delegate ----
extension CarDetailsInfoCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {    //delegate method
        if completionBlock!(textField,.textFieldShouldBeginEditing) != nil {
            return completionBlock!(textField,.textFieldShouldBeginEditing)!
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        _ = completionBlock!(textField,.textFieldDidBeginEditing)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        
        if completionBlock!(textField,.textFieldShouldReturn) != nil {
            return completionBlock!(textField,.textFieldShouldReturn)!
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(range.location == 0) {
            if (string == " ") {
                return false
            }
        }
        guard let _ = completionBlockShouldChange else { return true }
        var txt: String = ""
        if let textString =  textField.text as NSString? {
            txt = (textString.replacingCharacters(in: range, with: string) as NSString) as String
        }
        
        if completionBlockShouldChange!(textField, txt) != nil {
            return completionBlockShouldChange!(textField, txt)!
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        _ = completionBlock!(textField,.textFieldDidEndEditing)
    }
}

//MARK:- UITextFieldDelegate Methods ------
extension CarDetailsPopupCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if completionBlock!(textField,.textFieldShouldBeginEditing) != nil {
            return completionBlock!(textField,.textFieldShouldBeginEditing)!
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        _ = completionBlock!(textField,.textFieldDidBeginEditing)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        if completionBlock!(textField,.textFieldShouldReturn) != nil {
            return completionBlock!(textField,.textFieldShouldReturn)!
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(range.location == 0) {
            if (string == " ") {
                return false
            }
        }
        
        guard let _ = completionBlockShouldChange else { return true }
        var txt: String = ""
        if let textString =  textField.text as NSString? {
            txt = (textString.replacingCharacters(in: range, with: string) as NSString) as String
        }
        
        if completionBlockShouldChange!(textField, txt) != nil {
            return completionBlockShouldChange!(textField, txt)!
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        _ = completionBlock!(textField,.textFieldDidEndEditing)
    }
}


class CarDetailsTextFieldCell: UITableViewCell {
    
    var completionBlock: Constants.TextFieldCompletionBlock?
    var completionBlockShouldChange: Constants.TextFieldShouldChangeCompletionBlock?
    @IBOutlet weak var txtFldInfo: ACFloatingTextfield!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK:- Set Keyboard Type ------
    func setupTextFieldKeyboardType(id:String) {
        switch id {
        case "firstname" ,"lastname" , "city":
            self.txtFldInfo.autocapitalizationType = .words
            self.txtFldInfo.keyboardType = UIKeyboardType.asciiCapable
            self.txtFldInfo.isSecureTextEntry = false
            
        case "email":
            self.txtFldInfo.keyboardType = UIKeyboardType.emailAddress
            self.txtFldInfo.isSecureTextEntry = false
            
        case "password":
            self.txtFldInfo.keyboardType = UIKeyboardType.default
            self.txtFldInfo.isSecureTextEntry = true
            
        default:
            self.txtFldInfo.keyboardType = UIKeyboardType.asciiCapable
            self.txtFldInfo.isSecureTextEntry = false
        }
        self.txtFldInfo.autocorrectionType = .no
    }
    
    func setUpTextFieldDelegate() {
        self.txtFldInfo.delegate = self
    }
    
}

//MARK:- TextField Delegate ----
extension CarDetailsTextFieldCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {    //delegate method
        if completionBlock!(textField,.textFieldShouldBeginEditing) != nil {
            return completionBlock!(textField,.textFieldShouldBeginEditing)!
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        _ = completionBlock!(textField,.textFieldDidBeginEditing)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        
        if completionBlock!(textField,.textFieldShouldReturn) != nil {
            return completionBlock!(textField,.textFieldShouldReturn)!
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(range.location == 0) {
            if (string == " ") {
                return false
            }
        }
        guard let _ = completionBlockShouldChange else { return true }
        var txt: String = ""
        if let textString =  textField.text as NSString? {
            txt = (textString.replacingCharacters(in: range, with: string) as NSString) as String
        }
        
        if completionBlockShouldChange!(textField, txt) != nil {
            return completionBlockShouldChange!(textField, txt)!
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        _ = completionBlock!(textField,.textFieldDidEndEditing)
    }
}

class CarDetailsDocumantCell: UITableViewCell {
    
    @IBOutlet weak var imgDrivingLicence: UIImageView!
    @IBOutlet weak var btnDrivingLicence: UIButton!
    @IBOutlet weak var imgSeperator: UIImageView!
    @IBOutlet weak var lblDrivingLicence: UILabel!
    @IBOutlet weak var btnInfo: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


class SeperatorCell: UITableViewCell {
    
    // @IBOutlet weak var passengerSeatTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


class CarImageUploadCell: UITableViewCell {
    
    @IBOutlet weak var btnFront: UIButton!
    @IBOutlet weak var btnRear: UIButton!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var imgFront: UIImageView!
    @IBOutlet weak var imgRear: UIImageView!
    @IBOutlet weak var imgRight: UIImageView!
    @IBOutlet weak var imgLeft: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


