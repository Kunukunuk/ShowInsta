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
    @NSManaged var age: Int
    @NSManaged var avatar: PFFile?
    
    class func parseClassName() -> String {
        return "User"
    }
    
}
