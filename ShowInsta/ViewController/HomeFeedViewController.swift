//
//  HomeFeedViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 9/26/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import Parse

class HomeFeedViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    var takenImage: UIImage?
    var caption: String?
    var imagePicker = UIImagePickerController()
    var tableData: [[String: [AnyObject]]] = []
    var dates: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        // Do any additional setup after loading the view.
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
        present(imagePicker, animated: true, completion: nil)
    }
    
    func usePhoto() {
    
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableData.isEmpty {
            return 1
        }
        return tableData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        
        if !tableData.isEmpty {
            let date = tableData[indexPath.row]
            
            let key = date[dates[indexPath.row]]
            
            let img = key![0] as! UIImage
            let cap = key![1] as! String
            
            cell.picImageView.image = img
            cell.editTextView.text = cap
        } else {
            cell.picImageView.image = UIImage(named: "image_placeholder")
            cell.editTextView.text = "caption"
        }
        
        return cell
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            takenImage = image
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
        performSegue(withIdentifier: "showItem", sender: nil)
    }
    
    @IBAction func unwindToHomeFeedCancel(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindToHomeFeedShare(_ segue: UIStoryboardSegue) {
        
        let currentTime = NSDate()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "YYYY-MM-DD HH:MM:SS"
        
        let currentDateTime = dateFormat.string(from: currentTime as Date)
        
        if let itemVC = segue.source as? ItemViewController {
            
            takenImage = itemVC.takenImage
            caption = itemVC.captionTextView.text
            
            dates.append(currentDateTime)
            tableData.append([currentDateTime: [takenImage!, caption! as AnyObject]])
            
            tableView.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItem" {
            
            let vc = segue.destination as! UINavigationController
            let realVC = vc.topViewController as! ItemViewController
            
            realVC.takenImage = self.takenImage
        } else if segue.identifier == "Logout" {
            PFUser.logOutInBackground { (error: Error?) in
                // PFUser.current() will now be nil
            }
        }
    }

}
