//
//  CameraCoordinator.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 5/1/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraCoordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //properties that will be used to store information on which camera we use, the session we’re creating and the preview layout
    //var captureSession: AVCaptureSession?
    //var frontCamera: AVCaptureDevice?
    //var frontCameraInput: AVCaptureDeviceInput?
    //var previewLayer: AVCaptureVideoPreviewLayer?
    //var previewView: UIView!
    var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let captureSession = AVCaptureSession()
    var bufferSize: CGSize = .zero
    var rootLayer: CALayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()//new add
    //var captureOutput: AVCapturePhotoOutput?//new add
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // to be implemented in the subclass
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            return
//        }
        
    }
    
    //enum to describes all potentials errors
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
//    func prepare(completionHandler: @escaping (Error?) -> Void){
//        //ref: https://developer.apple.com/documentation/avfoundation/avcapturesession
//        //1. Create a capture session
//        //2. Define which capture device we’ll use
//        //3. Create an input from our capture device
//        func createCaptureSession(){
//            self.captureSession = AVCaptureSession()
//            self.captureSession?.sessionPreset = .vga640x480//.hd1280x720 //You use the sessionPreset property to customize the quality level, bitrate, or other settings for the output.
//            //default is high, https://developer.apple.com/documentation/avfoundation/avcapturesession/preset/1388084-high
//        }
//        func configureCaptureDevices() throws {
//            let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
//
//            self.frontCamera = camera
//
//            try camera?.lockForConfiguration()
//            camera?.unlockForConfiguration()
//
//        }
//        func configureDeviceInputs() throws {
//            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
//
//            if let frontCamera = self.frontCamera {
//                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
//
//                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!)}
//                else { throw CameraControllerError.inputsAreInvalid }
//
//                if captureSession.canAddOutput(videoDataOutput) {
//                    captureSession.addOutput(videoDataOutput)
//                    // Add a video data output
//                    videoDataOutput.alwaysDiscardsLateVideoFrames = true
//                    videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
//                    videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
//                }else {
//                    print("Could not add video data output to the session")
//                    captureSession.commitConfiguration()
//                    return
//                }
//
//                let captureConnection = videoDataOutput.connection(with: .video)
//                // Always process the frames
//                captureConnection?.isEnabled = true
//                do {
//                    try  frontCamera.lockForConfiguration()
//                    let dimensions = CMVideoFormatDescriptionGetDimensions(frontCamera.activeFormat.formatDescription)
//                    bufferSize.width = CGFloat(dimensions.width)
//                    bufferSize.height = CGFloat(dimensions.height)
//                    frontCamera.unlockForConfiguration()
//                } catch {
//                    print(error)
//                }
//                captureSession.commitConfiguration()
//            }
//            else { throw CameraControllerError.noCamerasAvailable }
//
//            captureSession.startRunning()
//
//        }
//
//        DispatchQueue(label: "prepare").async {
//            do {
//                createCaptureSession()
//                try configureCaptureDevices()
//                try configureDeviceInputs()
//            }
//
//            catch {
//                DispatchQueue.main.async{
//                    completionHandler(error)
//                }
//
//                return
//            }
//
//            DispatchQueue.main.async {
//                completionHandler(nil)
//            }
//        }
//
//    }
    
    //generate the preview of our camera session and show it inside a given view
//    func displayPreview(on view: UIView) throws {
//        //guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
//
//        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        self.previewLayer?.connection?.videoOrientation = .portrait
//
//        view.layer.insertSublayer(self.previewLayer!, at: 0)
//        self.previewLayer?.frame = view.frame
//    }
    
    //new
    func setupAVCapture(previewView: UIView) {
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .vga640x480 // Model image size is smaller.
        
        // Add a video input
        guard captureSession.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            captureSession.commitConfiguration()
            return
        }
        captureSession.addInput(deviceInput)
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            captureSession.commitConfiguration()
            return
        }
        let captureConnection = videoDataOutput.connection(with: .video)
        // Always process the frames
        captureConnection?.isEnabled = true
        do {
            try  videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        captureSession.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
    }
    
    func startCaptureSession() {
        captureSession.startRunning()
    }
    
    func resumeCaptureSession() {
        if (captureSession.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    // Clean up capture setup
    func teardownAVCapture() {
        self.previewLayer?.removeFromSuperlayer()
        previewLayer = nil
//        if (captureSession.isRunning) {
//            captureSession.stopRunning()
//        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // print("frame dropped")
    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
}
