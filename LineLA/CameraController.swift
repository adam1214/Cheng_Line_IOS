//
//  CameraController.swift
//  LineLA
//
//  Created by uscclab on 2018/10/1.
//  Copyright © 2018 uscclab. All rights reserved.
//

import AVFoundation
import UIKit

// Member attribute
class CameraController: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var currentCameraPosition: CameraPosition?
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    var metadataOutput: AVCaptureMetadataOutput?
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var deviceOrientationObserver: DeviceOrientationObserver?
    
    deinit {
        captureSession = nil
        currentCameraPosition = nil
        frontCamera = nil
        frontCameraInput = nil
        metadataOutput = nil
        rearCamera = nil
        rearCameraInput = nil
        previewLayer = nil
        deviceOrientationObserver = nil
    }
}

// My func
extension CameraController {
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera, .builtInDualCamera],mediaType: .video,  position: .unspecified)
            let cameras = session.devices.compactMap { $0 }
            guard !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }
            
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }
                
                if camera.position == .back {
                    self.rearCamera = camera
                    
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                
                self.currentCameraPosition = .rear
            }
                
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                self.currentCameraPosition = .front
            }
                
            else { throw CameraControllerError.noCamerasAvailable }
        }
        
        func configureMetadataOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.metadataOutput = AVCaptureMetadataOutput()
            
            if (captureSession.canAddOutput(self.metadataOutput!)) {
                captureSession.addOutput(self.metadataOutput!)
                self.metadataOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                self.metadataOutput?.metadataObjectTypes = [.qr,.ean8, .ean13, .pdf417, .upce, .aztec, .code128, .code39, .code39Mod43 , .code93]
            }else {
                print("Your device does not support scanning a code from an item. Please use a device with a camera.")
                return
            }
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configureMetadataOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(activity: @escaping (_ previewLayer: AVCaptureVideoPreviewLayer?) -> ((_ orientation: UIDeviceOrientation) -> ())) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = .resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = getDeviceOrientation()
        self.deviceOrientationObserver = DeviceOrientationObserver(activity: activity(self.previewLayer))
    }
    
    func getDeviceOrientation() -> AVCaptureVideoOrientation {
        let orientation = UIDevice.current.orientation
        var avorientation = AVCaptureVideoOrientation.portrait
        if orientation != .portraitUpsideDown && orientation != .faceUp && orientation != .faceDown && orientation != .unknown {
            
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
        }
        return avorientation
    }
    
}

// My func : AVCapturePhotoCaptureDelegate
extension CameraController: AVCapturePhotoCaptureDelegate {
    // Scanner
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        captureSession?.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//            print(qrCodeValue)
            let notificationName = Notification.Name(rawValue: "GetBarcodeNotification")
            NotificationCenter.default.post(name: notificationName, object: self,
                                            userInfo: ["barcode":stringValue])
        }
    }
    
}

// My enum
extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}
