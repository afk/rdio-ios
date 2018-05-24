//
//  AddChannelViewController.swift
//  rdio
//
//  Created by Tim Wattenberg on 25.04.18.
//  Copyright © 2018 Tim Wattenberg. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class AddChannelViewController: UIViewController {
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    
    @IBOutlet weak var videoOutputView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startLiveVideo()
        startBarcodeDetection()
    }
    
    func startLiveVideo() {
        // Enable live stream video
        self.session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        // Set the quality of the video
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        // What the camera is seeing
        self.session.addInput(deviceInput)
        // What we will display on the screen
        self.session.addOutput(deviceOutput)
        
        // Show the video as it's being captured
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        let deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
        // Orientation is reversed
//        switch (deviceOrientation) {
//        case .landscapeLeft:
//            previewLayer.connection?.videoOrientation = .landscapeRight
//        case .landscapeRight:
//            previewLayer.connection?.videoOrientation = .landscapeLeft
//        default:
//            previewLayer.connection?.videoOrientation = .landscapeRight
//        }
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = self.videoOutputView.bounds
        self.videoOutputView.layer.addSublayer(previewLayer)
        
        self.session.startRunning()
    }
    
    func startBarcodeDetection() {
        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: self.detectBarcodeHandler)
        self.requests = [barcodeRequest]
    }
    
    func detectBarcodeHandler(request: VNRequest, error: Error?) {
        if error != nil {
            print(error!)
        }
        guard let barcodes = request.results else {
            return
        }
        
        // Perform UI updates on the main thread
        DispatchQueue.main.async {
            if self.session.isRunning {
                self.videoOutputView.layer.sublayers?.removeSubrange(1...)
                
                // This will be used to eliminate duplicate findings
                var barcodeObservations: [String : VNBarcodeObservation] = [:]
                for barcode in barcodes {
                    if let potentialQRCode = barcode as? VNBarcodeObservation {
                        print("Symbology: \(potentialQRCode.symbology.rawValue)")
                        
                        if let desc = potentialQRCode.barcodeDescriptor as? CIQRCodeDescriptor {
                            let content = String(data: desc.errorCorrectedPayload, encoding: .utf8)
                            
                            // FIXME: This currently returns nil. I did not find any docs on how to encode the data properly so far.
                            print("Payload: \(String(describing: content))")
                            print("Error-Correction-Level: \(desc.errorCorrectionLevel)")
                            print("Symbol-Version: \(desc.symbolVersion)")
                        }
                        
                        if potentialQRCode.symbology == .QR {
                            barcodeObservations[potentialQRCode.payloadStringValue!] = potentialQRCode
                        }
                    }
                }
                
                for (barcodeContent, barcodeObservation) in barcodeObservations {
                    //self.drawTextBox(barcodeObservation: barcodeObservation, content: barcodeContent)
                    print(barcodeContent)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddChannelViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // Run Vision code with live stream
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions: [VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics : camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}
