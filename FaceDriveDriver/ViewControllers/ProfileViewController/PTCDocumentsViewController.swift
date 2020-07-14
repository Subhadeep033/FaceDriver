//
//  PTCDocumentsViewController.swift
//  Facedriver
//
//  Created by DAT-Asset-259 on 16/07/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
class PTCDocumentsViewController: UIViewController {

    @IBOutlet weak var tableViewPTCDocument: UITableView!
    var selectedImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.StoryboardSegueConstants.kEnlargeSegue{
            let enlargeViewControllerObj = segue.destination as! EnlargeImageViewController
            enlargeViewControllerObj.enlargeImage = selectedImage
        }
    }

}

//MARK:- TableView Delegate & DataSource -----
extension PTCDocumentsViewController : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 0.28
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ptcDocumentCell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCellId.kPTCDocumentCellId) as! PTCDocumentCell
        ptcDocumentCell.labelPTCDocument.font = UIFont(name: "Roboto-Medium", size: 17.0)
        ptcDocumentCell.labelPTCDocument.textColor = Constants.AppColour.kAppBlackColor
        ptcDocumentCell.imageViewPTCDocument.tag = indexPath.row
        let userDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
        var urlSting = String()
        
        if indexPath.row == 0{
            ptcDocumentCell.labelPTCDocument.text = "PTC Number"
            urlSting = userDict["ptcIcon"] as? String ?? ""
            let url = URL(string: urlSting)
            if urlSting.count == 0{
                ptcDocumentCell.imageViewPTCDocument.image = UIImage(named: ApiKeyConstants.ImageType.kDocsIcon)
                ptcDocumentCell.imageViewPTCDocument.contentMode = .center
            }else{
                ptcDocumentCell.imageViewPTCDocument.kf.indicatorType = .activity
                let authToken = userDict[ApiKeyConstants.kToken] as? String ?? ""
                
                let token = "Bearer " + authToken
                let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
                
                Alamofire.request(url!, method: .get, headers: dictHeaderParams).responseJSON { (responseObject) -> Void in
                    debugPrint(responseObject)
                    if responseObject.data != nil{
                        ptcDocumentCell.imageViewPTCDocument.image = UIImage(data: responseObject.data!)
                        ptcDocumentCell.imageViewPTCDocument.contentMode = .scaleAspectFit
                    }
                    else{
                        ptcDocumentCell.imageViewPTCDocument.image = UIImage(named: "")
                    }
                }
            }
        }else {
            
            ptcDocumentCell.labelPTCDocument.text = "Facedrive Insurance"
            urlSting = userDict["pinkslipimage"] as? String ?? ""
            let url = URL(string: urlSting)
            if urlSting.count == 0{
                ptcDocumentCell.imageViewPTCDocument.image = UIImage(named: ApiKeyConstants.ImageType.kDocsIcon)
                ptcDocumentCell.imageViewPTCDocument.contentMode = .center
            }else{
                ptcDocumentCell.imageViewPTCDocument.kf.indicatorType = .activity
                let authToken = userDict[ApiKeyConstants.kToken] as? String ?? ""
                
                let token = "Bearer " + authToken
                let dictHeaderParams:[String : String] = ["Content-Type":"application/json","Authorization": token]
                
                Alamofire.request(url!, method: .get, headers: dictHeaderParams).responseJSON { (responseObject) -> Void in
                    debugPrint(responseObject)
                    if responseObject.data != nil{
                        ptcDocumentCell.imageViewPTCDocument.image = UIImage(data: responseObject.data!)
                        ptcDocumentCell.imageViewPTCDocument.contentMode = .scaleAspectFit
                    }
                    else{
                        ptcDocumentCell.imageViewPTCDocument.image = UIImage(named: "")
                    }
                }
            }
        }
        
        return ptcDocumentCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let docsCell = self.tableViewPTCDocument.cellForRow(at: indexPath) as! PTCDocumentCell

        if !((docsCell.imageViewPTCDocument.image!.isEqual(UIImage(named: ApiKeyConstants.ImageType.kDocsIcon)))){
            let showAlert = UIAlertController.init(title: Constants.AppAlertMessage.kAlertTitle, message: "", preferredStyle: .actionSheet)
            showAlert.view.tintColor = Constants.AppColour.kAppGreenColor
            let view = UIAlertAction.init(title: Constants.AppAlertAction.kViewImage, style: .default) { (action) in
                
                self.selectedImage = docsCell.imageViewPTCDocument.image ?? UIImage()
                self.performSegue(withIdentifier: Constants.StoryboardSegueConstants.kEnlargeSegue, sender: nil)
            }
            
            let cancel = UIAlertAction.init(title: Constants.AppAlertAction.kNo, style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            showAlert.addAction(cancel)
            showAlert.addAction(view)
            self.present(showAlert, animated: true, completion: nil)
        }
    }
}
