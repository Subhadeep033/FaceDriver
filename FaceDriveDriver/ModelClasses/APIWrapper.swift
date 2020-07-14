//
//  APIWrapper.swift
//  AKSwiftSlideMenu
//
//  Created by Subhadeep Chakraborty on 10/11/17.
//  Copyright © 2017 Shubhayan All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class APIWrapper: NSObject {
      //MARK: GET Method
    class func requestGETImage(_ strURL: URL,headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        Alamofire.request(strURL, method: .get, headers: headers).responseJSON { (responseObject) -> Void in
            debugPrint(responseObject)
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
            let apiTime = (responseObject.timeline.totalDuration * 1000)
            let timestamp = Utility.currentTimeInMiliseconds()
            
            let apiDict : [String:AnyObject] = ["api" : strURL as AnyObject,"d" : apiTime as AnyObject,"time" : timestamp as AnyObject, "sessionId" : token as AnyObject]
            Utility.createAPIResponseFile(dict:apiDict)
            if responseObject.result.isSuccess {
                let json = JSON(responseObject.result.value!)
                debugPrint("New Json",json)
                success(json)
            }
            else{
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    class func requestGETURL(_ strURL: String,headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        Alamofire.request(strURL, method: .get, headers: headers).responseJSON { (responseObject) -> Void in
            debugPrint(responseObject)
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
            let apiTime = (responseObject.timeline.totalDuration * 1000)
            let timestamp = Utility.currentTimeInMiliseconds()
            
            let apiDict : [String:AnyObject] = ["api" : strURL as AnyObject,"d" : apiTime as AnyObject,"time" : timestamp as AnyObject, "sessionId" : token as AnyObject]
            Utility.createAPIResponseFile(dict:apiDict)
            if responseObject.result.isSuccess {
//                let json = JSON(data: responseObject.data!)
                let json = JSON(responseObject.result.value!)
                debugPrint("New Json",json)
                /*if let userName = json[0]["title"]["rendered"].string {
                    //Now you got your value
                    debugPrint("New title",userName)
                }*/
//                let resJson = JSON(responseObject.result.value!)
                success(json)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    //MARK: POST Method
    class func requestPOSTURL(_ strURL : String, params : Parameters?, headers : HTTPHeaders?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        debugPrint("Param",params as Any)
         Alamofire.request(strURL, method: .post, parameters: params, encoding: JSONEncoding.prettyPrinted, headers: headers).responseJSON{(responseObject) -> Void in
            debugPrint(responseObject)
            
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
            let apiTime = (responseObject.timeline.totalDuration * 1000)
            let timestamp = Utility.currentTimeInMiliseconds()
            
            let apiDict : [String:AnyObject] = ["api" : strURL as AnyObject,"d" : apiTime as AnyObject,"time" : timestamp as AnyObject, "sessionId" : token as AnyObject]
            Utility.createAPIResponseFile(dict:apiDict)
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                debugPrint("RESPONSE FROM WRAPPER:---------------------",resJson)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    //MARK: PUT Method
    class func requestPUTURL(_ strURL : String, params : [String : AnyObject]?, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        debugPrint("Param",params!)
        Alamofire.request(strURL, method: .put, parameters: params, encoding: JSONEncoding.prettyPrinted, headers: headers).responseJSON{(responseObject) -> Void in
            debugPrint(responseObject)
            let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
            let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
            let apiTime = (responseObject.timeline.totalDuration * 1000)
            let timestamp = Utility.currentTimeInMiliseconds()
            
            let apiDict : [String:AnyObject] = ["api" : strURL as AnyObject,"d" : apiTime as AnyObject,"time" : timestamp as AnyObject, "sessionId" : token as AnyObject]
            Utility.createAPIResponseFile(dict:apiDict)
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                debugPrint("RESPONSE FROM WRAPPER:---------------------",resJson)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    class func requestMultipartWith (_ endUrl: String, imageData: Data?, parameters: [String : Any],headers:[String:String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        

        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "image", fileName: "image.png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: endUrl, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { responseObject in
                    debugPrint("Succesfully uploaded")
                    let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                    let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
                    let apiTime = (responseObject.timeline.totalDuration * 1000)
                    let timestamp = Utility.currentTimeInMiliseconds()
                    
                    let apiDict : [String:AnyObject] = ["api" : endUrl as AnyObject,"d" : apiTime as AnyObject,"time" : timestamp as AnyObject, "sessionId" : token as AnyObject]
                    Utility.createAPIResponseFile(dict:apiDict)
                    if responseObject.result.isSuccess {
                        let resJson = JSON(responseObject.result.value!)
                        debugPrint("RESPONSE FROM WRAPPER:---------------------",resJson)
                        success(resJson)
                    }
                    if responseObject.result.isFailure {
                        let error : Error = responseObject.result.error!
                        failure(error)
                    }
                }
            case .failure(let error):
                debugPrint("Error in upload: \(error.localizedDescription)")
               
            }
        }
    }
    
    class func requestPUTMultipartWith (_ endUrl: String, imageData: Data?, parameters: [String : Any],headers:[String:String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        
        
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "image", fileName: "image.png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: endUrl, method: .put, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { responseObject in
                    debugPrint("Succesfully uploaded")
                    let driverDetailsDict = Utility.retrieveDictionarybyKey(ApiKeyConstants.kUserDefaults.kDriverDetails) ?? [:]
                    let token = driverDetailsDict[ApiKeyConstants.kToken] as? String ?? ""
                    let apiTime = (responseObject.timeline.totalDuration * 1000)
                    let timestamp = Utility.currentTimeInMiliseconds()
                    
                    let apiDict : [String:AnyObject] = ["api" : endUrl as AnyObject,"d" : apiTime as AnyObject,"time" : timestamp as AnyObject, "sessionId" : token as AnyObject]
                    Utility.createAPIResponseFile(dict:apiDict)
                    if responseObject.result.isSuccess {
                        let resJson = JSON(responseObject.result.value!)
                        debugPrint("RESPONSE FROM WRAPPER:---------------------",resJson)
                        success(resJson)
                    }
                    if responseObject.result.isFailure {
                        let error : Error = responseObject.result.error!
                        failure(error)
                    }
                }
            case .failure(let error):
                debugPrint("Error in upload: \(error.localizedDescription)")
                
            }
        }
    }
}
