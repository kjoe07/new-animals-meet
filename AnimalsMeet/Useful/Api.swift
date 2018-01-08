//
//  Api.swift
//  app
//
//  Created by Adrien morel on 25/02/2017.
//  Copyright © 2017 ZiggTime. All rights reserved.
//

import Foundation
import Contacts
import SwiftyJSON
import PromiseKit
import Alamofire

class Api {
    
    
    static let instance = Api()
    
    public var authServerUrl = ""
    public var serverUrl = ""
    
    init() {
        
        if ProcessInfo.processInfo.environment["ENV"] == "DEBUG" {
            
            //serverUrl = "http://193.70.42.87:4001"
            serverUrl = "http://localhost:3000"
            authServerUrl = "http://193.70.42.87:4000"
        }
    }
    
    class BackendError: Error {
        let json: JSON
        
        init(_ json: JSON) {
            self.json = json
        }
    }
    
    func request(_ endpoint: String, withParams params: Parameters, method: HTTPMethod, encoding: ParameterEncoding? = nil) -> Promise<JSON> {
        
        return Promise { fulfill, reject in
            
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
            
            /*
            if encoding == nil {
                encoding = method == .get ? URLEncoding.default : JSONEncoding.default
            }
 */
            encoding = URLEncoding.default
            
			_ = Alamofire.request(Api.instance.serverUrl + endpoint, method: method, parameters: params, encoding: encoding!, headers: headers)
                .validate()
                .responseJSON() { response in
                   print("la respuesta de: \(Api.instance.serverUrl)\(endpoint):")
					print(response)
                    switch response.result {
                    case .success(let json):
                        fulfill(JSON(json))
                    case .failure(let error):
						if error._code == NSURLErrorTimedOut {
							//HANDLE TIMEOUT HERE
							reject(error)
						}else{
							if let err = error as? AFError {
								if err.isResponseSerializationError {
									fulfill(JSON.null)
								} else {
									reject(error)
								}
							}
						}
                    }
            }
           // print(c.debugDescription)
        }
    }
    
    func post(_ endpoint: String, withParams params: Parameters = [:]) -> Promise<JSON> {
        return request(endpoint, withParams: params, method: .post)
    }
    
    func delete(_ endpoint: String, withParams params: Parameters = [:]) -> Promise<JSON> {
        return request(endpoint, withParams: params, method: .delete)
    }
    
    func put(_ endpoint: String, withParams params: Parameters = [:]) -> Promise<JSON> {
        return request(endpoint, withParams: params, method: .put)
    }
    
    func get(_ endpoint: String, withParams params: Parameters = [:]) -> Promise<JSON> {
        return request(endpoint, withParams: params, method: .get)
    }
    
    func upload(_ endpoint: String, data: Data, contentType: String) -> Promise<()> {
        
        return Promise { fulfill, reject in
            let c = Alamofire.upload(data, to: serverUrl + endpoint, method: .put, headers: ["Content-Type": contentType])
                .validate()
                .responseString { response in
                    switch response.result {
                    case .success:
                        fulfill()
                    case .failure(let err):
                        print(String(data: response.data!, encoding: .utf8) ?? "nil")
                        reject(err)
                    }
            }
            print(c.debugDescription)
        }
    }
    
    static func Upload(_ url: String, data: Data, contentType: String) -> Promise<()> {
        let instance = Api()
        instance.serverUrl = url
        return instance.upload("", data: data, contentType: contentType)
    }
}
