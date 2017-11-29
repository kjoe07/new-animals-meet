//
//  NotificationTableViewCell.swift
//  AnimalsMeet
//
//  Created by Adrien Morel on 05/12/2016.
//  Copyright © 2016 AnimalsMeet. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var luLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var notifText: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconNotif: UIImageView!
    
    private let style = "<meta charset=\"UTF-8\"><style>* { color: #777777; font-family: verdana; font-size: 12; }</style>"
    
    func setNotificationContent(from whoFrom: String, action code: Int) {
        
        let actionText: String!
        
        switch code {
        case 0:
            actionText = "a aimé votre photo" //le gusta su foto
            iconNotif.image = UIImage(named: "heart_icon_round")
            
        case 1:
            actionText = "vous a envoyé un message" //te envió un mensaje
            iconNotif.image = UIImage(named: "chat")

        case 2:
            actionText = "a aimé votre profil" //le gustó su perfil
            iconNotif.image = UIImage(named: "heart_icon_round")
        case 3:
            actionText = "Il a commencé une Balade" //le gustó su perfil
            iconNotif.image = UIImage(named: "chat")
        default:
            actionText = "[...]"
        }
        print("whoForm \(whoFrom)")
        setHtml("\(style)<b>\(whoFrom)</b> \(actionText!)")
    }
    
    func setHtml(_ html: String) {
        let html = "\(style) \(html)"
        
        do {
            let attributed = try NSAttributedString(data:html.data(using: String.Encoding.utf8, allowLossyConversion: true
                )!, options: [
                    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                    ], documentAttributes: nil)
            notifText.attributedText = attributed
        } catch {
            notifText.text = html
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        UIKitViewUtils.setCornerRadius(sender: profilePic, radius: profilePic.bounds.width / 2)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
