//
//  CommentTableViewCell.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 02/05/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var commentContent: UITextView!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var like: UILabel!
    @IBOutlet weak var answer: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var nickname: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePic.rounded()
        commentContent.textContainer.lineFragmentPadding = 0
    }
    
    func configure(comment: CommentModel) {
        print("el comentario: \(comment.text)")
        profilePic.kf.setImage(with: comment.author.image)
        let attributedString = NSMutableAttributedString()
        let words = comment.text.components(separatedBy: " ")
        for i in 0..<(words.count) {
            if (words[i].hasPrefix("@")){
                print("has it")
                attributedString.bold((words[i])+" ")
            }else{
                attributedString.normal((words[i]).decodeEmoji + " ")
            }
            //let myAddedString = attributedString(string: words[i], attributes: nil)          //  self.commentInput.attributedText
        }
        //
        //self.commentInput.attributedText = attributedString
        commentContent.attributedText =  attributedString//comment.text
        updateLikeCount(comment: comment)
        nickname.text = comment.author.nickname
      
    }
    
    func updateLikeCount(comment: CommentModel) {
        
        if comment.likeCount == 0 {
            likeCount.isHidden = true
        } else {
            likeCount.isHidden = false
            likeCount.text = "\(comment.likeCount!)"
        }
        
        if comment.iLiked {
            like.text = "Je n'aime plus"
        } else {
            like.text = "J'aime"
        }
    
    }
}
extension UITableViewCell{
    func encode_emoji(_ s: String) -> String {
        let data = s.data(using: .nonLossyASCII, allowLossyConversion: true)!
        return String(data: data, encoding: .utf8)!
    }
    func decode_emoji(_ s: String) -> String? {
        let data = s.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII)
    }
}
extension String {
    var decodeEmoji: String{
        let data = self.data(using: String.Encoding.utf8);
        let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
        if let str = decodedStr{
            return str as String
        }
        return self
    }
    var encodeEmoji: String{
        if let encodeStr = NSString(cString: self.cString(using: .nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue){
            return encodeStr as String
        }
        return self
    }
}
