//
//  ProfileViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 9/28/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MBProgressHUD

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var imagePicker = UIImagePickerController()
    var takenProfile: UIImage?
    var posts: [PFObject] = []
    var summaryText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        profileImageView.image = UIImage(named: "Profile")
        
        collectionView.dataSource = self
        getName()
        getPosts()
        print("I am here")
        // Do any additional setup after loading the view.
    }
    
    func printHello() {
        print("summary: \(summaryText)")
    }
    func getPosts() {
        
        let query = Post.query()
        
        query?.order(byDescending: "createdAt")
        query?.includeKey("author")
        
        query?.findObjectsInBackground { (allPosts, error) in
            if error == nil {
                let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
                loading.label.text = "Retrieving post(s)"
                if let posts = allPosts {
                    
                    self.posts.removeAll()
                    
                    for post in posts {
                        
                        self.posts.append(post)

                    }
                    loading.hide(animated: true)
                    self.collectionView.reloadData()
                }
            } else {
                print(error?.localizedDescription)
                
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if posts.isEmpty {
            return 1
        } else {
            return posts.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        if !posts.isEmpty {
            let post = posts[indexPath.row]
            cell.userPhotoImage.file = post["media"] as? PFFile
            cell.userPhotoImage.loadInBackground()
        }
        
        return cell
    }
    
    func alertSheet() {
        let alertSheet = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        alertSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.useCamera()}))
        alertSheet.addAction(UIAlertAction(title: "Photo", style: .default , handler: { _ in self.usePhoto()}))
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertSheet.addAction(cancelAction)
        
        present(alertSheet, animated: true, completion: nil)
    }
    
    func useCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("camera not availble")
            imagePicker.sourceType = .photoLibrary
        }
    }
    
    func usePhoto() {
        
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func changeProfilePic(_ sender: UITapGestureRecognizer) {
        alertSheet()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            takenProfile = image
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func getName() {
        let currentUser = PFUser.current()
        
        if currentUser!["name"] == nil {
            nameLabel.text = "Name??"
        } else {
            nameLabel.text = currentUser!["name"] as? String
        }
    }
    
}
