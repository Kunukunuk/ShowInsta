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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        profileImageView.image = UIImage(named: "Profile")
        
        collectionView.dataSource = self
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
        let cellsPerLine: CGFloat = 3
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        let width = collectionView.frame.size.width / cellsPerLine - interItemSpacingTotal / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width * 3 / 2)
        getName()
        getPosts()
        getUserInfo()
    }
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        resizeImageView.contentMode = UIView.ContentMode.scaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func getUserInfo() {
        
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.label.text = "Retrieving user information"
        let query = UsersObject.query()
        query?.order(byDescending: "createdAt")
        query?.whereKey("author", equalTo: PFUser.current())
        
        query?.findObjectsInBackground(block: { (users, error) in
            if error == nil {
                
                for user in users! {
                    
                    if user["avatar"] == nil {
                        self.profileImageView.image = UIImage(named: "Profile")
                    } else {
                        self.profileImageView.file = user["avatar"] as? PFFile
                        self.profileImageView.loadInBackground()
                    }
                    self.nameLabel.text = user["displayName"] as? String
                    self.summary.text = user["summary"] as? String
                    break
                
                }
                loading.mode = .customView
                loading.customView = UIImageView(image: UIImage(named: "check.png"))
                loading.label.text = "Retrieved the user information"
                loading.hide(animated: true, afterDelay: 1)
            } else {
                print(error?.localizedDescription)
            }
        })
    }
    
    func saveUser() {
        
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.label.text = "Saving user information"
        
        if takenProfile != nil {
            takenProfile = resize(image: takenProfile!, newSize: CGSize(width: 1000, height: 1000))
        }
        
        UsersObject.saveUserInfo(image: takenProfile, withSummary: summary.text, withName: nameLabel.text) { (success, error) in
            if success {
                print("successfully saved")
                loading.mode = .customView
                loading.customView = UIImageView(image: UIImage(named: "check.png"))
                loading.label.text = "Saved the user information"
                loading.hide(animated: true, afterDelay: 1)
                self.getUserInfo()
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    func getPosts() {
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.label.text = "Retrieving post(s)"
        
        let query = Post.query()
        
        query?.order(byDescending: "createdAt")
        query?.whereKey("author", equalTo: PFUser.current())
        
        query?.findObjectsInBackground { (allPosts, error) in
            if error == nil {
                
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
        } else {
            cell.userPhotoImage.image = UIImage(named: "image")
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
        
        saveUser()
    }
    
    func getName() {
        let currentUser = PFUser.current()
        
        if currentUser!["name"] == nil {
            nameLabel.text = "Name??"
        } else {
            nameLabel.text = currentUser!["name"] as? String
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Setting" {
            let settings = segue.destination as! SettingsViewController
            settings.takenImage = takenProfile
        }
    }
}
