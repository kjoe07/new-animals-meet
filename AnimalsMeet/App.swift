//
//  App.swift
//
//
//  Created by gwendal lasson on 03/05/2017.
//
//

import SwiftyJSON
import Foundation
import SwiftLocation
import Alamofire
import PromiseKit
import Cereal

struct UserData {
   
   var selectedAnimal = 0
   var deviceToken: String?
   var accessToken: String!
   var expiry: Int!
   var client: String!
   var uid: String!
   
   init() {
   }
}


// UserData can be encoded/decoded
extension UserData: CerealType {
   
   init(decoder: CerealDecoder) throws {
      selectedAnimal = try decoder.decode(key: Keys.selectedAnimal)!
      deviceToken = try decoder.decode(key: Keys.deviceToken)
      accessToken = try decoder.decode(key: Keys.accessToken)
      expiry = try decoder.decode(key: Keys.expiry)
      client = try decoder.decode(key: Keys.client)
      uid = try decoder.decode(key: Keys.uid)
   }
   
   func encodeWithCereal( _ cereal: inout CerealEncoder) throws {
      try cereal.encode(selectedAnimal, forKey: Keys.selectedAnimal)
      try cereal.encode(deviceToken, forKey: Keys.deviceToken)
      try cereal.encode(accessToken, forKey: Keys.accessToken)
      try cereal.encode(expiry, forKey: Keys.expiry)
      try cereal.encode(client, forKey: Keys.client)
      try cereal.encode(uid, forKey: Keys.uid)
   }
   
   private struct Keys {
      static let selectedAnimal = "selectedAnimal"
      static let deviceToken = " deviceToken"
      static let accessToken = "accessToken"
      static let expiry = "expiry"
      static let client = "client"
      static let uid = "uid"
   }
}

class App {
   
   static let instance = App()
   var userModel: UserModel!
   var userData: UserData! {
      didSet {
         var encoder = CerealEncoder()
         try? encoder.encode(userData, forKey: "userData")
         let data = encoder.toData()
         let defaults = UserDefaults.standard
         defaults.set(data, forKey: "userData")
      }
   }
   var breeds: [BreedModel]!
   
   func loadUserData() {
      
      let defaults = UserDefaults.standard
      if let data = defaults.object(forKey: "userData") as? Data {
         let decoder = try? CerealDecoder(data: data)
         userData = try! decoder?.decodeCereal(key: "userData")
      } else {
         userData = UserData()
      }
   }
   
   init() {
      pingLocation()
      Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(pingLocation), userInfo: nil, repeats: true)
   }
   
   func requestForSignInPasswd(withUrl: String, parameters: Parameters) -> Promise<Void> {
      return Promise { (fulfill, reject) in
         let r = Alamofire.request(withUrl, method: .post, parameters: parameters)
            .validate()
            .responseJSON { response in
               switch response.result {
               case .success(let json):
                  let headers = response.response!.allHeaderFields
                  self.userData = UserData()
                  self.userData.accessToken = headers["access-token"].unsafelyUnwrapped as! String
                  self.userData.expiry = Int(headers["expiry"].unsafelyUnwrapped as! String)
                  self.userData.client = headers["client"].unsafelyUnwrapped as! String
                  
                  let data = JSON(json)["data"]
                  self.userData.uid = data["uid"].stringValue
                  fulfill()
               case .failure(let error):
                  alert.showAlertError(title: "Impossible de se connecter", subTitle: "Echec de l'authentification")
                  reject(error)
               }
         }
         print(r.debugDescription)
      }
   }
   
   func requestUserBreedsAndAnimals() -> Promise<Void> {
      return UserModel.getProfilUser() .then { userModel -> Void in
         print("retrieved user")
         self.userModel = userModel
      }.then { () -> Promise<Void> in
         print("will retrieve breeds")
         return Api.instance.get("/breed").then { json -> Void in
            print("retrieved breeds")
            self.breeds = json["breeds"].arrayValue.map { BreedModel(fromJSON: $0) }
         }
      }.then {
         print("will retrieve animals")
         return Api.instance.get("/animals/").then { json -> Void in
            print("retrieved animals")
            let items = json["myanimal"].arrayValue
            self.userModel.animals = items.map { AnimalModel(fromJSON: $0) }
			if self.userModel.animals?.count == 0{
				self.logout()
			}
			}
      }
   }
   
   func authenticate(email: String, password: String) -> Promise<Void> {
      
      return requestForSignInPasswd(withUrl: "\(Api.instance.serverUrl)/auth/sign_in", parameters: ["email": email, "password": password])
         .then { self.requestUserBreedsAndAnimals() }
   }
   
   func authenticate(facebookToken: String) -> Promise<Void> {
      return Api.instance.post("/auth/sessionProvider", withParams: ["provider": "facebook", "token": facebookToken])
         .then { JSON in
            let result = JSON["result"]
            self.userData = UserData()
            self.userData.accessToken = result["access-token"].stringValue
            self.userData.expiry = Int(result["expiry"].stringValue)
            self.userData.uid = result["uid"].stringValue
            self.userData.client = result["client"].stringValue
			print("client: \(self.userData.client)")
			print("UID: \(self.userData.uid)")
			print("token: \(self.userData.accessToken)")
            return self.requestUserBreedsAndAnimals()
      }
   }
   
   public static let showRequestFailure = { (_: Error) in
      alert.showAlertError(title: "Action échouée", subTitle: "Vérifiez votre connexion ou réessayez plus tard")
   }
   
   public static func getImageUrlFromMediaId(_ id: Int) -> URL {
      return URL(string: "\(Api.instance.serverUrl)/media/\(id)")!
   }
   
   public func logout() {
      App.instance.userData.accessToken = nil
      UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "auth_view")
   }
   
   public func getSelectedAnimal() -> AnimalModel {
      return userModel.animals![userData.selectedAnimal]
   }
   
   @objc func pingLocation() {
      
      _ = Location.getLocation(accuracy: .city, frequency: .oneShot, success: { (_, location) in
         
         guard App.instance.userData.deviceToken != nil else {
            print("cannot ping, no device token")
            return
         }
         
         let lat = location.coordinate.latitude.description
         let long = location.coordinate.longitude.description
         
         Api.instance.post("/ping", withParams: [
            "ping[latitude]": lat,
            "ping[longitude]": long,
            "ping[device_token]": App.instance.userData.deviceToken!
            ])
            .catch { err in
               print("ping failed \(err)")
         }
      }, error: { (_, _, err) in
         print("ping error \(err)")
      })
   }
   
}
