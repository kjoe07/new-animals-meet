//
//  user_register.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 09/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import ARSLineProgress

class RegisterViewController: UIViewController {
    var userData: UserModel!;
    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirm_password: UITextField!
    @IBOutlet var send: UIButton!
    @IBOutlet var connect: UIButton!
    
    @IBAction func goLogin(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func register(_ sender: AnyObject) {

        let email = self.email.text!
        let password = self.password.text!

        guard password == confirm_password.text else {
            alert.showAlertError(title: "Erreur", subTitle: "Vous avez saisi deux mots de passe différents")
            return
        }
        
        guard password.characters.count >= 8 else {
            alert.showAlertError(title: "Erreur", subTitle: "Le mot de passe est trop court (8 charactères minimum)")
            return
        }

        ARSLineProgress.show()
        UserModel.callForCreate(email: email, password: password)
            .then { App.instance.authenticate(email: email, password: password) }
            .then { _ in alert.showAlertSuccess(title: "Cool !", subTitle: "Enregistrement réussi") }
            .always { ARSLineProgress.hide() }
            .catch { err in alert.showAlertError(title: "Erreur d'inscription", subTitle: String(describing: err)) }
    }

    func initForm() {
        let radius: CGFloat = view.bounds.height * 0.07 * 0.5

        // init email
        UIKitViewUtils.setCornerRadius(sender: email, radius: radius)
        UIKitViewUtils.setBorderWidth(sender: email, width: 1.5, hexString: "#cccccc")
        
        // init password
        UIKitViewUtils.setCornerRadius(sender: password, radius: radius)
        UIKitViewUtils.setBorderWidth(sender: password, width: 1.5, hexString: "#cccccc")

        // init confirm_password
        UIKitViewUtils.setCornerRadius(sender: confirm_password, radius: radius)
        UIKitViewUtils.setBorderWidth(sender: confirm_password, width: 1.5, hexString: "#cccccc")
        
        // init send
        UIKitViewUtils.setCornerRadius(sender: send, radius: radius)

        
        // init connect
        UIKitViewUtils.setCornerRadius(sender: connect, radius: radius)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initForm()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userData = UserModel();
    }
}
