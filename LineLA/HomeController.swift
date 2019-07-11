//
//  ViewController.swift
//  LineLA
//
//  Created by uscclab on 2018/9/10.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit

// Member attribute
class HomeController: UIViewController {
    var shared: GlobalInfo!
    var accountInfo: AccountInfo!
    var loginInfo: LoginInfo!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonExit: UIButton!
}

// Override func
extension HomeController {
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // 選轉
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        // check login state
//        if !loginInfo.token {
//            if loginInfo.cardID != nil{
//                if let controller = storyboard?.instantiateViewController(withIdentifier: "ConfirmLoginController") as? ConfirmLoginController{
//                    controller.shared = shared
//                    exitUI()
//                    navigationController?.pushViewController(controller, animated: true)
//                }
//            }
//        } else {
//            // go to TabBarViewController.
//            if let controller = storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController {
////                controller.restorationIdentifier = "goHome"
//                if let controller = controller.viewControllers?.first as? FriendPageViewController{
//                    controller.shared = shared
//                }
//                exitUI()
//                navigationController?.pushViewController(controller, animated: true)
//            }
//        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// My func
extension HomeController {
    func prepare() {
//        shared = GlobalInfo.shared()
        accountInfo = shared.accountInfo
        loginInfo = shared.loginInfo
        buttonShadow(button: buttonLogin)
        buttonShadow(button: buttonExit)
        shared.mqttManager.setupMQTT()
    }
    
    func buttonShadow(button: UIButton!) {  // button 陰影
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 2.0
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.7
    }
    
    func exitUI() {
        buttonLogin = nil
        buttonExit = nil
        shared = nil
        accountInfo = nil
        loginInfo = nil
    }
}

// IBAction func
extension HomeController {
    @IBAction func actionLogin(_ sender: Any) {
//        if let controller = storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController {
    //                controller.restorationIdentifier = "goHome"
//                    if let controller = controller.viewControllers?.first as? FriendPageViewController{
//                        controller.shared = shared
//                    }
//                    exitUI()
//                    navigationController?.pushViewController(controller, animated: true)
//        }
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ScannerController") as? ScannerController{
            controller.shared = shared
            exitUI()
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func actionExit(_ sender: Any) {
        /* debug start
        loginInfo.cardID = "0100672000367"
        accountInfo.memberID = "100672000367"
        loginInfo.token = true
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ConfirmLoginController") as? ConfirmLoginController{
            controller.shared = shared
            exitUI()
//            controller.memberID = "100672000367"
            navigationController?.pushViewController(controller, animated: true)
        }
        // */// debug end
        //* Release start
        exitUI()
        exit(0)
        // */// Release end
    }
    
}
