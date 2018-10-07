//
//  LoginViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 9/25/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class LoginViewController: UIViewController {

    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var isHidden = true
    
    
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
    
    func loginAlert(with message: String? = "Email or password is empty") {
        
        let alertController = UIAlertController(title: "Invalid Login", message: "\(message!)", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        
        if username.isEmpty || password.isEmpty {
            loginAlert()
        } else {
            
            let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
            loading.label.text = "Logging in"
            //MBProgressHUD.showAdded(to: self.view, animated: true)
            PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
                if let error = error {
                    print("User log in failed: \(error.localizedDescription)")
                    self.loginAlert(with: error.localizedDescription)
                    loading.hide(animated: true)
                } else {
                    print("User logged in successfully")
                    // display view controller that needs to shown after successful login
                    loading.mode = .customView
                    loading.customView = UIImageView(image: UIImage(named: "check.png"))
                    loading.label.text = "Successfully logged in"
                    loading.hide(animated: true, afterDelay: 1)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                       self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    })
                    //self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
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
