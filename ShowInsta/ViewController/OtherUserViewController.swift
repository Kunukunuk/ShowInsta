//
//  OtherUserViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 10/7/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import ParseUI

class OtherUserViewController: UIViewController {

    @IBOutlet weak var userAvatar: PFImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var userInfo: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName.text = userInfo?["displayName"] as? String
        summaryLabel.text = userInfo?["summary"] as? String
        userAvatar.file = userInfo?["avatar"] as? PFFile
        
    }
    
    
    @IBAction func followButton(_ sender: UIButton) {
    }
    
}
