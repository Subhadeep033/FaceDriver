//
//  EnlargeImageViewController.swift
//  FaceDriveDriver
//
//  Created by Subhadeep Chakraborty on 05/03/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Reachability


class EnlargeImageViewController: UIViewController {
    var enlargeImage = UIImage()
    @IBOutlet weak var enlargeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        enlargeImageView.image = enlargeImage
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissViewButtonTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
