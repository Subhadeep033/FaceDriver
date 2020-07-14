//
//  LegalDetailsViewController.swift
//  FaceDriveDriver
//
//  Created by DAT-Asset-259 on 24/05/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import WebKit

class LegalDetailsViewController: UIViewController,WKNavigationDelegate,WKUIDelegate {
    
    var legalLinkToOpen = String()
    var headerTitle = String()
    
    @IBOutlet weak var webContainerView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    private var legalDetailsWebkitView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        titleLabel.text = headerTitle
        let webConfiguration = WKWebViewConfiguration()
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.webContainerView.frame.size.width, height: self.webContainerView.frame.size.height))
        self.legalDetailsWebkitView = WKWebView (frame: customFrame , configuration: webConfiguration)
        self.legalDetailsWebkitView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.legalDetailsWebkitView.backgroundColor = UIColor.clear
        self.webContainerView.addSubview(legalDetailsWebkitView)
        legalDetailsWebkitView.navigationDelegate = self
        legalDetailsWebkitView.uiDelegate = self
        
        legalDetailsWebkitView.load(URLRequest(url: URL(string: legalLinkToOpen)!))
        spinner.startAnimating()
        webContainerView.bringSubviewToFront(spinner)
    }
    

    @IBAction func navigationBackButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:- WebKit Delegates
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
    }
}
