//
//  CameraView.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 5/1/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct CameraView: View {
    @Binding var isShown: Bool
    var body: some View {
        CameraViewController()
            .edgesIgnoringSafeArea(.top)
    }
}

extension CameraViewController : UIViewControllerRepresentable{
    public typealias UIViewControllerType = CameraViewController
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<CameraViewController>) -> CameraViewController {
        return CameraViewController()
    }
    
    public func updateUIViewController(_ uiViewController: CameraViewController, context: UIViewControllerRepresentableContext<CameraViewController>) {
    }
}

final class CameraViewController: UIViewController {
    //properties to instantiate our camera coordinator and describe our preview
    //let cameraCoordinator = CameraCoordinator()//camera control related things are wrapped inside the CameraCoordinator
    let visionprocessorCoordinator = VisionProcessingCoordinator()
    var previewView: UIView!
    
    //create the preview view and call our camera controller methods
    
    override func viewDidLoad() {
        
        previewView = UIView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        previewView.contentMode = UIView.ContentMode.scaleAspectFit
        view.addSubview(previewView)
        
        visionprocessorCoordinator.setupAVCapture(previewView: self.previewView)
        //visionprocessorCoordinator.displayPreview(on: self.previewView)
        //self.previewView.addSubview(visionprocessorCoordinator.preview)
        
//        cameraCoordinator.prepare {(error) in
//            if let error = error {
//                print(error)
//            }
//
//            try? self.cameraCoordinator.displayPreview(on: self.previewView)
//        }
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        visionprocessorCoordinator.resumeCaptureSession()

//        if (self.cameraCoordinator.captureSession?.isRunning == false) {
//            self.cameraCoordinator.captureSession?.startRunning()
//        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        visionprocessorCoordinator.teardownAVCapture()
//        if (self.cameraCoordinator.captureSession?.isRunning == true) {
//            self.cameraCoordinator.captureSession?.stopRunning()
//        }

    }
}


