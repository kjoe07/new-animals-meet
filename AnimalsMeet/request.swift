//
//  request.swift
//  vasoking
//
//  Created by kjoe on 5/9/17.
//  Copyright © 2017 Kjoe Inc. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
class request  {    
    func request(_ endpoint: String, withParams params: Parameters, method: HTTPMethod, encoding: ParameterEncoding? = nil,completion: @escaping ((_ data: JSON?,_ error: String?) -> Void)) {
           //let constants = contantes()
        var headers = HTTPHeaders()
        
        if let uid = App.instance.userData.uid {
            headers["uid"] = uid
        }
        if let token = App.instance.userData.accessToken {
            headers["access-token"] = token
        }
        if let client = App.instance.userData.client {
            headers["client"] = client
        }
        if let expiry = App.instance.userData.expiry {
            headers["expiry"] = String(expiry)
        }
        if let deviceToken = App.instance.userData.deviceToken {
            headers["DeviceToken"] = deviceToken
        }
        headers["token-type"] = "Bearer"
        
        var encoding = encoding

            encoding = URLEncoding.default
            let c = Alamofire.request(Api.instance.serverUrl  + endpoint, method: method, parameters: params, encoding: encoding!, headers: headers)
                //.validate()
                .responseJSON() { response in
                    print(response)
                    switch response.result {
                    case .success(let json):
                        print(JSON(json))
                        let data = JSON(json)
                        completion(data,nil)
                    case .failure(let error):
                        completion(nil,response.error?.localizedDescription)
                        print(error)
                    }
            }
            print(c.debugDescription)       
    }
    /*func post(_ endpoint: String, withParams params: Parameters = [:],completion: @escaping ((_ data: JSON) -> Void)) {
        request(endpoint, withParams: params, method: .post, completion: { data in
            print("passing data from post to model")
            print(data)
            completion(data)
        }
    )}
    
    func delete(_ endpoint: String, withParams params: Parameters = [:]){
        return request(endpoint, withParams: params, method: .delete)
    }
    
    func put(_ endpoint: String, withParams params: Parameters = [:]){
        return request(endpoint, withParams: params, method: .put)
    }
    
    func get(_ endpoint: String, withParams params: Parameters = [:]){
        return request(endpoint, withParams: params, method: .get)
    }
    */

}
