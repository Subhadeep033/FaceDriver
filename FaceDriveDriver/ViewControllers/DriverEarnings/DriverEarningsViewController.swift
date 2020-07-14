//
//  DriverEarningsViewController.swift
//  Facedriver
//
//  Created by DAT-Asset-259 on 12/11/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import WebKit

class DriverEarningsViewController: UIViewController,WKNavigationDelegate,WKUIDelegate/*WKScriptMessageHandler*/ {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var webContainerView: UIView!
    private var legalDetailsWebkitView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        
        let driverId = driverDetailsDict[ApiKeyConstants.kid] as? String ?? ""
        
        let legalLinkToOpen = "https://dev.apps.fdv2aws.com/apps/earning/index.html#/list/\(driverId)"
        
        let webConfiguration = WKWebViewConfiguration()
        
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.webContainerView.frame.size.width, height: self.webContainerView.frame.size.height))
        self.legalDetailsWebkitView = WKWebView (frame: customFrame , configuration: webConfiguration)
        self.legalDetailsWebkitView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.legalDetailsWebkitView.backgroundColor = UIColor.clear
        self.webContainerView.addSubview(legalDetailsWebkitView)
        legalDetailsWebkitView.navigationDelegate = self
        legalDetailsWebkitView.uiDelegate = self
        legalDetailsWebkitView.scrollView.alwaysBounceVertical = false
        legalDetailsWebkitView.load(URLRequest(url: URL(string: legalLinkToOpen)!))
        spinner.startAnimating()
        webContainerView.bringSubviewToFront(spinner)
        // Do any additional setup after loading the view.
    }
    
    // MARK:- WebKit Delegates
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
    }
    
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
//    {
//        if(message.name == "callbackHandler") {
//            print("Launch my Native Camera")
//        }
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
