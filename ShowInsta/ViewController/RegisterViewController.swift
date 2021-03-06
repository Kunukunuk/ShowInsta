//
//  RegisterViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 9/26/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

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
        
        newUser.username = usernameField.text
        newUser.password = passwordField.text
        newUser.email = emailTextField.text
        
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.label.text = "Registering user"
        
        newUser.signUpInBackground { (success: Bool, error: Error?) in
            if success {
                print("created new user")
                self.performSegue(withIdentifier: "finishedRegister", sender: nil)
                loading.hide(animated: true)
            } else {
                print(error?.localizedDescription)
                self.registerAlert(reason: error!.localizedDescription)
                loading.hide(animated: true)
            }
        }
    }

}
