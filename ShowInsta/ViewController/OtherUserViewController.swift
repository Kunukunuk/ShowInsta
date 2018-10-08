//
//  OtherUserViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 10/7/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import ParseUI
import MBProgressHUD

class OtherUserViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var userAvatar: PFImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var userInfo: PFObject?
    var userPost: [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        
        userName.text = userInfo?["displayName"] as? String
        summaryLabel.text = userInfo?["summary"] as? String
        userAvatar.file = userInfo?["avatar"] as? PFFile
        userAvatar.loadInBackground()
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
        let cellsPerLine: CGFloat = 3
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        let width = collectionView.frame.size.width / cellsPerLine - interItemSpacingTotal / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width * 3 / 2)
        
        getUserPosts()
    }
    
    func getUserPosts() {
        let query = Post.query()
        
        query?.order(byDescending: "createdAt")
        query?.whereKey("author", equalTo: userInfo!["author"])
        
        query?.findObjectsInBackground { (allPosts, error) in
            if error == nil {
                
                for post in allPosts! {
                    self.userPost.append(post)
                }
                self.collectionView.reloadData()
                
            } else {
                print(error?.localizedDescription)
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if userPost.isEmpty {
            return 1
        } else {
            return userPost.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        if !userPost.isEmpty {
            let post = userPost[indexPath.row]
            
            cell.otherImageView.file = post["media"] as? PFFile
            cell.otherImageView.loadInBackground()
        }
        
        return cell
    }
    
    @IBAction func followButton(_ sender: UIButton) {
    }
    
}
