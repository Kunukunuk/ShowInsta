//
//  UsersObject.swift
//  ShowInsta
//
//  Created by Kun Huang on 9/30/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import Parse

class UsersObject: PFObject, PFSubclassing {

    @NSManaged var displayName: String?
    @NSManaged var summary: String?
    @NSManaged var avatar: PFFile?
    @NSManaged var author: PFUser?
    
    class func parseClassName() -> String {
        return "User"
    }
    
    class func saveUserInfo(image: UIImage?, withSummary summary: String?, withName name: String?, withCompletion completion: PFBooleanResultBlock?) {
        // use subclass approach
        let user = UsersObject()
        
        // Add relevant fields to the object
        user.avatar = getPFFileFromImage(image: image) // PFFile column type
        user.author = PFUser.current() // Pointer column type that points to PFUser
        user.summary = summary
        user.displayName = name
        
        // Save object (following function will save the object in Parse asynchronously)
        user.saveInBackground(block: completion)
    }
    
    /**
     Method to convert UIImage to PFFile
     
     - parameter image: Image that the user wants to upload to parse
     
     - returns: PFFile for the the data in the image
     */
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = image.pngData() {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
    
}
