//
//  DetailsViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 10/2/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import ParseUI

class DetailsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: PFImageView!
    @IBOutlet weak var likeCounts: UILabel!
    @IBOutlet weak var commentCounts: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    var date: String?
    var caption: String?
    var picFile: PFFile?
    var likeCount: Int = 0
    var commentCount: Int = 0
    var post: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoImageView.file = picFile
        photoImageView.loadInBackground()
        dateLabel.text = date
        captionLabel.text = caption
        likeCounts.text = String(likeCount)
        commentCounts.text = String(commentCount)
        getName()
        print("post: \(post)")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func likeButton(_ sender: UIButton) {
        likeCount += 1
        likeCounts.text = "\(likeCount)"
        savePostCounts()
    }
    
    @IBAction func commentButton(_ sender: UIButton) {
        commentCount += 1
        commentCounts.text = "\(commentCount)"
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
    
    func savePostCounts() {
        post!["likesCount"] = likeCount
        
        post?.saveInBackground(block: { (success, error) in
            if success {
                print("like count saved")
            } else {
                print("error with saving count")
            }
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
