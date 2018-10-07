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

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var imagePicker = UIImagePickerController()
    var takenProfile: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        profileImageView.image = UIImage(named: "Profile")
        
        collectionView.dataSource = self
        getName()
        getProfilePic()
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath)
        
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
        
        saveProfilePhoto()
    }
    
    func getName() {
        let currentUser = PFUser.current()
        
        if currentUser!["name"] == nil {
            nameLabel.text = "Name??"
        } else {
            nameLabel.text = currentUser!["name"] as? String
        }
    }
    
    func getProfilePic() {
        
        let currentUser = PFUser.current()
        
        print(currentUser)
        
        if currentUser!["avatar"] != nil {
            profileImageView.file = currentUser!["avatar"] as? PFFile
            profileImageView.loadInBackground()
        }
    }
    
    //Mark save user profile picture

    func saveProfilePhoto() {
        
        let imgData = takenProfile?.pngData()
        PFUser.current()!["avatar"] = PFFile(name: "profile.png", data: imgData!)
        
        PFUser.current()!.saveInBackground(block: { (success, error) in
            if success {
                print("profile image saved")
                self.getProfilePic()
            } else {
                print("error saving")
                print(error?.localizedDescription)
            }
        })
        
    }
}
