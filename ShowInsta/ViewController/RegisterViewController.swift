//
//  RegisterViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 9/26/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import Parse

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func registerAlert(reason: String) {
        
        let alertController = UIAlertController(title: "Registration Error", message: "Can't register this account because \(reason)", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    
    @IBAction func registerUser(_ sender: UIButton) {
        
        let newUser = PFUser()
        newUser["name"] = nameTextField.text!
        //let user = UsersObject()
        newUser.username = usernameField.text
        newUser.password = passwordField.text
        newUser.email = emailTextField.text
        //user.usersName = nameTextField.text
        
        /*user.fetchInBackground { (<#PFObject?#>, <#Error?#>) in
            <#code#>
        }*/
        
        /*user.saveInBackground { (success, error) in
            if (success) {
                print("sucessful")
                self.performSegue(withIdentifier: "finishedRegister", sender: nil)
            } else {
                // There was a problem, check error.description
                print("unsucessful: ", error?.localizedDescription)
            }
        }*/
        
        newUser.signUpInBackground { (success: Bool, error: Error?) in
            if success {
                print("created new user")
                self.performSegue(withIdentifier: "finishedRegister", sender: nil)
            } else {
                print(error?.localizedDescription)
                self.registerAlert(reason: error!.localizedDescription)
            }
        }
    }

}
