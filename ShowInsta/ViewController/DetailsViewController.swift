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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoImageView.file = picFile
        photoImageView.loadInBackground()
        dateLabel.text = date
        captionLabel.text = caption
        getName()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func likeButton(_ sender: UIButton) {
        likeCount += 1
        likeCounts.text = "\(likeCount)"
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
