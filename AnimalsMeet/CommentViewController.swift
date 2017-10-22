//
//  CommentViewController.swift
//  AnimalsMeet
//
//  Created by Adrien morel on 02/05/2017.
//  Copyright © 2017 AnimalsMeet. All rights reserved.
//

import UIKit
import SearchTextField

class CommentViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var writeAComment: UIView!
    @IBOutlet weak var tableViewContainer: UIView!
    
    @IBOutlet weak var sendButton: UIButton!
    let commentTableViewController = CommentTableViewController()
    var media: MediaModel!
    
    var users = ["User1","User2","User3"]
    var userMode = false
    
    @IBOutlet weak var commentInput: SearchTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Commentaires"
        addChildViewController(commentTableViewController)
        tableViewContainer.addSubview(commentTableViewController.view)
        commentTableViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        commentInput.delegate = self
        commentInput.keyboardType = .emailAddress
        
        commentInput.addTarget(self, action: #selector(self.textEditingChanged(_:)), for: .editingChanged)
        self.sendButton.alpha = 0
    }
    
    func textEditingChanged(_ sender: Any) {
        if commentInput.text?.isEmpty != false {
            self.sendButton.alpha = 0
        }
        else {
            self.sendButton.alpha = 1
        }
        if let b = commentInput.text?.hasSuffix(" @"), b {
            userMode = true
        }
        if userMode {
            commentInput.filterStrings(users)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment(self)
        return true
    }
    
    @IBAction func sendComment(_ sender: Any) {
        guard !commentInput.text!.isEmpty else {
            return
        }
        
        let comment = commentInput.text!
        let commentModel = CommentModel()
        commentModel.author = App.instance.userModel
        commentModel.text = comment
        commentModel.likeCount = 0
        commentTableViewController.theData.append(commentModel)
        commentTableViewController.tableView.reloadData()
        commentInput.text = ""
        self.textEditingChanged(self)
        
        commentInput.resignFirstResponder()
        media.comment(content: comment)
            .then { _ in
                self.commentTableViewController.shouldRefresh()
            }
            .catch { _ in
                self.commentInput.text = comment
        }
    }
    
    public static func newInstance(_ media: MediaModel) -> CommentViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommentVC") as! CommentViewController
        vc.media = media
        return vc
    }
}
