//
//  SignUpFormCollectionViewCell.swift
//  Facedrive
//
//  Created by DAT-Asset-115 on 1/18/19.
//  Copyright © 2019 DAT-Asset-115-DAPL. All rights reserved.
//

import UIKit
protocol KeyBoardCheckDelegate {
    func checkEmail(_ strted:Bool)
    
}
class SignUpFormCollectionViewCell: UICollectionViewCell ,UITextFieldDelegate,UIImagePickerControllerDelegate{
    
    @IBOutlet var btn_camera: UIButton!
    @IBOutlet var table_Signup: UITableView!
    @IBOutlet var img_profilePic: UIImageView!
    
}
