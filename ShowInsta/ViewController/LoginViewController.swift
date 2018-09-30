//
//  LoginViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 9/25/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var isHidden = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        checkIsLoggedIn()
    }
    
    func checkIsLoggedIn () {
        if PFUser.current() != nil {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
            if let error = error {
                print("User log in failed: \(error.localizedDescription)")
            } else {
                print("User logged in successfully")
                // display view controller that needs to shown after successful login
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    
    @IBAction func unwindLogout(_ segue: UIStoryboardSegue) {
        
        
    }
    
    
    @IBAction func showHidePassword(_ sender: UIButton) {
        if isHidden {
            passwordField.isSecureTextEntry = false
            isHidden = false
        } else {
            passwordField.isSecureTextEntry = true
            isHidden = true
        }
    }
    

}
