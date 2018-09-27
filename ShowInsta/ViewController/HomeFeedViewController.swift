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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutUser(_ sender: UIBarButtonItem) {
        PFUser.logOutInBackground { (error: Error?) in
            // PFUser.current() will now be nil
        }
    }
    
    @IBAction func takePicture(_ sender: UIBarButtonItem) {
        
    }
    
    func useCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func usePhoto() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        present(vc, animated: true)
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
