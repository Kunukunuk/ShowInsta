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

    @NSManaged var usersName: String?
    @NSManaged var age: Int
    @NSManaged var email: String?
    @NSManaged var username: String?
    @NSManaged var password: String?
    
    class func parseClassName() -> String {
        return "Users"
    }
    
}
