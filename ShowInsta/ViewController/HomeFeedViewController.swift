//
//  HomeFeedViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 9/26/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery

class HomeFeedViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    var takenImage: UIImage?
    var caption: String?
    var imagePicker = UIImagePickerController()
    var tableData: [[String: [AnyObject]]] = []
    var dates: [String] = []
    var newData:[PFObject] = []
    
    var client : ParseLiveQuery.Client!
    var subscription : Subscription<PFUser>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        //imagePicker.allowsEditing = true
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        getPosts()
        getQuery()
        // Do any additional setup after loading the view.
    }
    
    func getPosts() {
        
       let query = Post.query()
        
        query?.order(byDescending: "createdAt")
        query?.includeKey("author")
        query?.includeKey("createdAt")
        query?.limit = 20
        
        query?.findObjectsInBackground { (allPosts, error) in
            if error == nil {
                if let posts = allPosts {
                    let object = posts.first
                    let date = object?.createdAt
                    
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "YYYY-MM-DD HH:MM:SS"
                    
                    let currentDateTime = dateFormat.string(from: date!)
                    
                    self.newData = posts
                    print("post: \(posts)")
                    print("newData: \(self.newData)")
                    print("newData: \(self.newData.count)")
                    for post in posts {
                        let caption = post["caption"] as! String
                        self.dates.append(currentDateTime)
                        self.tableData.append([currentDateTime: [UIImage(named: "Profile")!, caption as AnyObject]])
                        self.tableView.reloadData()
                    }
                }
            } else {
                print(error?.localizedDescription)
            }
        }
        
    }
    
    func savePost() {
        
        Post.postUserImage(image: takenImage, withCaption: caption) { (success, error) in
            if success {
                print("Successfully saved")
            } else {
                print("not saved")
            }
        }
        
    }
    
    func getQuery() {
        
        let currentUser = PFUser.current()
        print("Current user: \(currentUser)")
        print(currentUser!["name"])
        print("I am here")
        var armorQuery: PFQuery<PFUser> {
            return (PFUser.query()!
                .whereKeyExists("username")
                .order(byAscending: "createdAt")) as! PFQuery<PFUser>
        }
        print("I am here 2")
        client = ParseLiveQuery.Client()
        subscription = client.subscribe(armorQuery)
            // handle creation events, we can also listen for update, leave, enter events
            .handle(Event.created) { _, user in
                print("***********")
                print("\(user.username)")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
        }
        
        print("end of here")
        
    }
    
    @IBAction func postItem(_ sender: UIBarButtonItem) {
        
        alertSheet()
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableData.isEmpty {
            return 20
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
            cell.captionLabel.text = cap
            cell.dateLabel.text = dates[indexPath.row]
            
        } else {
            cell.picImageView.image = UIImage(named: "image_placeholder")
            cell.captionLabel.text = "caption"
            cell.dateLabel.text = "Date posted"
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
        
        savePost()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
