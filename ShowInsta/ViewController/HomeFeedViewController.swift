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

class HomeFeedViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    var takenImage: UIImage?
    var caption: String?
    var imagePicker = UIImagePickerController()
    var tableData: [[String: [AnyObject]]] = []
    var dates: [String] = []
    var isMoreDataLoading = false
    var refreshControl: UIRefreshControl!
    var loadingMoreView:InfiniteScrollActivityView?
    var limit = 20
    
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
                if let posts = allPosts {
                    
                    self.tableData.removeAll()
                    self.isMoreDataLoading = false
                    
                    for post in posts {
                        
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
        
        Post.postUserImage(image: takenImage, withCaption: caption) { (success, error) in
            if success {
                
                self.getPosts()
                self.tableView.reloadData()
            } else {
                print("not saved")
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
            
            //dates.append(currentDateTime)
            //tableData.append([currentDateTime: [takenImage!, caption! as AnyObject]])
            
            //tableView.reloadData()
            
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
                let destinationVC = segue.destination as! DetailsViewController
                
                for (key, value) in post {
                    destinationVC.date = key
                    destinationVC.picFile = value[0] as? PFFile
                    destinationVC.caption = value[1] as? String
                }
            }
        }
    }

}
