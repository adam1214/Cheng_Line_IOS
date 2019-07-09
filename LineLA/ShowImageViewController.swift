//
//  ShowImageViewController.swift
//  LineLA
//
//  Created by uscclab on 2019/3/21.
//  Copyright © 2019 uscclab. All rights reserved.
//

import UIKit

class ShowImageViewController: UIViewController {
    @IBOutlet weak var viewImg: UIView!
    @IBOutlet weak var imgView: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if image != nil {
            imgView.image = image!
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: false)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
