//
//  DetailsViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 10/2/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import ParseUI
import MBProgressHUD

class DetailsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: PFImageView!
    @IBOutlet weak var likeCounts: UILabel!
    @IBOutlet weak var commentCounts: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    var date: String?
    var caption: String?
    var picFile: PFFile?
    var likesCount: Int = 0
    var commentsCount: Int = 0
    var post: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoImageView.file = picFile
        photoImageView.loadInBackground()
        dateLabel.text = date
        captionLabel.text = caption
        likeCounts.text = String(likesCount)
        commentCounts.text = String(commentsCount)
        getName()
        commentsLabel.text = ""
        getComments()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func likeButton(_ sender: UIButton) {
        likesCount += 1
        likeCounts.text = "\(likesCount)"
        savePostCounts()
    }
    
    @IBAction func commentButton(_ sender: UIButton) {
        commentBox()
    }
    
    func getName() {
        let currentUser = PFUser.current()
        
        if currentUser!["name"] == nil {
            nameLabel.text = "Name??"
        } else {
            nameLabel.text = currentUser!["name"] as? String
        }
        //print(currentUser!["name"])
    }
    
    func getComments() {
        if post!["comment"] != nil {
            commentsLabel.text = post!["comment"] as? String
        } else {
            commentsLabel.text = ""
        }
    }
    
    func savePostCounts() {
        post!["likesCount"] = likesCount
        post!["commentsCount"] = commentsCount
        post!["comment"] = commentsLabel.text
        
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.label.text = "Saving likes or comment"
        post?.saveInBackground(block: { (success, error) in
            if success {
                print("like count saved")
                loading.hide(animated: true)
            } else {
                print("error with saving count")
                loading.hide(animated: true)
            }
        })
    }
    
    func commentBox() {
        self.performSegue(withIdentifier: "commentBox", sender: nil)
    }
    
    @IBAction func unwindToDetailsCancelComment(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindToDetailsPostComment(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as? CommentViewController
        
        let comment = sourceViewController?.commentTextView.text
        //commentsLabel.text = "\(comment!) \n"
        
        commentsLabel.text?.append("\(comment!) \n")
        commentsCount += 1
        commentCounts.text = "\(commentsCount)"
        savePostCounts()
        // Use data from the view controller which initiated the unwind segue
    }

}
