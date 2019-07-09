//
//  ConfirmLoginController.swift
//  LineLA
//
//  Created by uscclab on 2018/10/22.
//  Copyright © 2018 uscclab. All rights reserved.
//

import UIKit

// Member attribute
class ConfirmLoginController: UIViewController {
    var gradientLayer: CAGradientLayer!
    var shared: GlobalInfo!
    var accountInfo: AccountInfo!
    var loginInfo: LoginInfo!
//    let appDeleagte = UIApplication.shared.delegate as! AppDelegate
    var memberID: String?
    @IBOutlet weak var buttonConfirmLogin: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelMemberID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var lowView: UIView!
    @IBOutlet weak var firstView: UIView!
    var showProfile: ((_ responseData: Data) -> ())!
}

// Override func
extension ConfirmLoginController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepare()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        let tabBarController = segue.destination as! TabBarViewController
        if let controller = tabBarController.viewControllers?.first as? FriendPageViewController{
            controller.shared = shared
        }
    }
    
}

// My func
extension ConfirmLoginController {
    func prepare() {
        loginInfo = shared.loginInfo
        accountInfo = shared.accountInfo
        initClosure()
        createGradientLayer()
        checkMemberID()
        GlobalInfo.getProfile(memberID: memberID,activity: showProfile)
        
        buttonShadow(button: buttonConfirmLogin)
        buttonShadow(button: buttonCancel)
    }
    
    func initClosure() {
        // assign a closure to showProfile.
        showProfile = {(_ responseData: Data) -> () in
            // parse the result as JSON, since that's what the API provides
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: String] else { return }
                guard let memberName = todo["name"] else { return }
                guard let avatar = Data(base64Encoded: todo["avatar"]!) else { return }
            
                self.accountInfo.memberID = self.memberID
                self.accountInfo.memberName = memberName
                self.accountInfo.memberAvatar = UIImage(data: avatar,scale:1.0)?.toCircle()
                // asynchronous thread. task core is update UI.
                DispatchQueue.main.async { self.upddateUI() }
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
    }
    
    func upddateUI(){
        imageView.image = accountInfo.memberAvatar?.toCircle()
        labelName.text = labelName.text! + accountInfo.memberName!
        labelMemberID.text = labelMemberID.text! + self.memberID!
    }
    
    func exitUI(){
        memberID = nil
        showProfile = nil
        if let l = firstView.layer.sublayers![0] as? CAGradientLayer {
            l.removeFromSuperlayer()
        }
        gradientLayer = nil
        imageView.image = nil
        labelMemberID.text = nil
        labelName.text = nil
        buttonConfirmLogin = nil
        buttonCancel = nil
        imageView = nil
        labelMemberID = nil
        labelName = nil
        lowView = nil
        firstView = nil
        accountInfo = nil
        loginInfo = nil
        shared = nil
    }
    
    func checkMemberID() {
        if let str = loginInfo.cardID {
            // Set up the URL request
            var newStartIndex = str.index(str.startIndex, offsetBy: 1)
            var substring = str[..<newStartIndex]
            let firstchat = String(substring)
            var memberID: String
            if firstchat == "0" { // LA memberID is 0xxxxxxxxxxxx.
                newStartIndex = str.index(str.startIndex, offsetBy: 1)
                substring = str[newStartIndex..<str.endIndex]
                memberID = String(substring)
            } else { memberID = str }
            accountInfo.memberID = memberID
            self.memberID = accountInfo.memberID
        }
    }
    
    func buttonShadow(button: UIButton!) { 
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 2.0
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.7
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = lowView.bounds
        gradientLayer.colors = [UIColor.green.cgColor, UIColor.white.cgColor]
        firstView.layer.addSublayer(gradientLayer)
        firstView.bringSubviewToFront(lowView)
    }
}

// IBAction func
extension ConfirmLoginController {
    @IBAction func actionCancel(_ sender: Any) {
        for i in 0..<(self.navigationController?.viewControllers.count)!{
            if let controller =  self.navigationController?.viewControllers[i] as? HomeController {
                shared.clearAppInfo()
                controller.shared = shared
                controller.loginInfo = shared.loginInfo
                controller.accountInfo = shared.accountInfo
                exitUI()
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    @IBAction func actionConfirmLogin(_ sender: Any) {
        // TODO: nextpage
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let controller = appDelegate.window?.rootViewController as? NavRootController {
                controller.viewControllers.removeAll()
                let mainVC = UIStoryboard.init(name: "Main", bundle: nil)
                if let childcontroller = mainVC.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController {
                    loginInfo.token = true
                    if let childcontroller = childcontroller.viewControllers?.first as? FriendPageViewController{
                        childcontroller.shared = shared
                    }
                    exitUI()
                    controller.viewControllers.append(childcontroller)
                }
            }
        }
    }
}
