//
//  ScannerController.swift
//  LineLA
//
//  Created by uscclab on 2018/10/1.
//  Copyright © 2018 uscclab. All rights reserved.
//
import AVFoundation
import UIKit

// Member attribute
class ScannerController: UIViewController {
    var shared: GlobalInfo!
    var loginInfo:LoginInfo!
    var cameraController: CameraController!
    var scannerObserver: ScannerObserver!
    var returnBarcode: (() -> ())!
    var setCamera: ((_ previewLayer: AVCaptureVideoPreviewLayer?) -> (_ orientation: UIDeviceOrientation) -> ())!
    
    @IBOutlet weak var backItem: UIBarButtonItem!
    @IBOutlet weak var capturePreviewView: UIView!
}

// Override func
extension ScannerController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let captureSession = cameraController.captureSession

        if (captureSession?.isRunning == false) {
            captureSession?.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if shared != nil{
            let captureSession = cameraController.captureSession

            if (captureSession?.isRunning == true) {
                captureSession?.stopRunning()
            }
        }
        
//        if let nav = self.navigationController {
//            let isPopping = !nav.viewControllers.contains(self)
//            if isPopping {
//                print("Pop Scanner Controller")
//            } else {
//                // on nav, not popping off (pushing past, being presented over, etc.)
//            }
//        } else {
//            // not on nav at all
//        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// My func
extension ScannerController {
    func prepare() {
        loginInfo = shared.loginInfo
        cameraController = CameraController()
        initClosure()
        self.scannerObserver = ScannerObserver(activity: returnBarcode)
        func configureCameraController() {
            cameraController.prepare{(error) in
                if let error = error {
                    print(error)
                }
                try? self.cameraController.displayPreview(activity: self.setCamera)
            }
        }
        configureCameraController()
    }
    
    func initClosure() {
        returnBarcode = backToHome
        setCamera = { (_ previewLayer: AVCaptureVideoPreviewLayer?) -> ((_ orientation: UIDeviceOrientation) -> ()) in
            previewLayer?.frame = self.view.frame
            // 初始化 QR Code Frame 來突顯 QR code
            let qrCodeFrameView = UIView()
            qrCodeFrameView.layer.borderColor = UIColor.red.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            qrCodeFrameView.frame = CGRect(x: 0, y: self.capturePreviewView.frame.height/2, width: self.capturePreviewView.frame.width, height: 1.0)
    
            self.capturePreviewView.layer.insertSublayer(previewLayer!, at: 0)
            self.capturePreviewView.addSubview(qrCodeFrameView)
            self.capturePreviewView.bringSubviewToFront(qrCodeFrameView)
            
            let setDeviceOrientation = {(_ orientation: UIDeviceOrientation) -> () in
                if orientation != .portraitUpsideDown && orientation != .faceUp && orientation != .faceDown && orientation != .unknown {
                    var avorientation: AVCaptureVideoOrientation!
                    switch orientation {
                    case .portrait:
                        avorientation = .portrait
                    case .portraitUpsideDown:
                        break
                    case .landscapeRight:
                        avorientation = .landscapeLeft
                    case .landscapeLeft:
                        avorientation = .landscapeRight
                    case .unknown:
                        break
                    case .faceUp:
                        break
                    case .faceDown:
                        break
                    @unknown default:
                        fatalError()
                        break
                    }
                    previewLayer?.connection?.videoOrientation = avorientation
                    
                    let width = self.capturePreviewView.frame.width
                    let height = self.capturePreviewView.frame.height
                    let qrCodeFrameView = UIView()
                    qrCodeFrameView.layer.borderColor = UIColor.red.cgColor
                    qrCodeFrameView.layer.borderWidth = 2
                    qrCodeFrameView.frame = CGRect(x: 0, y: height/2, width: width, height: 1.0)
                    self.capturePreviewView.subviews[0].removeFromSuperview()
                    self.capturePreviewView.layer.insertSublayer(previewLayer!, at: 0)
                    self.capturePreviewView.addSubview(qrCodeFrameView)
                    self.capturePreviewView.bringSubviewToFront(qrCodeFrameView)
                    previewLayer?.frame = (self.capturePreviewView.frame)
                }
            }
            return setDeviceOrientation
        }
    }
    
    func backToHome() {
        let barcode = self.scannerObserver.barcode;
        print(barcode!)
        loginInfo.cardID = barcode
        loginInfo.token = false
        shared.mqttManager.mqtt.publish("IDF/Login/\(shared.mqttManager.uuID!)", withString: String(barcode!))
//        print("\(shared.mqttManager.clientID!)")
//        print(shared.mqttManager.clientID!)
        for i in 0..<(self.navigationController?.viewControllers.count)!{
            if let controller =  self.navigationController?.viewControllers[i] as? HomeController {
                controller.shared = shared
                controller.loginInfo = shared.loginInfo
                controller.accountInfo = shared.accountInfo
                exitUI()
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func exitUI() {
        let captureSession = cameraController.captureSession
        
        if (captureSession?.isRunning == true) {
            captureSession?.stopRunning()
        }
        self.setCamera = nil
        self.cameraController = nil
        self.scannerObserver.barcode = nil
        self.scannerObserver = nil
        self.returnBarcode = nil
        self.backItem = nil
        self.loginInfo = nil
        self.shared = nil
        
    }
}

// IBAction func
extension ScannerController {
    @IBAction func back(_ sender: Any) {
        for i in 0..<(self.navigationController?.viewControllers.count)!{
            if let controller =  self.navigationController?.viewControllers[i] as? HomeController {
                controller.shared = shared
                controller.loginInfo = shared.loginInfo
                controller.accountInfo = shared.accountInfo
                exitUI()
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }
    }
}
