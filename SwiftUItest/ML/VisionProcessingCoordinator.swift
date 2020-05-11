//
//  VisionProcessingCoordinator.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 5/4/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Vision

class VisionProcessingCoordinator: CameraCoordinator {
    
    private var detectionOverlay: CALayer! = nil
    
    //new added for face detection
    var detectedFaceRectangleShapeLayer: CAShapeLayer?
    var detectedFaceLandmarksShapeLayer: CAShapeLayer?
    
    // Vision parts
    private var requests = [VNRequest]()
    private var trackingRequests: [VNTrackObjectRequest]?
    
    lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    
    var performTracking = true
    
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil
        
        guard let modelURL = Bundle.main.url(forResource: "ObjectDetector", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
//        guard let modelURL = Bundle.main.url(forResource: "YOLOv3TinyFP16", withExtension: "mlmodelc") else {
//            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
//        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        

        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to obtain a CVPixelBuffer for the current output frame.")
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        //Instantiate this handler to perform Vision requests on a single image. You specify the image and, optionally, a completion handler at the time of creation, and call perform(_:) to begin executing the request.
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
        
        //Face tracking
//        var requestHandlerOptions: [VNImageOption: AnyObject] = [:]
//        let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil)
//        if cameraIntrinsicData != nil {
//            requestHandlerOptions[VNImageOption.cameraIntrinsics] = cameraIntrinsicData
//        }
//        performFaceTrackingRequest(pixelBuffer: pixelBuffer, exifOrientation: exifOrientation, requestHandlerOptions: requestHandlerOptions)
        
        
    }
    
    func performFaceTrackingRequest (pixelBuffer: CVImageBuffer, exifOrientation: CGImagePropertyOrientation, requestHandlerOptions: [VNImageOption : AnyObject])
    {
        if (performTracking) {
            guard let requests = self.trackingRequests, !requests.isEmpty else {
                NSLog("No tracking requests")
                return
            }
            do {
                try self.sequenceRequestHandler.perform(requests,
                                                         on: pixelBuffer,
                                                         orientation: exifOrientation)
            } catch let error as NSError {
                NSLog("Failed to perform SequenceRequest: %@", error)
            }
            
            // Setup the next round of tracking.
            var newTrackingRequests = [VNTrackObjectRequest]()
            for trackingRequest in requests {
                
                guard let results = trackingRequest.results else {
                    return
                }
                
                guard let observation = results[0] as? VNDetectedObjectObservation else {
                    return
                }
                
                if !trackingRequest.isLastFrame {
                    if observation.confidence > 0.3 {
                        trackingRequest.inputObservation = observation
                    } else {
                        trackingRequest.isLastFrame = true
                    }
                    newTrackingRequests.append(trackingRequest)
                }
            }
            self.trackingRequests = newTrackingRequests
                
            if newTrackingRequests.isEmpty {
                // Nothing to track, so abort.
                return
            }
            
            // Perform face landmark tracking on detected faces.
            var faceLandmarkRequests = [VNDetectFaceLandmarksRequest]()
            
            // Perform landmark detection on tracked faces.
            for trackingRequest in newTrackingRequests {
                
                let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request, error) in
                    
                    if error != nil {
                        print("FaceLandmarks error: \(String(describing: error)).")
                    }
                    
                    guard let landmarksRequest = request as? VNDetectFaceLandmarksRequest,
                        let results = landmarksRequest.results as? [VNFaceObservation] else {
                            return
                    }
                    
                    // Perform all UI updates (drawing) on the main queue, not the background queue on which this handler is being called.
                    DispatchQueue.main.async {
                        self.drawFaceObservations(results)
                    }
                })
                
                guard let trackingResults = trackingRequest.results else {
                    return
                }
                
                guard let observation = trackingResults[0] as? VNDetectedObjectObservation else {
                    return
                }
                let faceObservation = VNFaceObservation(boundingBox: observation.boundingBox)
                faceLandmarksRequest.inputFaceObservations = [faceObservation]
                
                // Continue to track detected facial landmarks.
                faceLandmarkRequests.append(faceLandmarksRequest)
                
