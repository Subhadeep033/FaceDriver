//
//  MapInWebViewController.swift
//  FaceDriveDriver
//
//  Created by DAT-Asset-259 on 22/05/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import WebKit

class MapInWebViewController: UIViewController,WKNavigationDelegate,WKUIDelegate{
    
    var strTripStatus = String()
    var mapWebView: WKWebView!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        let webConfiguration = WKWebViewConfiguration()
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.containerView.frame.size.width, height: self.containerView.frame.size.height))
        self.mapWebView = WKWebView (frame: customFrame , configuration: webConfiguration)
        self.mapWebView.translatesAutoresizingMaskIntoConstraints = false
        self.mapWebView.backgroundColor = UIColor.clear
        self.containerView.addSubview(mapWebView)
        mapWebView.navigationDelegate = self
        mapWebView.uiDelegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if Utility.isEqualtoString(strTripStatus, ApiKeyConstants.kAccepted){
            mapWebView.load(NSURLRequest(url: NSURL(string: "http://maps.google.com/maps?saddr=" + appDelegate.lattitude + "," + appDelegate.longitude + "&daddr=" + appDelegate.pickUpLattitude + "," + appDelegate.pickUpLongitude)! as URL) as URLRequest)
        }
        else{
            debugPrint(appDelegate.endTriplattitude,appDelegate.endTriplongitude)
            mapWebView.load(NSURLRequest(url: NSURL(string: "http://maps.google.com/maps?saddr=" + appDelegate.pickUpLattitude + "," + appDelegate.pickUpLongitude + "&daddr=" + appDelegate.endTriplattitude + "," + appDelegate.endTriplongitude)! as URL) as URLRequest)
        }
        // Do any additional setup after loading the view.
    }
    
    // MARK:- Back Button Action-----
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
