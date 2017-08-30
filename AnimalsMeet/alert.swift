//
//  U_Alert.swift
//  AnimalsMeet
//
//  Created by Sacha IFRAH on 04/10/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import Foundation
import SwiftMessages


class alert {
   
   static func showAlertSuccess(title: String, subTitle: String)
   {
      let view = MessageView.viewFromNib(layout: .CardView)
      view.configureTheme(.success)
      view.configureDropShadow()
      
      let iconText = ["🐶"].sm_random()!
      view.configureContent(title: title, body: subTitle, iconText: iconText)
      view.button?.isHidden = true
      SwiftMessages.show(view: view)
   }
   
   static func showAlertError(title: String, subTitle: String)
   {
      let view = MessageView.viewFromNib(layout: .CardView)
      view.configureTheme(.error)
      view.configureDropShadow()
      
      let iconText = ["🐶"].sm_random()!
      view.configureContent(title: title, body: subTitle, iconText: iconText)
      view.button?.isHidden = true
      SwiftMessages.show(view: view)
   }
   
   static func showAlertWarning(title: String, subTitle: String)
   {
      let view = MessageView.viewFromNib(layout: .CardView)
      view.configureTheme(.warning)
      view.configureDropShadow()
      
      let iconText = ["😧"].sm_random()!
      view.configureContent(title: title, body: subTitle, iconText: iconText)
      
      view.button?.isHidden = true
      SwiftMessages.show(view: view)
   }
   
   static func showAlertInfo(title: String, subTitle: String)
   {
      let view = MessageView.viewFromNib(layout: .CardView)
      view.configureTheme(.info)
      view.configureDropShadow()
      
      let iconText = ["🙂"].sm_random()!
      view.configureContent(title: title, body: subTitle, iconText: iconText)
      view.button?.isHidden = true
      SwiftMessages.show(view: view)
   }
   
   static func showProgressAlert(title: String, subTitle: String) {
      let view = MessageView.viewFromNib(layout: .CardView)
      view.configureTheme(.info)
      view.configureDropShadow()
      view.configureContent(title: title, body: subTitle, iconText: "🙂")
      // TODO: add support for canceling the operation
      view.button?.isHidden = true
      var config = SwiftMessages.defaultConfig
      config.presentationContext = .window(windowLevel: UIWindowLevelAlert)
      
      config.duration = .indefinite(delay: 1, minimum: 1)
      config.presentationStyle = .top
      config.dimMode = .gray(interactive: false)
      config.interactiveHide = false
      SwiftMessages.show(config: config, view: view)
   }
   
   static func showWaiting(currentView: UIViewController) -> UIAlertController
   {
      let alertController = UIAlertController(title: nil, message: "\n\n\n\n", preferredStyle: UIAlertControllerStyle.alert)
      
      let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
      
      spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
      spinnerIndicator.color = UIColor.black
      spinnerIndicator.startAnimating()
      
      alertController.view.addSubview(spinnerIndicator)
      currentView.present(alertController, animated: true, completion: nil)
      return alertController
   }
}


