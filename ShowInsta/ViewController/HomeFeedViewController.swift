//
//  HomeFeedViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 9/26/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import Parse

class HomeFeedViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutUser(_ sender: UIBarButtonItem) {
        PFUser.logOutInBackground { (error: Error?) in
            // PFUser.current() will now be nil
        }
    }
    
    @IBAction func postItem(_ sender: UIBarButtonItem) {
        
        alertSheet()
        
    }
    
    func alertSheet() {
        let alertSheet = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        alertSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.useCamera()}))
        alertSheet.addAction(UIAlertAction(title: "Photo", style: .default , handler: { _ in self.usePhoto()}))
        alertSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertSheet, animated: true, completion: nil)
    }
    
    func useCamera() {
        
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true)
    }
    
    func usePhoto() {
    
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true)
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