                //var requestHandlerOptions: [VNImageOption: AnyObject] = [:]
                let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                                orientation: exifOrientation,
                                                                options: requestHandlerOptions)
                
                do {
                    try imageRequestHandler.perform(faceLandmarkRequests)
                } catch let error as NSError {
                    NSLog("Failed to perform FaceLandmarkRequest: %@", error)
                }
            }
            
        }
    }
    
    override func setupAVCapture(previewView: UIView) {
        super.setupAVCapture(previewView: previewView)
        
        // setup Vision parts
        setupLayers()
        updateLayerGeometry()
        
        //switch coreml detection or face detection here
        setupVision()
        //prepareFaceDetectionRequest()
        
        // start the capture
        startCaptureSession()
    }
    
    func displayPreview(on view: UIView) {
        
        //try? super.displayPreview(on: view)
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        //        self.previewLayer?.frame = view.frame
    }
    
    override func resumeCaptureSession()
    {
        super.resumeCaptureSession()
    }
    
    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
    }
    
    func updateLayerGeometry() {
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
}

extension VisionProcessingCoordinator {
    
    //new for face detection
    func prepareFaceDetectionRequest() {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
        
            if error != nil {
                print("FaceDetection error: \(String(describing: error)).")
            }
            
            guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
                let results = faceDetectionRequest.results as? [VNFaceObservation] else {
                    return
            }
            
            //var alltrackrequests = [VNTrackObjectRequest]() //track multiple objects
            DispatchQueue.main.async {
                //draw face detection results
                self.drawFaceObservations(results)
                
                // Add the observations to the tracking list
//                for observation in results {
//                    //print(observation.boundingBox.width)
//                    let faceTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
//                    alltrackrequests.append(faceTrackingRequest)
//                }
//                self.trackingRequests = alltrackrequests
            }
        })
        self.requests = [faceDetectionRequest]
        
        //add tracking after face detection
        //self.sequenceRequestHandler = VNSequenceRequestHandler()
        
        self.setupFaceDrawingLayers()
    }
    
    
    
    // MARK: Drawing Vision Observations
