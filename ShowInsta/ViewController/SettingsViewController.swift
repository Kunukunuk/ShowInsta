//
//  SettingsViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 10/6/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView

class SettingsViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var summaryText: RSKPlaceholderTextView!
    var takenImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let previousController = viewController as? ProfileViewController
        previousController?.takenProfile = takenImage
        if !summaryText.text.isEmpty{
            previousController?.summary.text = summaryText.text
            previousController?.saveUser()
        }
    }
    
    
}
