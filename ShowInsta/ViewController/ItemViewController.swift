//
//  ItemViewController.swift
//  ShowInsta
//
//  Created by Kun Huang on 9/28/18.
//  Copyright © 2018 Kun Huang. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {

    
    @IBOutlet weak var photoImageVIEW: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    var takenImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        photoImageVIEW.image = takenImage
    }

}
