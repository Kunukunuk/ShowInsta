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
import MBProgressHUD
import ParseUI

class HomeFeedViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    var takenImage: UIImage?
    var caption: String?
    var imagePicker = UIImagePickerController()
    var tableData: [[String: [AnyObject]]] = []
    var dates: [String] = []
    var posts: [PFObject] = []
    var isMoreDataLoading = false
    var refreshControl: UIRefreshControl!
    var loadingMoreView:InfiniteScrollActivityView?
    var limit = 20
    var userInfo: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        //imagePicker.allowsEditing = true
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HomeFeedViewController.didPullToRefresh(_:)), for: .valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        getUserInfo()
        getPosts()
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        
        getPosts()
    }
    
    func getPosts() {
        
       let query = Post.query()
        
        query?.order(byDescending: "createdAt")
        query?.includeKey("author")
        query?.limit = limit
        
        query?.findObjectsInBackground { (allPosts, error) in
            if error == nil {
                let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
                loading.label.text = "Retrieving post(s)"
                if let posts = allPosts {
                    
                    self.tableData.removeAll()
                    self.isMoreDataLoading = false
                    
                    for post in posts {
                        
                        self.posts.append(post)
                        let date = post.createdAt
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss a" //Input Format
                        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                        let stringDate = dateFormatter.string(from: date!)
                        let currentDate = self.UTCToLocal(UTCDateString: stringDate)
                        
                        let caption = post["caption"] as! String
                        let image = post["media"]
                        
                        self.tableData.append([currentDate: [image as AnyObject, caption as AnyObject]])

                        self.tableView.reloadData()
                    }
                    loading.hide(animated: true)
                    self.refreshControl.endRefreshing()
                    self.loadingMoreView!.stopAnimating()
                }
            } else {
                print(error?.localizedDescription)
                
            }
        }
        
    }
    
    func UTCToLocal(UTCDateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss a" //Input Format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let UTCDate = dateFormatter.date(from: UTCDateString)
        dateFormatter.dateFormat = "yyyy-MMM-dd hh:mm:ss a" // Output Format
        dateFormatter.timeZone = TimeZone.current
        let UTCToCurrentFormat = dateFormatter.string(from: UTCDate!)
        return UTCToCurrentFormat
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
    
    func savePost() {
        
        takenImage = resize(image: takenImage!, newSize: CGSize(width: 1000, height: 1000))
        
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true )
        loading.label.text = "Saving post(s)"
        Post.postUserImage(image: takenImage, withCaption: caption) { (success, error) in
            if success {
                
                self.getPosts()
                loading.mode = .customView
                loading.customView = UIImageView(image: UIImage(named: "check.png"))
                loading.label.text = "Saved your post"
                loading.hide(animated: true, afterDelay: 1)
                
                self.tableView.reloadData()
            } else {
                print("not saved")
                loading.hide(animated: true)
            }
        }
        
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
    
    func getUserInfo() {
        let query = UsersObject.query()
        query?.order(byDescending: "createdAt")
        query?.includeKey("author")
        
        query?.findObjectsInBackground(block: { (users, error) in
            if error == nil {
                for user in users! {
                    self.userInfo = user
                    break
                }
            } else {
                print(error?.localizedDescription)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableData.isEmpty {
            return 20
        }
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = PFImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        var name = "Name"
        if userInfo != nil {
            name = (userInfo!["displayName"] as? String)!
            profileView.file = userInfo!["avatar"] as? PFFile
            profileView.loadInBackground()
        } else {
            profileView.image = UIImage(named: "Profile")
        }
        
        headerView.addSubview(profileView)
        
        let label = UILabel(frame: CGRect(x: 60, y: 0, width: 375, height: 50))
        label.text = name
        headerView.addSubview(label)
        
        let tappedHeader = UITapGestureRecognizer(target: self, action: #selector(HomeFeedViewController.tappedHeaderView(_:)))
        
        headerView.addGestureRecognizer(tappedHeader)
        
        return headerView
    }
    
    @objc func tappedHeaderView(_ tapped: UITapGestureRecognizer) {
        performSegue(withIdentifier: "userProfile", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        
        if !tableData.isEmpty {
            let date = tableData[indexPath.row]
            
            for (key, value) in date {
                
                let img = value[0] as? PFFile
                let cap = value[1] as! String
                
                cell.picImageView.file = img
                cell.picImageView.loadInBackground()
                cell.captionLabel.text = cap
                cell.dateLabel.text = key
            }
            
            
        } else {
            cell.picImageView.image = UIImage(named: "image_placeholder")
            cell.captionLabel.text = "caption"
            cell.dateLabel.text = "Date posted"
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scrollViewContentHeight = tableView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
            
            isMoreDataLoading = true
            
            let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
            loadingMoreView?.frame = frame
            loadingMoreView!.startAnimating()
            
            // ... Code to load more results ...
            limit += 20
            getPosts()
        }
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
        
        /*let currentTime = NSDate()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "YYYY-MM-DD HH:MM:SS"
        
        let currentDateTime = dateFormat.string(from: currentTime as Date)*/
        
        if let itemVC = segue.source as? ItemViewController {
            
            takenImage = itemVC.takenImage
            caption = itemVC.captionTextView.text
            
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
        } else if segue.identifier == "details" {
            let cell = sender as! FeedCell
            if let indexPath = tableView.indexPath(for: cell) {
                let post = tableData[indexPath.row]
                let postInDetails = self.posts[indexPath.row]
                
                let destinationVC = segue.destination as! DetailsViewController
                
                destinationVC.post = postInDetails
                destinationVC.likesCount = postInDetails["likesCount"] as! Int
                destinationVC.commentsCount = postInDetails["commentsCount"] as! Int
                
                for (key, value) in post {
                    destinationVC.date = key
                    destinationVC.picFile = value[0] as? PFFile
                    destinationVC.caption = value[1] as? String
                }
            }
        } else if segue.identifier == "userProfile" {
            let otherUser = segue.destination as! OtherUserViewController
            
            otherUser.userInfo = userInfo
        }
    }

}