//    var captureDeviceResolution: CGSize = CGSize()
//
    fileprivate func setupFaceDrawingLayers() {
        let captureDeviceResolution = bufferSize//self.captureDeviceResolution

        let captureDeviceBounds = CGRect(x: 0,
                                         y: 0,
                                         width: captureDeviceResolution.width,
                                         height: captureDeviceResolution.height)

        let captureDeviceBoundsCenterPoint = CGPoint(x: captureDeviceBounds.midX,
                                                     y: captureDeviceBounds.midY)

        let normalizedCenterPoint = CGPoint(x: 0.5, y: 0.5)

        guard let rootLayer = self.rootLayer else {
            self.presentErrorAlert(message: "view was not property initialized")
            return
        }

        let overlayLayer = CALayer()
        overlayLayer.name = "DetectionOverlay"
        overlayLayer.masksToBounds = true
        overlayLayer.anchorPoint = normalizedCenterPoint
        overlayLayer.bounds = captureDeviceBounds
        overlayLayer.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)

        let faceRectangleShapeLayer = CAShapeLayer()
        faceRectangleShapeLayer.name = "RectangleOutlineLayer"
        faceRectangleShapeLayer.bounds = captureDeviceBounds
        faceRectangleShapeLayer.anchorPoint = normalizedCenterPoint
        faceRectangleShapeLayer.position = captureDeviceBoundsCenterPoint
        faceRectangleShapeLayer.fillColor = nil
        faceRectangleShapeLayer.strokeColor = UIColor.green.withAlphaComponent(0.7).cgColor
        faceRectangleShapeLayer.lineWidth = 5
        faceRectangleShapeLayer.shadowOpacity = 0.7
        faceRectangleShapeLayer.shadowRadius = 5

        let faceLandmarksShapeLayer = CAShapeLayer()
        faceLandmarksShapeLayer.name = "FaceLandmarksLayer"
        faceLandmarksShapeLayer.bounds = captureDeviceBounds
        faceLandmarksShapeLayer.anchorPoint = normalizedCenterPoint
        faceLandmarksShapeLayer.position = captureDeviceBoundsCenterPoint
        faceLandmarksShapeLayer.fillColor = nil
        faceLandmarksShapeLayer.strokeColor = UIColor.yellow.withAlphaComponent(0.7).cgColor
        faceLandmarksShapeLayer.lineWidth = 3
        faceLandmarksShapeLayer.shadowOpacity = 0.7
        faceLandmarksShapeLayer.shadowRadius = 5

        overlayLayer.addSublayer(faceRectangleShapeLayer)
        faceRectangleShapeLayer.addSublayer(faceLandmarksShapeLayer)
        rootLayer.addSublayer(overlayLayer)

        self.detectionOverlay = overlayLayer
        //self.detectionOverlayLayer = overlayLayer
        self.detectedFaceRectangleShapeLayer = faceRectangleShapeLayer
        self.detectedFaceLandmarksShapeLayer = faceLandmarksShapeLayer

        self.updateLayerGeometry()
    }
    
    // MARK: Helper Methods for Error Presentation
    fileprivate func presentErrorAlert(withTitle title: String = "Unexpected Failure", message: String) {
        print("FaceDetection error: \(title):")
        print("FaceDetection error message: \(message).")
        //let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //self.present(alertController, animated: true)
    }
    
    fileprivate func presentError(_ error: NSError) {
        self.presentErrorAlert(withTitle: "Failed with error \(error.code)", message: error.localizedDescription)
    }
    
    /// - Tag: DrawPaths
    fileprivate func drawFaceObservations(_ faceObservations: [VNFaceObservation]) {
        guard let faceRectangleShapeLayer = self.detectedFaceRectangleShapeLayer,
            let faceLandmarksShapeLayer = self.detectedFaceLandmarksShapeLayer
            else {
            return
        }
        
        CATransaction.begin()
        
        CATransaction.setValue(NSNumber(value: true), forKey: kCATransactionDisableActions)
        
        let faceRectanglePath = CGMutablePath()
        let faceLandmarksPath = CGMutablePath()
        
        for faceObservation in faceObservations {
            self.addIndicators(to: faceRectanglePath,
                               faceLandmarksPath: faceLandmarksPath,
                               for: faceObservation)
        }
        
        faceRectangleShapeLayer.path = faceRectanglePath
        faceLandmarksShapeLayer.path = faceLandmarksPath
        
        self.updateLayerGeometry()
        
        CATransaction.commit()
    }
    
    fileprivate func addIndicators(to faceRectanglePath: CGMutablePath, faceLandmarksPath: CGMutablePath, for faceObservation: VNFaceObservation) {
        let displaySize = bufferSize//self.captureDeviceResolution
        
        let faceBounds = VNImageRectForNormalizedRect(faceObservation.boundingBox, Int(displaySize.width), Int(displaySize.height))
        faceRectanglePath.addRect(faceBounds)
        
        if let landmarks = faceObservation.landmarks {
            // Landmarks are relative to -- and normalized within --- face bounds
            let affineTransform = CGAffineTransform(translationX: faceBounds.origin.x, y: faceBounds.origin.y)
                .scaledBy(x: faceBounds.size.width, y: faceBounds.size.height)
            
            // Treat eyebrows and lines as open-ended regions when drawing paths.
            let openLandmarkRegions: [VNFaceLandmarkRegion2D?] = [
                landmarks.leftEyebrow,
                landmarks.rightEyebrow,
                landmarks.faceContour,
                landmarks.noseCrest,
                landmarks.medianLine
            ]
            for openLandmarkRegion in openLandmarkRegions where openLandmarkRegion != nil {
                self.addPoints(in: openLandmarkRegion!, to: faceLandmarksPath, applying: affineTransform, closingWhenComplete: false)
            }
            
            // Draw eyes, lips, and nose as closed regions.
            let closedLandmarkRegions: [VNFaceLandmarkRegion2D?] = [
                landmarks.leftEye,
                landmarks.rightEye,
                landmarks.outerLips,
                landmarks.innerLips,
                landmarks.nose
            ]
            for closedLandmarkRegion in closedLandmarkRegions where closedLandmarkRegion != nil {
                self.addPoints(in: closedLandmarkRegion!, to: faceLandmarksPath, applying: affineTransform, closingWhenComplete: true)
            }
        }
    }
    
    fileprivate func addPoints(in landmarkRegion: VNFaceLandmarkRegion2D, to path: CGMutablePath, applying affineTransform: CGAffineTransform, closingWhenComplete closePath: Bool) {
        let pointCount = landmarkRegion.pointCount
        if pointCount > 1 {
            let points: [CGPoint] = landmarkRegion.normalizedPoints
            path.move(to: points[0], transform: affineTransform)
            path.addLines(between: points, transform: affineTransform)
            if closePath {
                path.addLine(to: points[0], transform: affineTransform)
                path.closeSubpath()
            }
        }
    }

}
